import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
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
  late List<SupplierModel> _currentSuppliers;

  bool get _isAllSelected =>
      _selectedSupplierIds.length == _currentSuppliers.length;
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
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) =>
          SuppliersBloc(SuppliersRepository())..add(LoadSuppliers()),
      child: Column(
        children: [
          if (isMobile)
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<SuppliersBloc, SuppliersState>(
                  builder: (context, state) {
                    if (state is SuppliersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SuppliersLoaded) {
                      _currentSuppliers = state.suppliers;
                      return Column(
                        children: [
                          // TOP BAR
                          isMobile
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _searchController,
                                      onChanged: (v) {
                                        context.read<SuppliersBloc>().add(
                                          LoadSuppliers(query: v),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search a supplier...",
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 0,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              context.push('/supplierform');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 20,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "NEW SUPPLIER",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (v) {
                                          context.read<SuppliersBloc>().add(
                                            LoadSuppliers(query: v),
                                          );
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Search a supplier...",
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 0,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.push('/supplierform');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "NEW SUPPLIER",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 24),
                          if (_showDeleteButton)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
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
                            ),

                          // LIST CONTAINER
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildTable(context, state.suppliers),
                          ),
                        ],
                      );
                    }

                    if (state is SuppliersError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text("No suppliers found."));
                  },
                ),
              ),
            ),
          ),
        ],
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
              final selectedModels = _currentSuppliers
                  .where((s) => _selectedSupplierIds.contains(s.id))
                  .toList();
              context.read<SuppliersBloc>().add(
                DeleteSuppliers(selectedModels),
              );
              setState(() {
                _selectedSupplierIds.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<SupplierModel> suppliers) {
    return Column(
      children: [
        _buildTableHeader(),
        if (suppliers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("No suppliers found."),
            ),
          )
        else
          ...suppliers.map((s) => _buildTableRow(context, s)),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Checkbox(
              activeColor: Colors.blue,
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedSupplierIds = _currentSuppliers
                        .map((e) => e.id)
                        .toSet();
                  } else {
                    _selectedSupplierIds.clear();
                  }
                });
              },
            ),
          ),
          Expanded(flex: 8, child: Text("Name", style: primaryTextStyle)),
          Expanded(flex: 8, child: Text("Email", style: primaryTextStyle)),
          Expanded(flex: 6, child: Text("Phone", style: primaryTextStyle)),
          Expanded(flex: 10, child: Text("Address", style: primaryTextStyle)),
          Expanded(flex: 6, child: Text("Hotel", style: primaryTextStyle)),
          SizedBox(width: 80, child: Text("Actions", style: primaryTextStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, SupplierModel supplier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          Expanded(
            flex: 2,
            child: Checkbox(
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
          ),
          Expanded(flex: 8, child: Text(supplier.name)),
          Expanded(
            flex: 8,
            child: Text(
              supplier.email.isEmpty ? "-" : supplier.email,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              supplier.phone.isEmpty ? "-" : supplier.phone,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              supplier.address.isEmpty ? "-" : supplier.address,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              supplier.hotelName,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.edit_note, size: 24),
                  onPressed: () {
                    context.push('/supplierform', extra: supplier);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
