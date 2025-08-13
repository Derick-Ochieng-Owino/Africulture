import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final bool isPaginated;
  final int rowsPerPage;
  final void Function(Map<String, dynamic> user)? onEdit;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.isPaginated = true,
    this.rowsPerPage = 10,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              }
              return null;
            },
          ),
          columns: columns
              .map((col) => DataColumn(
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                col,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ))
              .toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: columns.map((col) {
                if (col == 'Online') {
                  final isOnline = row['Online'] == true;
                  return DataCell(Icon(
                    Icons.circle,
                    color: isOnline ? Colors.lightGreenAccent : Colors.redAccent,
                    size: 14,
                  ));
                }
                if (col == 'Actions' && onEdit != null) {
                  return DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit!(row),
                    ),
                  );
                }
                return DataCell(Text(row[col]?.toString() ?? ''));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
