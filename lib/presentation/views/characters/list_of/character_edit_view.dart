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

  @override
  void initState() {
    super.initState();
    _vmCharacter = injector.get<CharactersViewModel>();
    _formFields = CharacterFormFieldsController();

    // Preenche com os dados que vieram da tela anterior
    _preencherCampos(widget.character);
  }

  void _preencherCampos(Character character) {
    _formFields.name.controller.text = character.name;
    // Se tiver outros campos como level ou classe, preencha aqui
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) return;

    // Criamos o clone com os dados novos
    final updatedCharacter = widget.character.copyWith(
      name: _formFields.name.controller.text.trim(),
      updatedAt: DateTime.now(),
      // characterClass: widget.character.characterClass, // Mantém ou muda via Dropdown
    );

    await _vmCharacter.commands.updateCharacter(updatedCharacter);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.character.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar do Personagem (UX: Bom ter uma prévia visual)
              CircleAvatar(
                radius: 50,
              ),
              const SizedBox(height: 24),
              InputTextField(
                label: 'Nome do Personagem',
                controller: _formFields.name.controller,
                prefixIcon: Icons.badge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _salvarEdicao,
                child: const Text('SALVAR ALTERAÇÕES'),
              ),
            ],
          ),
        ),
      ),
    );
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
