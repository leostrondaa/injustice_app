import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CharacterDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final String Function(T) itemLabelBuilder;
  final void Function(T?) onChanged;

  const CharacterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.itemLabelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabelBuilder(item), // Aqui ele usa o displayName do seu Enum
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        value: value,
        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        dropdownStyleData: const DropdownStyleData(
          maxHeight: 250,
        ),
      ),
    );
  }
}
