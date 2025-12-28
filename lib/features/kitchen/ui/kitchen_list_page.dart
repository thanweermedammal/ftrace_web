import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import '../bloc/kitchen_bloc.dart';
import '../bloc/kitchen_event.dart';
import '../bloc/kitchen_state.dart';
import '../model/kitchen_model.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:go_router/go_router.dart';

class KitchenListPage extends StatefulWidget {
  final String hotelId;
  const KitchenListPage({super.key, this.hotelId = ''});

  @override
  State<KitchenListPage> createState() => _KitchenListPageState();
}

class _KitchenListPageState extends State<KitchenListPage> {
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String _statusFilter = 'ALL'; // Default to ALL to match Hotel List logic
  bool _showFilters = false;
  List<String> _selectedHotelFilters = [];
  List<String> _selectedStorageFilters = [];

  Set<KitchenModel> _selectedKitchens = {};
  late List<KitchenModel> _filteredKitchens; // Filtered list for display

  // Derived Selection Properties
  bool get _isAllSelected =>
      _filteredKitchens.isNotEmpty &&
      _selectedKitchens.length == _filteredKitchens.length;

  bool get _isNoneSelected => _selectedKitchens.isEmpty;
  int get _selectedCount => _selectedKitchens.length;
  bool get _showDeleteButton => _selectedKitchens.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    UserModel? user;
    if (authState is AuthSuccess) {
      user = authState.user;
    }
    context.read<KitchenBloc>().add(
      LoadKitchens(hotelId: widget.hotelId, currentUser: user),
    );
  }

  // Helper to extract unique values for filters
  List<String> _getUniqueHotels(List<KitchenModel> allKitchens) {
    return allKitchens.map((e) => e.hotelName).toSet().toList()..sort();
  }

  List<String> _getUniqueStorages(List<KitchenModel> allKitchens) {
    return allKitchens.expand((e) => e.storages).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Column(
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
              "Kitchens",
              style: TextStyle(color: Colors.black),
            ),
          )
        else
          const TopBar(title: "Kitchens"),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<KitchenBloc, KitchenState>(
                builder: (context, state) {
                  if (state is KitchenLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is KitchenLoaded) {
                    final allKitchens = state.kitchens;

                    // Apply Filters
                    _filteredKitchens = allKitchens.where((k) {
                      // Hotel Filter
                      if (_selectedHotelFilters.isNotEmpty &&
                          !_selectedHotelFilters.contains(k.hotelName)) {
                        return false;
                      }

                      // Storage Filter
                      if (_selectedStorageFilters.isNotEmpty) {
                        bool hasMatch = k.storages.any(
                          (s) => _selectedStorageFilters.contains(s),
                        );
                        if (!hasMatch) return false;
                      }

                      return true;
                    }).toList();

                    // Sort based on status filter
                    if (_statusFilter == 'ACTIVE') {
                      _filteredKitchens.sort((a, b) {
                        if (a.status.toUpperCase() == 'ACTIVE' &&
                            b.status.toUpperCase() != 'ACTIVE') {
                          return -1;
                        } else if (a.status.toUpperCase() != 'ACTIVE' &&
                            b.status.toUpperCase() == 'ACTIVE') {
                          return 1;
                        }
                        return 0;
                      });
                    } else if (_statusFilter == 'INACTIVE') {
                      _filteredKitchens.sort((a, b) {
                        if (a.status.toUpperCase() == 'INACTIVE' &&
                            b.status.toUpperCase() != 'INACTIVE') {
                          return -1;
                        } else if (a.status.toUpperCase() != 'INACTIVE' &&
                            b.status.toUpperCase() == 'INACTIVE') {
                          return 1;
                        }
                        return 0;
                      });
                    } else {
                      // Default: Active first (Same as Hotel List)
                      _filteredKitchens.sort((a, b) {
                        if (a.status.toUpperCase() == 'ACTIVE' &&
                            b.status.toUpperCase() != 'ACTIVE') {
                          return -1;
                        } else if (a.status.toUpperCase() != 'ACTIVE' &&
                            b.status.toUpperCase() == 'ACTIVE') {
                          return 1;
                        }
                        return 0;
                      });
                    }

                    // Get Options for Filter Dropdowns
                    final hotelOptions = _getUniqueHotels(allKitchens);
                    final storageOptions = _getUniqueStorages(allKitchens);

                    return Column(
                      children: [
                        // TOP BAR: Search | Add | Spacer | Hide Filters | Status Toggle
                        isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (v) {
                                      final authState = context
                                          .read<AuthBloc>()
                                          .state;
                                      final user = authState is AuthSuccess
                                          ? authState.user
                                          : null;
                                      context.read<KitchenBloc>().add(
                                        LoadKitchens(
                                          hotelId: widget.hotelId,
                                          query: v,
                                          currentUser: user,
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Search kitchens...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
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
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.push('/kitchenform');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "ADD KITCHEN",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _showFilters = !_showFilters;
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: Icon(
                                            _showFilters
                                                ? Icons.filter_list_off
                                                : Icons.filter_list,
                                            size: 18,
                                            color: Colors.black87,
                                          ),
                                          label: Text(
                                            _showFilters
                                                ? "HIDE FILTERS"
                                                : "SHOW FILTERS",
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  IntrinsicWidth(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _statusToggleButton("Active"),
                                          Container(
                                            width: 1,
                                            height: 24,
                                            color: Colors.grey.shade300,
                                          ),
                                          _statusToggleButton("Inactive"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) {
                                        final authState = context
                                            .read<AuthBloc>()
                                            .state;
                                        final user = authState is AuthSuccess
                                            ? authState.user
                                            : null;
                                        context.read<KitchenBloc>().add(
                                          LoadKitchens(
                                            hotelId: widget.hotelId,
                                            query: v,
                                            currentUser: user,
                                          ),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search kitchens...",
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 0,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/kitchenform');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "ADD KITCHEN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Show/Hide Filters Button
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _showFilters = !_showFilters;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: Icon(
                                      _showFilters
                                          ? Icons.filter_list_off
                                          : Icons.filter_list,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                    label: Text(
                                      _showFilters
                                          ? "HIDE FILTERS"
                                          : "SHOW FILTERS",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Active/Inactive Toggle
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _statusToggleButton("Active"),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: Colors.grey.shade300,
                                        ),
                                        _statusToggleButton("Inactive"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                        // FILTER SECTION (Collapsible)
                        if (_showFilters)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              // border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildMultiSelectDropdown(
                                        title: "Hotel",
                                        options: hotelOptions,
                                        selectedValues: _selectedHotelFilters,
                                        onChanged: (values) {
                                          setState(() {
                                            _selectedHotelFilters = values;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildMultiSelectDropdown(
                                        title: "Storage",
                                        options: storageOptions,
                                        selectedValues: _selectedStorageFilters,
                                        onChanged: (values) {
                                          setState(() {
                                            _selectedStorageFilters = values;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedHotelFilters.clear();
                                      _selectedStorageFilters.clear();
                                      _statusFilter =
                                          'ACTIVE'; // Reset status too? Or just filters? Usually filters.
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black87,
                                  ),
                                  label: const Text(
                                    "CLEAR FILTERS",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // DELETE BUTTON ROW
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
                                        ? 'Delete 1 Kitchen'
                                        : 'Delete $_selectedCount Kitchens',
                                  ),
                                  onPressed: _onDeleteSelected,
                                ),
                              ],
                            ),
                          ),

                        // TABLE
                        Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _tableHeader(),
                              if (_filteredKitchens.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Text('No kitchens found'),
                                  ),
                                )
                              else
                                ..._filteredKitchens.map(
                                  (k) => _tableRow(context, k),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is KitchenError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- WIDGETS ----------

  Widget _statusToggleButton(String label) {
    bool isSelected = _statusFilter.toUpperCase() == label.toUpperCase();
    return InkWell(
      onTap: () {
        setState(() {
          _statusFilter = label.toUpperCase();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.grey.shade100
              : Colors.transparent, // Minimal highlight
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropdown({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final List<String>? result = await showDialog<List<String>>(
              context: context,
              builder: (context) {
                List<String> tempSelected = List.from(selectedValues);
                return StatefulBuilder(
                  builder: (context, setStateSB) {
                    return AlertDialog(
                      title: Text("Select $title"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: options.map((option) {
                            return CheckboxListTile(
                              title: Text(option),
                              value: tempSelected.contains(option),
                              onChanged: (checked) {
                                setStateSB(() {
                                  if (checked == true) {
                                    tempSelected.add(option);
                                  } else {
                                    tempSelected.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, tempSelected),
                          child: const Text("Apply"),
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (result != null) {
              onChanged(result);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ), // adjusted for chips
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedValues.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "All",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: selectedValues.map((val) {
                            return Chip(
                              label: Text(
                                val,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey.shade100,
                              onDeleted: () {
                                final newList = List<String>.from(
                                  selectedValues,
                                )..remove(val);
                                onChanged(newList);
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap, // denser
                              padding: const EdgeInsets.all(0),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Checkbox(
              activeColor: Colors.blue,
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedKitchens = _filteredKitchens.toSet();
                  } else {
                    _selectedKitchens.clear();
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 25,
            child: Text("Kitchen Name", style: primaryTextStyle),
          ),
          Expanded(flex: 25, child: Text("Hotel", style: primaryTextStyle)),
          Expanded(flex: 40, child: Text("Storages", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Status", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Actions", style: primaryTextStyle)),
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
              ? 'Are you sure you want to delete this Kitchen?'
              : 'Are you sure you want to delete $_selectedCount Kitchens?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<KitchenBloc>().add(
                DeleteKitchens(_selectedKitchens.toList()),
              );

              setState(() {
                _selectedKitchens.clear();
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, KitchenModel kitchen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Checkbox(
              activeColor: Colors.blue,
              value: _selectedKitchens.contains(kitchen),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedKitchens.add(kitchen);
                  } else {
                    _selectedKitchens.remove(kitchen);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              kitchen.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              kitchen.hotelName,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 40,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: kitchen.storages
                  .take(3)
                  .map(
                    (k) => Chip(
                      label: Text(k),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            flex: 15,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  kitchen.status.toUpperCase(),
                  style: TextStyle(
                    color: kitchen.status.toUpperCase() == 'ACTIVE'
                        ? Colors.green
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: kitchen.status.toUpperCase() == 'ACTIVE'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  padding: EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: () {
                    context.push('/kitchendetail', extra: kitchen);
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  padding: EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: () {
                    context.push('/kitchenform', extra: kitchen);
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
