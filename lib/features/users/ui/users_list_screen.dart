import 'package:flutter/material.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_event.dart';
import 'package:ftrace_web/features/users/bloc/users_state.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeRoleFilter = 'All';
  String _statusFilter = 'ALL'; // 'ACTIVE', 'INACTIVE', or 'ALL'
  Set<String> _selectedUserIds = {};
  late List<UserModel> _currentUsers;

  bool get _isAllSelected => _selectedUserIds.length == _currentUsers.length;

  bool get _isNoneSelected => _selectedUserIds.isEmpty;
  int get _selectedCount => _selectedUserIds.length;

  bool get _showDeleteButton => _selectedUserIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null; // 🔹 indeterminate
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (_) => UserBloc(UserRepository())..add(LoadUsers()),
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
              title: const Text("Users", style: TextStyle(color: Colors.black)),
            )
          else
            const TopBar(title: "Users"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEARCH + ADD + FILTERS
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _searchController,
                                onChanged: (v) {
                                  context.read<UserBloc>().add(
                                    LoadUsers(query: v),
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: "Search users...",
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
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.push('/usersform');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "ADD USER",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _roleFilters(),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IntrinsicWidth(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _statusFilterButton('ACTIVE'),
                                        _statusFilterButton('INACTIVE'),
                                      ],
                                    ),
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
                                    final roleParam = _activeRoleFilter == 'All'
                                        ? null
                                        : _activeRoleFilter;
                                    context.read<UserBloc>().add(
                                      LoadUsers(query: v, role: roleParam),
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search users...",
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
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/usersform');
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
                                ),
                                label: const Text(
                                  "ADD USER",
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
                                    _statusFilterButton('ACTIVE'),
                                    _statusFilterButton('INACTIVE'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _roleFilters(),
                            ],
                          ),
                    const SizedBox(height: 24),
                    _userTable(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleFilters() {
    final roles = {
      'All': 'All',
      'HA': 'Hotel Admin',
      'RO': 'Regional Officer',
      'SO': 'Safety Officer',
      'CHEF': 'Chef',
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: roles.entries.map((entry) {
          return _filterButton(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _filterButton(String roleCode, String roleLabel) {
    bool isSelected = _activeRoleFilter == roleCode;
    return GestureDetector(
      onTap: () {
        setState(() => _activeRoleFilter = roleCode);
        final roleParam = roleCode == 'All' ? null : roleLabel;
        context.read<UserBloc>().add(
          LoadUsers(role: roleParam, query: _searchController.text),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(8) : null,
        ),
        child: Text(
          roleCode,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _statusFilterButton(String label) {
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

  Widget _userTable() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoaded) {
          // Filter and Sort based on _statusFilter
          List<UserModel> filteredUsers = List.from(state.users);
          _currentUsers = filteredUsers;

          if (_statusFilter == 'ACTIVE') {
            filteredUsers.sort((a, b) {
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
            filteredUsers.sort((a, b) {
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
            // Default sort (optional, can mirror Hotel List default if needed)
            // For now, no specific default sort other than original order
            // mimicking "All" generally means "Just show them"
            filteredUsers.sort((a, b) {
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

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
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
                _tableHeader(),
                ...filteredUsers.map((u) => _tableRow(context, u)),
              ],
            ),
          );
        }
        if (state is UserError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
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
                    // select all
                    _selectedUserIds = _currentUsers.map((e) => e.id).toSet();
                  } else {
                    // clear all
                    _selectedUserIds.clear();
                  }
                });
              },
            ),
          ),
          Expanded(flex: 20, child: Text("Name", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Role", style: primaryTextStyle)),
          Expanded(flex: 25, child: Text("Email", style: primaryTextStyle)),
          Expanded(flex: 20, child: Text("Hotel", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Status", style: primaryTextStyle)),
          Expanded(flex: 10, child: Text("Actions", style: primaryTextStyle)),
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
              context.read<UserBloc>().add(
                DeleteUsers(_selectedUserIds.toList()),
              );

              setState(() {
                _selectedUserIds.clear();
              });

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, UserModel user) {
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
        children: [
          Expanded(
            flex: 5,
            child: Checkbox(
              activeColor: Colors.blue,
              value: _selectedUserIds.contains(user.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedUserIds.add(user.id);
                  } else {
                    _selectedUserIds.remove(user.id);
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 15,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(_getRoleLabel(user.role)),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
          // _roleChip(user.role)),
          Expanded(
            flex: 25,
            child: Text(
              user.email,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              user.hotelNames.isEmpty ? "No Hotel" : user.hotelNames.join(", "),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 15,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  user.status.toUpperCase(),
                  style: TextStyle(
                    color: user.status.toUpperCase() == 'ACTIVE'
                        ? Colors.green
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: user.status.toUpperCase() == 'ACTIVE'
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    context.push('/usersdetail', extra: user);
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    context.push('/usersform', extra: user);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String roleCode) {
    // If the role is strictly one of our known acronyms, map it.
    // However, since we are now filtering by Full Name, the user.role is likely "Hotel Admin".
    // "Hotel Admin" is not a key in this map, so it returns "Hotel Admin".
    // This function is kept for safety if data still has "HA".
    const roles = {
      'HA': 'Hotel Admin',
      'RO': 'Regional Officer',
      'SO': 'Safety Officer',
      'CHEF': 'Chef',
    };
    return roles[roleCode] ?? roleCode;
  }
}
