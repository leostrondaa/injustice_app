import 'package:faker_dart/faker_dart.dart';
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

class CharacterCreateView extends StatefulWidget {
  final Account account;
  final Character? character;

  const CharacterCreateView({super.key, required this.account, this.character});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  late final CharactersViewModel _vmCharacter;
  late final CharacterFormFieldsController _formFields;
  final _formKey = GlobalKey<FormState>();
  static final Faker _faker = Faker.instance..setLocale(FakerLocaleType.pt_PT);
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
  }

  Future<void> _salvarCriacao() async {
    if (!_formKey.currentState!.validate()) return;

    if (characterClass == null ||
        characterRarity == null ||
        characterAlign == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('preencha todos os campos.')),
      );
      return;
    }
    final createCharacter = Character(
      id: _faker.datatype.uuid(),
      name: _formFields.name.controller.text.trim(),
      characterClass: characterClass!,
      rarity: characterRarity!,
      alignment: characterAlign!,
      level: characterLvl,
      attack: characterAtk,
      health: characterHp,
      threat: characterThreat,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stars: characterStars,
    );

    await _vmCharacter.commands.addCharacter(createCharacter);

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
        title: const Text('Menu criar'),
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
                onPressed: _salvarCriacao,
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
