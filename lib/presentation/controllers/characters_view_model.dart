import '../../domain/facades/character_facade_usecases_interface.dart';
import '../commands/character_commands.dart';
import 'characters_commands_view_model.dart';
import 'characters_state_viewmodel.dart';

class CharactersViewModel {
  late final CharactersStateViewmodel _state;
  late final CharactersCommandsViewModel commands;
  CharactersStateViewmodel get charactersState => _state;

  CharactersViewModel(ICharacterFacadeUseCases facade) {
    _state = CharactersStateViewmodel();
    commands = CharactersCommandsViewModel(
      state: _state,
      getAccountCommand: GetAllCharactersCommand(facade),
      updateCharacterCommand: UpdateCharacterCommand(facade),
      createCharacterCommand: CreateCharacterCommand(facade),
      deleteCharacterCommand: DeleteCharacterCommand(facade),
    );
  }

  GetAllCharactersCommand get getAllCharactersCommand =>
      commands.getAllCharactersCommand;
  CreateCharacterCommand get createCharacterCommand =>
      commands.createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand =>
      commands.updateCharacterCommand;
}
