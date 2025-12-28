import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
import 'package:go_router/go_router.dart';
import '../bloc/suppliers_bloc.dart';
import '../data/suppliers_repository.dart';
import '../model/supplier_model.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedSupplierIds = {};
  List<SupplierModel>? _currentSuppliers;

  bool get _isAllSelected =>
      _currentSuppliers != null &&
      _currentSuppliers!.isNotEmpty &&
      _selectedSupplierIds.length == _currentSuppliers!.length;
  bool get _isNoneSelected => _selectedSupplierIds.isEmpty;
  int get _selectedCount => _selectedSupplierIds.length;
  bool get _showDeleteButton => _selectedSupplierIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobileNav = width < 900;
    final isMobile = width < 600;

    return BlocProvider(
      create: (context) =>
          SuppliersBloc(SuppliersRepository())..add(LoadSuppliers()),
      child: Column(
        children: [
          if (isMobileNav)
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const Text(
                "Suppliers",
                style: TextStyle(color: Colors.black),
              ),
            )
          else
            const TopBar(title: "Suppliers"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24.0),
              child: BlocBuilder<SuppliersBloc, SuppliersState>(
                builder: (context, state) {
                  if (state is SuppliersLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is SuppliersLoaded) {
                    _currentSuppliers = state.suppliers;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionBar(isMobileNav, isMobile),
                        const SizedBox(height: 24),
                        if (_showDeleteButton) _buildDeleteBar(),
                        _buildTable(state.suppliers, isMobile),
                      ],
                    );
                  }
                  if (state is SuppliersError)
                    return Center(child: Text(state.message));
                  return const Center(child: Text("No suppliers found."));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isMobileNav, bool isMobile) {
    if (isMobile) {
      return Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildAddButton(isIconOnly: false),
        ],
      );
    }
    if (isMobileNav) {
      return Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _buildAddButton())]),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 16),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Builder(
      builder: (context) => TextField(
        controller: _searchController,
        onChanged: (v) =>
            context.read<SuppliersBloc>().add(LoadSuppliers(query: v)),
        decoration: InputDecoration(
          hintText: "Search a supplier...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildAddButton({bool isIconOnly = false}) {
    if (isIconOnly) {
      return ElevatedButton(
        onPressed: () => context.push('/supplierform'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => context.push('/supplierform'),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "NEW SUPPLIER",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(
              _selectedCount == 1
                  ? 'Delete 1 Supplier'
                  : 'Delete $_selectedCount Suppliers',
            ),
            onPressed: () => _onDeleteSelected(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<SupplierModel> suppliers, bool isMobile) {
    final columns = [
      const TableColumnConfig(
        title: "Name",
        key: "name",
        flex: 3,
        minWidth: 200,
      ),
      const TableColumnConfig(
        title: "Email",
        key: "email",
        flex: 3,
        minWidth: 200,
      ),
      const TableColumnConfig(
        title: "Phone",
        key: "phone",
        flex: 2,
        minWidth: 150,
      ),
      if (!isMobile) ...[
        const TableColumnConfig(
          title: "Address",
          key: "address",
          flex: 4,
          minWidth: 300,
        ),
        const TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          flex: 2,
          minWidth: 150,
        ),
      ],
      const TableColumnConfig(
        title: "Actions",
        key: "actions",
        flex: 1,
        minWidth: 100,
      ),
    ];

    return Expanded(
      child: ResponsiveTable<SupplierModel>(
        columns: columns,
        items: suppliers,
        headerCheckboxValue: _headerCheckboxValue,
        onHeaderCheckboxChanged: () {
          setState(() {
            if (_isAllSelected) {
              _selectedSupplierIds.clear();
            } else {
              _selectedSupplierIds = suppliers.map((e) => e.id).toSet();
            }
          });
        },
        leadingWidgetBuilder: (context, supplier) => Checkbox(
          activeColor: Colors.blue,
          value: _selectedSupplierIds.contains(supplier.id),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedSupplierIds.add(supplier.id);
              } else {
                _selectedSupplierIds.remove(supplier.id);
              }
            });
          },
        ),
        cellBuilder: (context, supplier, key) {
          switch (key) {
            case 'name':
              return Text(supplier.name, overflow: TextOverflow.ellipsis);
            case 'email':
              return Text(
                supplier.email.isEmpty ? "-" : supplier.email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              );
            case 'phone':
              return Text(
                supplier.phone.isEmpty ? "-" : supplier.phone,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              );
            case 'address':
              return Text(
                supplier.address.isEmpty ? "-" : supplier.address,
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              );
            case 'hotel':
              return Text(supplier.hotelName, overflow: TextOverflow.ellipsis);
            case 'actions':
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () =>
                        context.push('/supplierform', extra: supplier),
                  ),
                ],
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _onDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this supplier?'
              : 'Are you sure you want to delete $_selectedCount suppliers?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (_currentSuppliers == null) return;
              final selectedModels = _currentSuppliers!
                  .where((s) => _selectedSupplierIds.contains(s.id))
                  .toList();
              context.read<SuppliersBloc>().add(
                DeleteSuppliers(selectedModels),
              );
              setState(() => _selectedSupplierIds.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
