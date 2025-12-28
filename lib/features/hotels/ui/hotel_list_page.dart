import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:go_router/go_router.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  String _statusFilter = 'ALL'; // 'ACTIVE', 'INACTIVE', or 'ALL'
  Set<String> _selectedHotelIds = {};
  late List<HotelModel> _currentHotels;

  bool get _isAllSelected => _selectedHotelIds.length == _currentHotels.length;

  bool get _isNoneSelected => _selectedHotelIds.isEmpty;
  int get _selectedCount => _selectedHotelIds.length;

  bool get _showDeleteButton => _selectedHotelIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null; // 🔹 indeterminate
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
            title: const Text("Hotels", style: TextStyle(color: Colors.black)),
          )
        else
          const TopBar(title: "Hotels"),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<HotelBloc, HotelState>(
              builder: (context, state) {
                if (state is HotelLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HotelLoaded) {
                  // Always show all hotels, just change the sorting order
                  List<HotelModel> filteredHotels = List.from(state.hotels);
                  _currentHotels = filteredHotels;

                  // Sort based on selected filter
                  if (_statusFilter == 'ACTIVE') {
                    // Active first, then Inactive
                    filteredHotels.sort((a, b) {
                      if (a.status.toUpperCase() == 'ACTIVE' &&
                          b.status.toUpperCase() != 'ACTIVE') {
                        return -1; // Active comes first
                      } else if (a.status.toUpperCase() != 'ACTIVE' &&
                          b.status.toUpperCase() == 'ACTIVE') {
                        return 1; // Inactive comes last
                      }
                      return 0; // Maintain order
                    });
                  } else if (_statusFilter == 'INACTIVE') {
                    // Inactive first, then Active
                    filteredHotels.sort((a, b) {
                      if (a.status.toUpperCase() == 'INACTIVE' &&
                          b.status.toUpperCase() != 'INACTIVE') {
                        return -1; // Inactive comes first
                      } else if (a.status.toUpperCase() != 'INACTIVE' &&
                          b.status.toUpperCase() == 'INACTIVE') {
                        return 1; // Active comes last
                      }
                      return 0; // Maintain order
                    });
                  } else {
                    // Default: Active first
                    filteredHotels.sort((a, b) {
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

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 🔍 SEARCH + ADD
                        isMobile
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    onChanged: (v) {
                                      final authState = context
                                          .read<AuthBloc>()
                                          .state;
                                      final user = authState is AuthSuccess
                                          ? authState.user
                                          : null;
                                      context.read<HotelBloc>().add(
                                        LoadHotels(query: v, currentUser: user),
                                      );
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
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.push('/hotelsform');
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
                                            "ADD HOTEL",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // child: ElevatedButton.icon(
                                        //
                                        //   onPressed: () {
                                        //     context.push('/hotelsform');
                                        //   },
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: Colors.blue,
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 20,
                                        //       vertical: 16,
                                        //     ),
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius: BorderRadius.circular(8),
                                        //     ),
                                        //   ),
                                        //   icon: const Icon(Icons.add),
                                        //   label: const Text("ADD HOTEL",
                                        //     style: TextStyle(
                                        //       color: Colors.white,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),),
                                        // ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IntrinsicWidth(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _filterButton('ACTIVE'),
                                              _filterButton('INACTIVE'),
                                            ],
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
                                      onChanged: (v) {
                                        final authState = context
                                            .read<AuthBloc>()
                                            .state;
                                        final user = authState is AuthSuccess
                                            ? authState.user
                                            : null;
                                        context.read<HotelBloc>().add(
                                          LoadHotels(
                                            query: v,
                                            currentUser: user,
                                          ),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search hotels...",
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // ElevatedButton.icon(
                                  //   onPressed: () {
                                  //     context.push('/hotelsform');
                                  //   },
                                  //   icon: const Icon(Icons.add),
                                  //   label: const Text("ADD HOTEL"),
                                  // ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/hotelsform');
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
                                      "ADD HOTEL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
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
                                        _filterButton('ACTIVE'),
                                        _filterButton('INACTIVE'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                        const SizedBox(height: 20),
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
                                        ? 'Delete 1 Hotel'
                                        : 'Delete $_selectedCount Hotels',
                                  ),
                                  onPressed: _onDeleteSelected,
                                ),
                              ],
                            ),
                          ),
                        // 📋 TABLE
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _tableHeader(isMobile),
                              ...filteredHotels.map((hotel) {
                                return _tableRow(context, hotel, isMobile);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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
              // 🔥 dispatch delete event
              context.read<HotelBloc>().add(
                DeleteHotels(_selectedHotelIds.toList()),
              );

              setState(() {
                _selectedHotelIds.clear();
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _tableHeader(bool isMobile) {
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
                    // select all
                    _selectedHotelIds = _currentHotels.map((e) => e.id).toSet();
                  } else {
                    // clear all
                    _selectedHotelIds.clear();
                  }
                });
              },
            ),
          ),

          Expanded(flex: 20, child: Text("Name", style: primaryTextStyle)),
          Expanded(flex: 25, child: Text("Email", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Phone", style: primaryTextStyle)),
          if (!isMobile)
            Expanded(
              flex: 20,
              child: Text("Kitchens", style: primaryTextStyle),
            ),
          Expanded(flex: 12, child: Text("Status", style: primaryTextStyle)),
          Expanded(flex: 12, child: Text("Actions", style: primaryTextStyle)),
        ],
      ),
    );
  }

  // ---------- ROW ----------
  Widget _tableRow(BuildContext context, HotelModel hotel, bool isMobile) {
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
          ),

          // NAME
          Expanded(
            flex: 20,
            child: Text(
              hotel.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // EMAIL
          Expanded(
            flex: 25,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(hotel.email),
            ),
          ),

          // PHONE
          Expanded(flex: 15, child: Text(hotel.phone)),

          // KITCHENS
          if (!isMobile)
            Expanded(
              flex: 20,
              child: Builder(
                builder: (_) {
                  final kitchens = hotel.kitchens;

                  if (kitchens.isEmpty) {
                    return const Text("-");
                  }

                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: kitchens
                        .map(
                          (k) => Chip(
                            label: Text(k),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),

          // STATUS
          Expanded(
            flex: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  hotel.status.toUpperCase(),
                  style: TextStyle(
                    color: hotel.status.toUpperCase() == 'ACTIVE'
                        ? Colors.green
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: hotel.status.toUpperCase() == 'ACTIVE'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // ACTIONS
          Expanded(
            flex: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  padding: EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: () {
                    context.push('/hoteldetail', extra: hotel);
                  },
                ),
                const SizedBox(width: 3),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  padding: EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  onPressed: () {
                    context.push('/hotelsform', extra: hotel);
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
