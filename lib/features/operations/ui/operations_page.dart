import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
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
  List<ReceivingModel>? _currentOperation;
  Set<KitchenStorageModel> _selectedMovements = {};
  List<KitchenStorageModel>? _currentMovements;

  bool get _isAllSelected => _selectedTab == 0
      ? (_currentOperation != null &&
            _currentOperation!.isNotEmpty &&
            _selectedOperations.length == _currentOperation!.length)
      : (_currentMovements != null &&
            _currentMovements!.isNotEmpty &&
            _selectedMovements.length == _currentMovements!.length);

  bool get _isNoneSelected => _selectedTab == 0
      ? _selectedOperations.isEmpty
      : _selectedMovements.isEmpty;

  int get _selectedCount => _selectedTab == 0
      ? _selectedOperations.length
      : _selectedMovements.length;

  bool get _showDeleteButton => _selectedCount > 0;

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          final isMobile = width < 600;

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
                  padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildSearchField(),
                      const SizedBox(height: 24),
                      if (_showDeleteButton) _buildDeleteBar(),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: BlocBuilder<OperationsBloc, OperationsState>(
                            builder: (context, state) {
                              if (state is OperationsLoading)
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              if (state is ReceivingLogsLoaded &&
                                  _selectedTab == 0) {
                                final filteredLogs = state.logs
                                    .where(
                                      (log) =>
                                          log.product.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ||
                                          log.barcode.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ||
                                          log.invoiceNo.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ),
                                    )
                                    .toList();
                                _currentOperation = filteredLogs;
                                return _buildReceivingTable(
                                  filteredLogs,
                                  isMobile,
                                );
                              }
                              if (state is StorageMovementsLoaded &&
                                  _selectedTab == 1) {
                                final filteredMovements = state.movements
                                    .where(
                                      (m) =>
                                          m.product.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ) ||
                                          m.barcode.toLowerCase().contains(
                                            _searchQuery.toLowerCase(),
                                          ),
                                    )
                                    .toList();
                                _currentMovements = filteredMovements;
                                return _buildStorageTable(
                                  filteredMovements,
                                  isMobile,
                                );
                              }
                              if (state is OperationsError)
                                return Center(child: Text(state.message));
                              return const Center(
                                child: Text(
                                  "No results.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            },
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

  Widget _buildSearchField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _selectedTab == 0
              ? "Search a receiving..."
              : "Search kitchen storages...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
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
            _selectedOperations.clear();
            _selectedMovements.clear();
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
              _selectedTab == 0
                  ? (_selectedCount == 1
                        ? 'Delete 1 Receiving Log'
                        : 'Delete $_selectedCount Receiving Logs')
                  : (_selectedCount == 1
                        ? 'Delete 1 Movement'
                        : 'Delete $_selectedCount Movements'),
            ),
            onPressed: _onDeleteSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildReceivingTable(List<ReceivingModel> logs, bool isMobile) {
    final List<TableColumnConfig<ReceivingModel>> columns = [
      TableColumnConfig(
        title: "Barcode",
        key: "barcode",
        valueGetter: (l) => l.barcode,
      ),
      TableColumnConfig(
        title: "Invoice No",
        key: "invoiceNo",
        valueGetter: (l) => l.invoiceNo,
      ),
      TableColumnConfig(
        title: "Product",
        key: "product",
        valueGetter: (l) => l.product,
      ),
      TableColumnConfig(
        title: "Quantity",
        key: "quantity",
        valueGetter: (l) => l.quantity.toString(),
      ),
      if (!isMobile) ...[
        TableColumnConfig(
          title: "Expiry Date",
          key: "expiry",
          valueGetter: (l) => l.expiryDate != null
              ? DateFormat('yyyy-MM-dd').format(l.expiryDate!)
              : '-',
        ),
        TableColumnConfig(
          title: "Production Date",
          key: "production",
          valueGetter: (l) => l.productionDate != null
              ? DateFormat('yyyy-MM-dd').format(l.productionDate!)
              : '-',
        ),
        TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          valueGetter: (l) => l.hotelName,
        ),
        TableColumnConfig(
          title: "Received By",
          key: "receivedBy",
          valueGetter: (l) => l.receivedBy,
        ),
      ],
      const TableColumnConfig(title: "Actions", key: "actions", minWidth: 100),
    ];

    return ResponsiveTable<ReceivingModel>(
      columns: columns,
      items: logs,
      headerCheckboxValue: _headerCheckboxValue,
      onHeaderCheckboxChanged: () {
        setState(() {
          if (_isAllSelected) {
            _selectedOperations.clear();
          } else {
            _selectedOperations = logs.toSet();
          }
        });
      },
      leadingWidgetBuilder: (context, log) => Checkbox(
        activeColor: Colors.blue,
        value: _selectedOperations.contains(log),
        onChanged: (checked) {
          setState(() {
            if (checked == true) {
              _selectedOperations.add(log);
            } else {
              _selectedOperations.remove(log);
            }
          });
        },
      ),
      cellBuilder: (context, log, key) {
        switch (key) {
          case 'barcode':
            return Text(log.barcode, overflow: TextOverflow.ellipsis);
          case 'invoiceNo':
            return Text(log.invoiceNo, overflow: TextOverflow.ellipsis);
          case 'product':
            return Text(log.product, overflow: TextOverflow.ellipsis);
          case 'quantity':
            return Text(log.quantity.toString());
          case 'expiry':
            return Text(
              log.expiryDate != null
                  ? DateFormat('yyyy-MM-dd').format(log.expiryDate!)
                  : '-',
              overflow: TextOverflow.ellipsis,
            );
          case 'production':
            return Text(
              log.productionDate != null
                  ? DateFormat('yyyy-MM-dd').format(log.productionDate!)
                  : '-',
              overflow: TextOverflow.ellipsis,
            );
          case 'hotel':
            return Text(log.hotelName, overflow: TextOverflow.ellipsis);
          case 'receivedBy':
            return Text(log.receivedBy, overflow: TextOverflow.ellipsis);
          case 'actions':
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {},
                ),
              ],
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildStorageTable(
    List<KitchenStorageModel> movements,
    bool isMobile,
  ) {
    final List<TableColumnConfig<KitchenStorageModel>> columns = [
      TableColumnConfig(
        title: "Date",
        key: "date",
        valueGetter: (m) => DateFormat('yyyy-MM-dd HH:mm').format(m.date),
      ),
      TableColumnConfig(
        title: "Product",
        key: "product",
        valueGetter: (m) => m.product,
      ),
      TableColumnConfig(
        title: "Barcode",
        key: "barcode",
        valueGetter: (m) => m.barcode,
      ),
      TableColumnConfig(
        title: "Quantity",
        key: "qty",
        valueGetter: (m) => m.quantity.toString(),
      ),
      if (!isMobile) ...[
        TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          valueGetter: (m) => m.hotelName,
        ),
        TableColumnConfig(
          title: "Kitchen",
          key: "kitchen",
          valueGetter: (m) => m.kitchenName,
        ),
        TableColumnConfig(
          title: "Storage",
          key: "storage",
          valueGetter: (m) => m.storageName,
        ),
        TableColumnConfig(
          title: "Moved By",
          key: "movedBy",
          valueGetter: (m) => m.movedBy,
        ),
      ],
    ];
    return ResponsiveTable<KitchenStorageModel>(
      columns: columns,
      items: movements,
      headerCheckboxValue: _headerCheckboxValue,
      onHeaderCheckboxChanged: () {
        setState(() {
          if (_isAllSelected) {
            _selectedMovements.clear();
          } else {
            _selectedMovements = movements.toSet();
          }
        });
      },
      leadingWidgetBuilder: (context, movement) => Checkbox(
        activeColor: Colors.blue,
        value: _selectedMovements.contains(movement),
        onChanged: (checked) {
          setState(() {
            if (checked == true) {
              _selectedMovements.add(movement);
            } else {
              _selectedMovements.remove(movement);
            }
          });
        },
      ),
      cellBuilder: (context, movement, key) {
        switch (key) {
          case 'date':
            return Text(
              DateFormat('yyyy-MM-dd HH:mm').format(movement.date),
              overflow: TextOverflow.ellipsis,
            );
          case 'product':
            return Text(movement.product, overflow: TextOverflow.ellipsis);
          case 'barcode':
            return Text(movement.barcode, overflow: TextOverflow.ellipsis);
          case 'qty':
            return Text(movement.quantity.toString());
          case 'hotel':
            return Text(movement.hotelName, overflow: TextOverflow.ellipsis);
          case 'kitchen':
            return Text(movement.kitchenName, overflow: TextOverflow.ellipsis);
          case 'storage':
            return Text(movement.storageName, overflow: TextOverflow.ellipsis);
          case 'movedBy':
            return Text(movement.movedBy, overflow: TextOverflow.ellipsis);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  void _onDeleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedTab == 0
              ? (_selectedCount == 1
                    ? 'Are you sure you want to delete this receiving log?'
                    : 'Are you sure you want to delete $_selectedCount receiving logs?')
              : (_selectedCount == 1
                    ? 'Are you sure you want to delete this movement?'
                    : 'Are you sure you want to delete $_selectedCount movements?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (_selectedTab == 0) {
                context.read<OperationsBloc>().add(
                  DeleteOperations(_selectedOperations.toList()),
                );
                setState(() => _selectedOperations.clear());
              } else {
                // Adjust depending on whether your BLoC supports movement deletion
                // context.read<OperationsBloc>().add(DeleteMovements(_selectedMovements.toList()));
                setState(() => _selectedMovements.clear());
              }
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
