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
    final List<TableColumnConfig> columns = [
      TableColumnConfig(title: "Name", key: "name", flex: 3, minWidth: 200),
      TableColumnConfig(
        title: "Barcode",
        key: "barcode",
        flex: 2,
        minWidth: 150,
      ),
      if (!isMobile) ...[
        TableColumnConfig(title: "UOM", key: "uom", flex: 1, minWidth: 80),
        TableColumnConfig(
          title: "Qty",
          key: "qty",
          flex: 1,
          minWidth: 80,
          isNumeric: true,
        ),
        TableColumnConfig(
          title: "Inventory UOM",
          key: "inventoryUom",
          flex: 2,
          minWidth: 120,
        ),
        TableColumnConfig(
          title: "Supplier",
          key: "supplier",
          flex: 3,
          minWidth: 180,
        ),
        TableColumnConfig(
          title: "Categories",
          key: "categories",
          flex: 3,
          minWidth: 200,
        ),
        TableColumnConfig(title: "Hotel", key: "hotel", flex: 2, minWidth: 150),
      ],
      TableColumnConfig(
        title: "Actions",
        key: "actions",
        flex: 1,
        minWidth: 100,
      ),
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
