import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/features/operations/bloc/operations_event.dart';
import 'package:ftrace_web/features/operations/bloc/operations_state.dart';
import 'package:intl/intl.dart';
import '../bloc/operations_bloc.dart';
import '../data/operations_repository.dart';
import '../model/operations_model.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  int _selectedTab = 0; // 0 for Receiving, 1 for Kitchen Storages
  Set<ReceivingModel> _selectedOperations = {};
  late List<ReceivingModel> _currentOperation;

  bool get _isAllSelected =>
      _selectedOperations.length == _currentOperation.length;

  bool get _isNoneSelected => _selectedOperations.isEmpty;
  int get _selectedCount => _selectedOperations.length;

  bool get _showDeleteButton => _selectedOperations.isNotEmpty;
  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null; // 🔹 indeterminate
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OperationsBloc(OperationsRepository())
        ..add(_selectedTab == 0 ? LoadReceivingLogs() : LoadStorageMovements()),
      child: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final isMobileNav = width < 900;
          final isTableCompact = width < 1350;

          return Column(
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
                    "Operations",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              else
                const TopBar(title: "Operations"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TABS
                      Row(
                        children: [
                          _tabButton(
                            context,
                            "Receiving",
                            Icons.local_shipping_outlined,
                            0,
                          ),
                          const SizedBox(width: 12),
                          _tabButton(
                            context,
                            "Kitchen Storages",
                            Icons.kitchen_outlined,
                            1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // LIST CONTAINER
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (_selectedTab == 0)
                                _searchBar("Search a receiving..."),
                              const SizedBox(height: 16),
                              Expanded(child: _buildList(isTableCompact)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabButton(
    BuildContext context,
    String title,
    IconData icon,
    int index,
  ) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (_selectedTab != index) {
          setState(() {
            _selectedTab = index;
          });
          if (index == 0) {
            context.read<OperationsBloc>().add(LoadReceivingLogs());
          } else {
            context.read<OperationsBloc>().add(LoadStorageMovements());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF5FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.blue.withOpacity(0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? Colors.blue : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.blue : Colors.grey,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildList(bool isTableCompact) {
    return BlocBuilder<OperationsBloc, OperationsState>(
      builder: (context, state) {
        if (state is OperationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReceivingLogsLoaded && _selectedTab == 0) {
          _currentOperation = state.logs; // Update _currentOperation here
          return _receivingTable(state.logs, isTableCompact);
        }
        if (state is StorageMovementsLoaded && _selectedTab == 1) {
          return _storageTable(state.movements, isTableCompact);
        }
        if (state is OperationsError) {
          return Center(child: Text(state.message));
        }
        return const Center(
          child: Text("No results.", style: TextStyle(color: Colors.grey)),
        );
      },
    );
  }

  Widget _receivingTable(List<ReceivingModel> logs, bool isTableCompact) {
    return Column(
      children: [
        if (_showDeleteButton)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: Text(
                  _selectedCount == 1
                      ? 'Delete 1 Kitchen'
                      : 'Delete $_selectedCount Kitchens',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: _onDeleteSelected,
              ),
            ),
          ),
        _receivingTableHeader(isTableCompact),
        if (logs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text("No results found.")),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) =>
                  _receivingTableRow(context, logs[index], isTableCompact),
            ),
          ),
      ],
    );
  }

  Widget _receivingTableHeader(bool isTableCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    // select all
                    _selectedOperations = _currentOperation.toSet();
                  } else {
                    // clear all
                    _selectedOperations.clear();
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: const Text(
              "Barcode",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isTableCompact)
            const Expanded(
              flex: 3,
              child: Text(
                "Invoice No",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            flex: isTableCompact ? 6 : 4,
            child: const Text(
              "Product",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: const Text(
              "Quantity",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: const Text(
              "Expiry Date",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isTableCompact)
            const Expanded(
              flex: 3,
              child: Text(
                "Production Date",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Expanded(
            flex: 3,
            child: Text(
              "Hotel",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isTableCompact)
            const Expanded(
              flex: 3,
              child: Text(
                "Received By",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: const Text(
              "Actions",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receivingTableRow(
    BuildContext context,
    ReceivingModel log,
    bool isTableCompact,
  ) {
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
              value: _selectedOperations.contains(log),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedOperations.add(log);
                  } else {
                    _selectedOperations.remove(log);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(log.barcode, style: const TextStyle(fontSize: 13)),
          ),
          if (!isTableCompact)
            Expanded(
              flex: 3,
              child: Text(log.invoiceNo, style: const TextStyle(fontSize: 13)),
            ),
          Expanded(
            flex: isTableCompact ? 6 : 4,
            child: Text(log.product, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.quantity.toString(),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              log.expiryDate != null
                  ? DateFormat('yyyy-MM-dd').format(log.expiryDate!)
                  : '-',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (!isTableCompact)
            Expanded(
              flex: 3,
              child: Text(
                log.productionDate != null
                    ? DateFormat('yyyy-MM-dd').format(log.productionDate!)
                    : '-',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          Expanded(
            flex: 3,
            child: Text(log.hotelName, style: const TextStyle(fontSize: 13)),
          ),
          if (!isTableCompact)
            Expanded(
              flex: 3,
              child: Text(log.receivedBy, style: const TextStyle(fontSize: 13)),
            ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this Operation?'
              : 'Are you sure you want to delete $_selectedCount Operations?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // 🔥 dispatch delete event
              context.read<OperationsBloc>().add(
                DeleteOperations(_selectedOperations.toList()),
              );

              setState(() {
                _selectedOperations.clear();
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _storageTable(
    List<KitchenStorageModel> movements,
    bool isTableCompact,
  ) {
    return Column(
      children: [
        _storageTableHeader(isTableCompact),
        if (movements.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text("No results found.")),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) =>
                  _storageTableRow(context, movements[index], isTableCompact),
            ),
          ),
      ],
    );
  }

  Widget _storageTableHeader(bool isTableCompact) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: isTableCompact ? 3 : 2,
            child: const Text(
              "Date",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: isTableCompact ? 6 : 3,
            child: const Text(
              "Product",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              "Barcode",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            flex: isTableCompact ? 2 : 1,
            child: const Text(
              "Qty",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              "Hotel",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              "Kitchen",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              "Storage",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              "Moved By",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storageTableRow(
    BuildContext context,
    KitchenStorageModel m,
    bool isTableCompact,
  ) {
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
            flex: isTableCompact ? 3 : 2,
            child: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(m.date),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: isTableCompact ? 6 : 3,
            child: Text(m.product, style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 3,
            child: Text(m.barcode, style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: isTableCompact ? 2 : 1,
            child: Text(
              m.quantity.toString(),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(m.hotelName, style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 2,
            child: Text(m.kitchenName, style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 2,
            child: Text(m.storageName, style: const TextStyle(fontSize: 13)),
          ),

          Expanded(
            flex: 2,
            child: Text(m.movedBy, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
