import 'package:flutter/material.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
import 'package:ftrace_web/features/products/model/product_model.dart';
import 'package:go_router/go_router.dart';

class ProductTable extends StatelessWidget {
  final List<ProductModel> products;
  final Set<String> selectedIds;
  final bool isMobile;
  final Function(String id, bool selected) onSelectionChanged;
  final Function(bool all) onSelectAll;

  const ProductTable({
    super.key,
    required this.products,
    required this.selectedIds,
    required this.isMobile,
    required this.onSelectionChanged,
    required this.onSelectAll,
  });

  bool get _isAllSelected =>
      products.isNotEmpty && selectedIds.length == products.length;
  bool get _isNoneSelected => selectedIds.isEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<TableColumnConfig<ProductModel>> columns = [
      TableColumnConfig(title: "Name", key: "name", valueGetter: (p) => p.name),
      TableColumnConfig(
        title: "Barcode",
        key: "barcode",
        valueGetter: (p) => p.barcode,
      ),
      if (!isMobile) ...[
        TableColumnConfig(title: "UOM", key: "uom", valueGetter: (p) => p.uom),
        TableColumnConfig(
          title: "Qty",
          key: "qty",
          isNumeric: true,
          valueGetter: (p) => p.quantity.toString(),
        ),
        TableColumnConfig(
          title: "Inventory UOM",
          key: "inventoryUom",
          valueGetter: (p) => p.inventoryUom,
        ),
        TableColumnConfig(
          title: "Categories",
          key: "categories",
          valueGetter: (p) => p.categories.join(", "),
        ),
        TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          valueGetter: (p) => p.hotelName,
        ),
      ],
      const TableColumnConfig(title: "Actions", key: "actions", minWidth: 100),
    ];

    return ResponsiveTable<ProductModel>(
      columns: columns,
      items: products,
      headerCheckboxValue: _headerCheckboxValue,
      onHeaderCheckboxChanged: () => onSelectAll(!_isAllSelected),
      leadingWidgetBuilder: (context, p) => Checkbox(
        activeColor: Colors.blue,
        value: selectedIds.contains(p.id),
        onChanged: (checked) => onSelectionChanged(p.id, checked == true),
      ),
      cellBuilder: (context, p, key) {
        switch (key) {
          case 'name':
            return Text(
              p.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            );
          case 'barcode':
            return Text(
              p.barcode,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            );
          case 'uom':
            return Text(p.uom, style: const TextStyle(fontSize: 13));
          case 'qty':
            return Text(
              p.quantity.toString(),
              style: const TextStyle(fontSize: 13),
            );
          case 'inventoryUom':
            return Text(
              p.inventoryUom,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            );
          case 'supplier':
            return Text(
              p.supplier,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            );
          case 'categories':
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: p.categories.map((c) => _categoryChip(c)).toList(),
            );
          case 'hotel':
            return Text(
              p.hotelName,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            );
          case 'actions':
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () => context.push('/productdetail', extra: p),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => context.push('/productform', extra: p),
                ),
              ],
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }
}
