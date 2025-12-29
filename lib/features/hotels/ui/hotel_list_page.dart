import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
import 'package:go_router/go_router.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  String _statusFilter = 'ALL'; // 'ACTIVE', 'INACTIVE', or 'ALL'
  Set<String> _selectedHotelIds = {};
  List<HotelModel>? _currentHotels;

  bool get _isAllSelected =>
      _currentHotels != null &&
      _selectedHotelIds.length == _currentHotels!.length;
  bool get _isNoneSelected => _selectedHotelIds.isEmpty;
  int get _selectedCount => _selectedHotelIds.length;
  bool get _showDeleteButton => _selectedHotelIds.isNotEmpty;

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
    context.read<HotelBloc>().add(LoadHotels(currentUser: user));
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text("Hotels", style: TextStyle(color: Colors.black)),
          )
        else
          const TopBar(title: "Hotels"),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: BlocBuilder<HotelBloc, HotelState>(
              builder: (context, state) {
                if (state is HotelLoading && _currentHotels == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HotelLoaded || _currentHotels != null) {
                  List<HotelModel> hotels = state is HotelLoaded
                      ? List.from(state.hotels)
                      : _currentHotels!;
                  _currentHotels = hotels;

                  // Sort based on selected filter
                  if (_statusFilter == 'ACTIVE') {
                    hotels.sort((a, b) {
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
                    hotels.sort((a, b) {
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
                    hotels.sort((a, b) {
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

                  return Column(
                    children: [
                      _buildTopBar(context, isMobile, isMobileNav),
                      const SizedBox(height: 20),
                      if (_showDeleteButton) _buildDeleteBar(context),
                      _buildTable(hotels, isMobile),
                    ],
                  );
                }

                return const Center(child: Text("Error"));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile, bool isMobileNav) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.push('/hotelsform'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  "ADD HOTEL",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildSearchField(context)),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => context.push('/hotelsform'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            "ADD HOTEL",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [_filterButton('ACTIVE'), _filterButton('INACTIVE')],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      onChanged: (v) {
        final authState = context.read<AuthBloc>().state;
        final user = authState is AuthSuccess ? authState.user : null;
        context.read<HotelBloc>().add(LoadHotels(query: v, currentUser: user));
      },
      decoration: InputDecoration(
        hintText: "Search hotels...",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildDeleteBar(BuildContext context) {
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
                  ? 'Delete 1 Hotel'
                  : 'Delete $_selectedCount Hotels',
            ),
            onPressed: _onDeleteSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<HotelModel> hotels, bool isMobile) {
    final List<TableColumnConfig<HotelModel>> columns = [
      TableColumnConfig(title: "Name", key: "name", valueGetter: (h) => h.name),
      TableColumnConfig(
        title: "Email",
        key: "email",
        valueGetter: (h) => h.email,
      ),
      TableColumnConfig(
        title: "Phone",
        key: "phone",
        valueGetter: (h) => h.phone,
      ),
      if (!isMobile) ...[
        TableColumnConfig(
          title: "Kitchens",
          key: "kitchens",
          valueGetter: (h) => h.kitchens.join(", "),
        ),
        TableColumnConfig(
          title: "Status",
          key: "status",
          valueGetter: (h) => h.status,
        ),
      ],
      const TableColumnConfig(title: "Actions", key: "actions", minWidth: 100),
    ];

    return Expanded(
      child: ResponsiveTable<HotelModel>(
        columns: columns,
        items: hotels,
        headerCheckboxValue: _headerCheckboxValue,
        onHeaderCheckboxChanged: () {
          setState(() {
            if (_isAllSelected) {
              _selectedHotelIds.clear();
            } else {
              _selectedHotelIds = hotels.map((e) => e.id).toSet();
            }
          });
        },
        leadingWidgetBuilder: (context, hotel) => Checkbox(
          activeColor: Colors.blue,
          value: _selectedHotelIds.contains(hotel.id),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedHotelIds.add(hotel.id);
              } else {
                _selectedHotelIds.remove(hotel.id);
              }
            });
          },
        ),
        cellBuilder: (context, hotel, key) {
          switch (key) {
            case 'name':
              return Text(
                hotel.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              );
            case 'email':
              return Text(hotel.email, overflow: TextOverflow.ellipsis);
            case 'phone':
              return Text(hotel.phone, overflow: TextOverflow.ellipsis);
            case 'kitchens':
              if (hotel.kitchens.isEmpty) return const Text("-");
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hotel.kitchens
                    .take(2)
                    .map(
                      (k) => Chip(
                        label: Text(k, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              );
            case 'status':
              return Chip(
                label: Text(
                  hotel.status.toUpperCase(),
                  style: TextStyle(
                    color: hotel.status.toUpperCase() == 'ACTIVE'
                        ? Colors.green
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                backgroundColor: hotel.status.toUpperCase() == 'ACTIVE'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                visualDensity: VisualDensity.compact,
              );
            case 'actions':
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => context.push('/hoteldetail', extra: hotel),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => context.push('/hotelsform', extra: hotel),
                  ),

                  // const SizedBox(width: 12),
                ],
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _filterButton(String label) {
    bool isSelected = _statusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
              ? 'Are you sure you want to delete this hotel?'
              : 'Are you sure you want to delete $_selectedCount hotels?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<HotelBloc>().add(
                DeleteHotels(_selectedHotelIds.toList()),
              );
              setState(() => _selectedHotelIds.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
