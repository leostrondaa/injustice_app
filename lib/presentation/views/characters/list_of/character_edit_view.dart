import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/validators/empty_str_validator.dart';
import '../../../../../core/validators/text_field_validator.dart';
import '../../../../../core/validators/min_lenght_str_validator.dart';
import '../../../../../core/validators/max_lenght_str_validator.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/models/account_entity.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../../presentation/controllers/characters_view_model.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/character_dropdown.dart';
import '../../../widgets/star_rating.dart';
import '../../../widgets/numeric_spinner.dart';
import 'package:injustice_app/core/typedefs/types_defs.dart';

class CharacterEditView extends StatefulWidget {
  final Character character;
  final Account account;

  const CharacterEditView({
    super.key,
    required this.character,
    required this.account,
  });

  @override
  State<CharacterEditView> createState() => _CharacterEditViewState();
}

class _CharacterEditViewState extends State<CharacterEditView> {
  late final CharactersViewModel _vmCharacter;
  late final CharacterFormFieldsController _formFields;
  final _formKey = GlobalKey<FormState>();
  CharacterClass? characterClass;
  CharacterRarity? characterRarity;
  CharacterAlignment? characterAlign;
  int characterStars = 0;
  int characterAtk = 0;
  int characterHp = 0;
  int characterThreat = 0;
  int characterLvl = 0;

  @override
  void initState() {
    super.initState();
    _vmCharacter = injector.get<CharactersViewModel>();
    _formFields = CharacterFormFieldsController();
    _preencherCampos(widget.character);
    characterClass = widget.character.characterClass;
    characterRarity = widget.character.rarity;
    characterAlign = widget.character.alignment;
    characterStars = widget.character.stars;
    characterAtk = widget.character.attack;
    characterHp = widget.character.health;
    characterThreat = widget.character.threat;
    characterLvl = widget.character.level;
  }

  @override
  void dispose() {
    _formFields.dispose();
    super.dispose();
  }

  void _preencherCampos(Character character) {
    _formFields.name.controller.text = character.name;
  }

  Future<void> _salvarEdicao() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedCharacter = widget.character.copyWith(
      name: _formFields.name.controller.text.trim(),
      characterClass: characterClass ?? widget.character.characterClass,
      rarity: characterRarity ?? widget.character.rarity,
      alignment: characterAlign ?? widget.character.alignment,
      stars: characterStars,
      attack: characterAtk,
      health: characterHp,
      threat: characterThreat,
      level: characterLvl,
      updatedAt: DateTime.now(),
    );

    final result =
        await _vmCharacter.commands.updateCharacter(updatedCharacter);

    if (mounted) {
      context.goNamed(
        AppRouteNames.characters,
        extra: widget.account,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu editar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              InputTextField(
                fieldKey: _formFields.name.key,
                controller: _formFields.name.controller,
                focusNode: _formFields.name.focus,
                label: 'Nome do Personagem',
                hint: 'Digite o nome',
                prefixIcon: Icons.badge,
                validator: (value) {
                  try {
                    TextFieldValidator(validators: [
                      EmptyStrValidator(),
                      MinLengthStrValidator(),
                      MaxLengthStrValidator(),
                    ]).validations(value);

                    return null;
                  } catch (e) {
                    return e.toString().replaceAll('InputFailure: ', '');
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: NumericSpinner(
                        label: 'Nível',
                        value: characterLvl,
                        minValue: 1,
                        maxValue: 80,
                        onChanged: (newValue) =>
                            setState(() => characterLvl = newValue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: NumericSpinner(
                    label: 'Ataque',
                    value: characterAtk,
                    minValue: 0,
                    onChanged: (newValue) =>
                        setState(() => characterAtk = newValue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumericSpinner(
                    label: 'HP',
                    value: characterHp,
                    minValue: 0,
                    onChanged: (newValue) =>
                        setState(() => characterHp = newValue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumericSpinner(
                    label: 'Ameaça',
                    value: characterThreat,
                    minValue: 0,
                    onChanged: (newValue) =>
                        setState(() => characterThreat = newValue),
                  ),
                ),
              ]),
              const SizedBox(
                height: 16,
              ),
              CharacterDropdown<CharacterClass>(
                value: characterClass,
                items: CharacterClass.values,
                hint: 'Selecione a classe',
                itemLabelBuilder: (item) => item.displayName,
                onChanged: (newValue) =>
                    setState(() => characterClass = newValue),
              ),
              const SizedBox(height: 16),
              CharacterDropdown<CharacterRarity>(
                value: characterRarity,
                items: CharacterRarity.values,
                hint: 'Selecione a raridade',
                itemLabelBuilder: (item) => item.displayName,
                onChanged: (newValue) =>
                    setState(() => characterRarity = newValue),
              ),
              const SizedBox(height: 16),
              CharacterDropdown<CharacterAlignment>(
                value: characterAlign,
                items: CharacterAlignment.values,
                hint: 'Selecione o alinhamento',
                itemLabelBuilder: (item) => item.displayName,
                onChanged: (newValue) =>
                    setState(() => characterAlign = newValue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Estrelas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              StarRating(
                stars: characterStars,
                size: 32, 
                interactive: true,
                onStarsChanged: (newStars) {
                  setState(() {
                    characterStars =
                        newStars;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _salvarEdicao,
                child: const Text('Salvar alterações'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.grey[800],
                ),
                onPressed: () => context.goNamed(
                  AppRouteNames.characters,
                  extra: widget.account,
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterFormFieldsController {
  final FormFieldControl name = _createField();

  List<FormFieldControl> get fields => [name];

  static FormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void dispose() {
    name.focus.dispose();
    name.controller.dispose();
  }
}
