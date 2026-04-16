import '../../domain/facades/character_facade_usecases_interface.dart';
import '../commands/character_commands.dart';
import 'characters_commands_view_model.dart';
import 'characters_state_viewmodel.dart';

// ViewModel principal que será consumida na UI
/// que mostra a lista de personagens
class CharactersViewModel {
  /// estado principal da tela, que contém a lista de personagens
  late final CharactersStateViewmodel _state;

  /// dispara os commands e effects e observa as mudanças de estado
  late final CharactersCommandsViewModel commands;

  /// Getter público para acessar o estado de Account
  CharactersStateViewmodel get charactersState => _state;

  CharactersViewModel(ICharacterFacadeUseCases facade) {
    _state = CharactersStateViewmodel();
    // dispara os commands e effects
    commands = CharactersCommandsViewModel(
      state: _state,
      getAccountCommand: GetAllCharactersCommand(facade),
      updateCharacterCommand: UpdateCharacterCommand(facade),
      createCharacterCommand: CreateCharacterCommand(facade),
    );
  }
  // --- Comandos expostos ---
  GetAllCharactersCommand get getAllCharactersCommand =>
      commands.getAllCharactersCommand;
  CreateCharacterCommand get createCharacterCommand =>
      commands.createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => commands
      .updateCharacterCommand; // The getter 'updateCharacterCommand' isn't defined for the type 'CharactersCommandsViewModel'. Try importing the library that defines 'updateCharacterCommand', correcting the name to the name of an existing getter, or defining a getter or field named 'updateCharacterCommand'.dartundefined_getter
}
