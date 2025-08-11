import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<String>? onFilterChanged;

  const FilterWidget({
    super.key,
    required this.filters,
    this.onFilterChanged,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.filters.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: _selectedFilter == filter,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = filter;
            });
            widget.onFilterChanged?.call(filter);
          },
        );
      }).toList(),
    );
  }
}