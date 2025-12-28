import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/products/bloc/categories_bloc.dart';
import 'package:ftrace_web/features/products/bloc/suppliers_bloc.dart';
import 'package:ftrace_web/features/products/model/product_model.dart';

class ProductFilterBar extends StatelessWidget {
  final String? selectedSupplier;
  final String? selectedUom;
  final String? selectedInventoryUom;
  final String? selectedCategory;
  final Function(String? supplier, String? uom, String? invUom, String? cat)
  onChanged;
  final VoidCallback onClear;

  const ProductFilterBar({
    super.key,
    this.selectedSupplier,
    this.selectedUom,
    this.selectedInventoryUom,
    this.selectedCategory,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SuppliersBloc>().state is SuppliersLoaded
        ? (context.watch<SuppliersBloc>().state as SuppliersLoaded).suppliers
              .map((e) => e.name)
              .toList()
        : <String>[];
    final categories = context.watch<CategoriesBloc>().state is CategoriesLoaded
        ? (context.watch<CategoriesBloc>().state as CategoriesLoaded).categories
              .map((e) => e.name)
              .toList()
        : <String>[];
    final uoms = ProductModel.uomOptions;
    final invUoms = ProductModel.uomOptions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: "Supplier",
                  value: selectedSupplier,
                  items: suppliers,
                  onChanged: (v) => onChanged(
                    v,
                    selectedUom,
                    selectedInventoryUom,
                    selectedCategory,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: "UOM",
                  value: selectedUom,
                  items: uoms,
                  onChanged: (v) => onChanged(
                    selectedSupplier,
                    v,
                    selectedInventoryUom,
                    selectedCategory,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: "Inventory UOM",
                  value: selectedInventoryUom,
                  items: invUoms,
                  onChanged: (v) => onChanged(
                    selectedSupplier,
                    selectedUom,
                    v,
                    selectedCategory,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: "Categories",
                  value: selectedCategory,
                  items: categories,
                  onChanged: (v) => onChanged(
                    selectedSupplier,
                    selectedUom,
                    selectedInventoryUom,
                    v,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
                label: const Text("CLEAR FILTERS"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select $label", style: const TextStyle(fontSize: 14)),
              value: value,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text("All")),
                ...items.map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
