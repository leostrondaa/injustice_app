import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/character_entity.dart';
import '../commands/character_commands.dart';
import 'characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter/foundation.dart';

class CharactersCommandsViewModel {
  final CharactersStateViewmodel state;
  final GetAllCharactersCommand _getAccountCommand;
  final CreateCharacterCommand _createCharacterCommand;
  final UpdateCharacterCommand _updateCharacterCommand;
  final DeleteCharacterCommand _deleteCharacterCommand;

  CharactersCommandsViewModel({
    required this.state,
    required GetAllCharactersCommand getAccountCommand,
    required CreateCharacterCommand createCharacterCommand,
    required UpdateCharacterCommand updateCharacterCommand,
    required DeleteCharacterCommand deleteCharacterCommand,
  })  : _getAccountCommand = getAccountCommand,
        _updateCharacterCommand = updateCharacterCommand,
        _createCharacterCommand = createCharacterCommand,
        _deleteCharacterCommand = deleteCharacterCommand {
    _observeGetAllCharacters();
    _observeCreateCharacter();
    _observeUpdateCharacter();
    _observeDeleteCharacter();
  }

  GetAllCharactersCommand get getAllCharactersCommand => _getAccountCommand;
  CreateCharacterCommand get createCharacterCommand => _createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => _updateCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand => _deleteCharacterCommand;

  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      if (command.isExecuting.value) return;

      final result = command.result.value;
      if (result == null) return;

      result.fold(
        onSuccess: (data) {
          state.clearMessage();
          onSuccess(data);
          command.clear();
        },
        onFailure: (err) {
          debugPrint('DEBUG [Command Error]: ${err.msg}');
          state.setMessage(err.msg);
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  void _observeGetAllCharacters() {
    _observeCommand<List<Character>>(
      _getAccountCommand,
      onSuccess: (characters) => state.state.value = characters,
    );
  }

  void _observeCreateCharacter() {
    _observeCommand<Character>(
      _createCharacterCommand,
      onSuccess: (newChar) {
        state.state.value = [...state.state.value, newChar];
      },
    );
  }

  void _observeUpdateCharacter() {
    _observeCommand<Character>(
      _updateCharacterCommand,
      onSuccess: (updated) {
        debugPrint(
            'DEBUG [Observer Update]: Atualizando ${updated.name} na lista.');
        final currentList = state.state.value;
        state.state.value =
            currentList.map((c) => c.id == updated.id ? updated : c).toList();
      },
    );
  }

  void _observeDeleteCharacter() {
    _observeCommand<Character>(
      _deleteCharacterCommand,
      onSuccess: (deleted) {
        debugPrint(
            'DEBUG [Observer Delete]: Removendo ${deleted.name} da lista.');
        final currentList = state.state.value;
        state.state.value =
            currentList.where((c) => c.id != deleted.id).toList();
      },
    );
  }

  Future<void> fetchCharacters() async {
    state.clearMessage();
    await _getAccountCommand.executeWith(());
  }

  Future<void> addCharacter(Character character) async {
    state.clearMessage();
    await _createCharacterCommand.executeWith((character: character));
  }

  Future<void> updateCharacter(Character character) async {
    state.clearMessage();
    await _updateCharacterCommand.executeWith((character: character));
  }

  Future<void> deleteCharacter(String id) async {
    state.clearMessage();
    _deleteCharacterCommand.executeWith((id: id));
  }
}
