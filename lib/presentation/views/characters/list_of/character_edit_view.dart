import 'package:flutter/material.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import '../../../../domain/models/account_entity.dart';

class CharacterEditView extends StatelessWidget {
  final Character character; // Recebe o objeto completo

  const CharacterEditView({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${character.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${character.id}'),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: character.name,
              decoration: const InputDecoration(labelText: 'Nome do meu cu'),
            ),

          ],
        ),
      ),
    );
  }
}