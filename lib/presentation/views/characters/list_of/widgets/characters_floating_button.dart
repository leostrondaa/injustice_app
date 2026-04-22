import 'package:flutter/material.dart';
import '../../../../../helper_dev/fakes/character_factory.dart';
import '../../../../controllers/characters_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../../../domain/models/account_entity.dart';
import '../../../../../domain/models/character_entity.dart';

class CharactersFab extends StatelessWidget {
  final CharactersViewModel viewModel;
  final Account account;

  const CharactersFab(
      {super.key, required this.account, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isExecuting =
          viewModel.commands.createCharacterCommand.isExecuting.value;

      return FloatingActionButton(
        onPressed: isExecuting
            ? null
            : () async {
                final RenderBox button =
                    context.findRenderObject() as RenderBox;
                final RenderBox overlay = Navigator.of(context)
                    .overlay!
                    .context
                    .findRenderObject() as RenderBox;

                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );
                final int? selectedValue = await showMenu<int>(
                  context: context,
                  position: position,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  items: [
                    const PopupMenuItem(value: 1, child: Text("Aleatório")),
                    const PopupMenuItem(value: 2, child: Text("Criar")),
                  ],
                );
                if (selectedValue == 1) {
                  final character = CharacterFactory.list(1).first;
                  await viewModel.commands.addCharacter(character);
                } else if (selectedValue == 2) {
                  if (!context.mounted) return;
                  context.goNamed(
                    AppRouteNames.charactersCreate,
                    extra: (
                      character: null as Character?,
                      account: account,
                    ),
                  );
                }
              },
        child: isExecuting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
      );
    });
  }
}
