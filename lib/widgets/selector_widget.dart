import 'package:flutter/material.dart';

class SensationSelect extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String?) onChanged;
  final Color labelColor; // New parameter for label color
  final double labelSize;

  const SensationSelect({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelColor = Colors.white, // Default color set to white
    this.labelSize = 10, // Default size set to 10
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(color: labelColor, fontSize: labelSize), // Use labelColor
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      hint: const Text(
                        'Sélectionner',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      items: ['Excellent', 'Bon', 'Moyen', 'Mauvais'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}