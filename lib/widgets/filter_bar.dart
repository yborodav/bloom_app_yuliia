import 'package:flutter/material.dart';
import '../models/yoga_class.dart';

class FilterBar extends StatelessWidget {
  final ClassType? selectedType;
  final Function(ClassType?) onChanged;
  const FilterBar({super.key, required this.selectedType, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selectedType == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          ...ClassType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type.name.toUpperCase()),
                selected: selectedType == type,
                onSelected: (_) => onChanged(type),
              ),
            );
          }),
        ],
      ),
    );
  }
}
