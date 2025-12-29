import 'package:flutter/material.dart';
import 'package:ftrace_web/core/theme.dart';

class TableColumnConfig<T> {
  final String title;
  final String key;
  final int flex;
  final double? minWidth;
  final bool isNumeric;
  final String Function(T item)? valueGetter;

  const TableColumnConfig({
    required this.title,
    required this.key,
    this.flex = 1,
    this.minWidth,
    this.isNumeric = false,
    this.valueGetter,
  });
}

class ResponsiveTable<T> extends StatelessWidget {
  final List<TableColumnConfig<T>> columns;
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

  double _measureText(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final bool isUnchangedHeight = constraints.maxHeight == double.infinity;

        // Determine if we show a leading column (checkbox or custom widget)
        final bool showLeading =
            onHeaderCheckboxChanged != null || leadingWidgetBuilder != null;
        final double leadingWidth = showLeading ? 48.0 : 0.0;
        final double sidePadding = 32.0;

        final TextStyle headerStyle = primaryTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        );
        final TextStyle cellStyle = primaryTextStyle;

        // Step 1: Calculate Base Widths based on content
        List<double> columnWidths = [];
        for (var col in columns) {
          // Start with header text width
          double colMax = _measureText(col.title, headerStyle);

          // If there's data and a value getter, check all rows
          if (items.isNotEmpty && col.valueGetter != null) {
            for (var item in items) {
              final val = col.valueGetter!(item);
              final w = _measureText(val, cellStyle);
              if (w > colMax) colMax = w;
            }
          }

          // Respect minWidth if provided
          double width = colMax + 32.0;
          if (col.minWidth != null && width < col.minWidth!) {
            width = col.minWidth!;
          }
          columnWidths.add(width);
        }

        double totalCalculatedWidth =
            sidePadding +
            leadingWidth +
            2.0 +
            columnWidths.fold(0, (a, b) => a + b);

        final double screenWidth = availableWidth;
        double tableWidth;

        if (totalCalculatedWidth <= screenWidth + 0.1) {
          // If content fits (with tiny margin for floating point), fill screen and disable scroll
          tableWidth = screenWidth;
          final double availableForCols =
              screenWidth - sidePadding - leadingWidth - 2.0;
          final double currentColsWidth = columnWidths.fold(0, (a, b) => a + b);

          columnWidths = columnWidths.map((w) {
            return (w / currentColsWidth) * availableForCols;
          }).toList();
        } else {
          // If content definitely exceeds screen, use calculated widths and allow horizontal scroll
          tableWidth = totalCalculatedWidth;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: isUnchangedHeight ? null : constraints.maxHeight,
            child: Column(
              children: [
                _buildHeader(context, showLeading, columnWidths),
                if (items.isEmpty)
                  _buildEmptyState()
                else if (isUnchangedHeight)
                  ...items.map(
                    (item) =>
                        _buildRow(context, item, showLeading, columnWidths),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) => _buildRow(
                        context,
                        items[index],
                        showLeading,
                        columnWidths,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool showLeading,
    List<double> columnWidths,
  ) {
    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          if (showLeading)
            SizedBox(
              width: 40,
              child: onHeaderCheckboxChanged != null
                  ? Checkbox(
                      activeColor: Colors.blue,
                      tristate: true,
                      value: headerCheckboxValue,
                      onChanged: (_) => onHeaderCheckboxChanged!(),
                    )
                  : null,
            ),
          if (showLeading) const SizedBox(width: 8),
          ...columns.asMap().entries.map((entry) {
            final i = entry.key;
            final col = entry.value;
            return SizedBox(
              width: columnWidths[i],
              child: Container(
                alignment: col.isNumeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  col.title,
                  style: primaryTextStyle.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    T item,
    bool showLeading,
    List<double> columnWidths,
  ) {
    return Container(
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
          if (showLeading)
            SizedBox(
              width: 40,
              child: leadingWidgetBuilder != null
                  ? leadingWidgetBuilder!(context, item)
                  : null,
            ),
          if (showLeading) const SizedBox(width: 8),
          ...columns.asMap().entries.map((entry) {
            final i = entry.key;
            final col = entry.value;
            return SizedBox(
              width: columnWidths[i],
              child: Container(
                alignment: col.isNumeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cellBuilder(context, item, col.key),
              ),
            );
          }),
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
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
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
