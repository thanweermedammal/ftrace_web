import 'package:flutter/material.dart';
import 'package:ftrace_web/core/theme.dart';

class TableColumnConfig {
  final String title;
  final String key;
  final int flex;
  final double? minWidth;
  final bool isNumeric;

  const TableColumnConfig({
    required this.title,
    required this.key,
    this.flex = 1,
    this.minWidth,
    this.isNumeric = false,
  });
}

class ResponsiveTable<T> extends StatelessWidget {
  final List<TableColumnConfig> columns;
  final List<T> items;
  final Widget Function(BuildContext context, T item, String columnKey)
  cellBuilder;
  final VoidCallback? onHeaderCheckboxChanged;
  final bool? headerCheckboxValue;
  final Widget Function(BuildContext context, T item)? leadingWidgetBuilder;
  final double rowHeight;
  final double headerHeight;

  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.items,
    required this.cellBuilder,
    this.onHeaderCheckboxChanged,
    this.headerCheckboxValue,
    this.leadingWidgetBuilder,
    this.rowHeight = 52.0,
    this.headerHeight = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool isUnchangedWidth = availableWidth == double.infinity;
        final bool isUnchangedHeight = constraints.maxHeight == double.infinity;

        // Calculate the total minimum width required by all columns
        double totalMinWidth =
            48.0; // Starting width for leading/checkbox column
        for (var col in columns) {
          totalMinWidth += col.minWidth ?? 100.0;
        }

        // The table width should be at least the available width or the total min width
        final double tableWidth =
            (!isUnchangedWidth && availableWidth > totalMinWidth)
            ? availableWidth
            : totalMinWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: isUnchangedHeight ? null : constraints.maxHeight,
            child: Column(
              children: [
                _buildHeader(context),
                if (items.isEmpty)
                  _buildEmptyState()
                else if (isUnchangedHeight)
                  ...items.map((item) => _buildRow(context, item))
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _buildRow(context, items[index]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          if (onHeaderCheckboxChanged != null)
            SizedBox(
              width: 40,
              child: Checkbox(
                activeColor: Colors.blue,
                tristate: true,
                value: headerCheckboxValue,
                onChanged: (_) => onHeaderCheckboxChanged!(),
              ),
            ),
          if (onHeaderCheckboxChanged != null) const SizedBox(width: 8),
          ...columns.map(
            (col) => Expanded(
              flex: col.flex,
              child: Container(
                alignment: col.isNumeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  col.title,
                  style: primaryTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, T item) {
    return Container(
      // height: rowHeight, // Removing fixed height to allow for wrapping if needed, though we prefer ellipsis
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          if (leadingWidgetBuilder != null)
            SizedBox(width: 40, child: leadingWidgetBuilder!(context, item)),
          if (leadingWidgetBuilder != null) const SizedBox(width: 8),
          ...columns.map(
            (col) => Expanded(
              flex: col.flex,
              child: Container(
                alignment: col.isNumeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cellBuilder(context, item, col.key),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: const Center(
        child: Text(
          "No data found.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }
}
