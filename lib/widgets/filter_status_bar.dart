// lib/widgets/filter_status_bar.dart
import 'package:flutter/material.dart';

class FilterStatusBar extends StatelessWidget {
  final String filterName;
  final VoidCallback onClear;
  final Color? backgroundColor;

  const FilterStatusBar({
    super.key,
    required this.filterName,
    required this.onClear,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filter: $filterName',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }
}