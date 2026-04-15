import 'package:flutter/material.dart';
import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import 'package:injustice_app/presentation/controllers/characters_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/account_entity.dart';
import '../../../controllers/account_viewmodel.dart';
import '../../../widgets/input_text_field.dart';
import '../../../functions/ui_functions.dart';

class CharacterEditView extends StatefulWidget {
  final Character character; // Obrigatório para edição

  const CharacterEditView({super.key, required this.character});

  @override
  State<CharacterEditView> createState() => _CharacterEditViewState();
}

class _CharacterEditViewState extends State<CharacterEditView> {
  late final CharactersViewModel _vmCharacter;
  late final CharacterFormFieldsController _formFields;
  final _formKey = GlobalKey<FormState>();

  // Estados locais
  // late int _level;
  // late double _gold;
  // late int _gems;

  @override
  void initState() {
    super.initState();
    _vmCharacter = injector.get<CharactersViewModel>();
    _formFields = CharacterFormFieldsController();

    // Injetamos a conta no estado do ViewModel para os effects funcionarem
    _vmCharacter.charactersState.state.value = [widget.character];

    // Inicializa campos e estados locais com os dados atuais
    _preencherCampos(widget.character);
    _setupEffects();
  }

  void _setupEffects() {
    // Effect para mensagens de erro/sucesso (mesma lógica que você já tem)
    effect(() {
      final errorMessage = _vmCharacter.charactersState.message.value;

      if (errorMessage != null && mounted) {
        showSnackBar(context, errorMessage, backgroundColor: Colors.red);
        _vmCharacter.charactersState.clearMessage();
      }
    });
  }

  void _preencherCampos(Character character) {
    _formFields.email.controller.text = character.name;
    _formFields.name.controller.text = character.characterClass.name;
  }

  Future<void> _atualizarCharacter() async {
    if (!_formKey.currentState!.validate()) return;

    // Criamos o objeto mantendo o ID original
    final updatedCharacter = widget.character.copyWith(
      characterClass: CharacterClass.values.byName(_formFields.email.controller.text.trim(),),
      name: _formFields.name.controller.text.trim(),

      updatedAt: DateTime.now(),
    );

    await _vmCharacter.commands.updateAccount(updatedCharacter);

    if (mounted) Navigator.pop(context); // Opcional: volta após salvar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Conta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _excluirConta(), // Sua função de excluir
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputTextField(
                label: 'E-mail',
                controller: _formFields.email.controller,
                prefixIcon: Icons.email,
                enabled: false, // Geralmente e-mail não se edita
              ),
              const SizedBox(height: 16),
              InputTextField(
                label: 'Nome de Usuário',
                controller: _formFields.name.controller,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _atualizarConta,
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formFields.dispose();
    super.dispose();
  }
}

class CharacterFormFieldsController {
  final FormFieldControl email = _createField();
  final FormFieldControl name = _createField();
  final FormFieldControl displayName = _createField();

  List<FormFieldControl> get fields => [email, name, displayName];

  static FormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void clear() {
    for (final field in fields) {
      field.controller.clear();
    }
  }

  void dispose() {
    for (final field in fields) {
      field.focus.dispose();
      field.controller.dispose();
    }
  }
}
