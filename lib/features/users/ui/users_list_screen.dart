import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_event.dart';
import 'package:ftrace_web/features/users/bloc/users_state.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeRoleFilter = 'All';
  String _statusFilter = 'ALL';
  Set<String> _selectedUserIds = {};
  List<UserModel>? _currentUsers;

  bool get _isAllSelected =>
      _currentUsers != null &&
      _currentUsers!.isNotEmpty &&
      _selectedUserIds.length == _currentUsers!.length;

  bool get _isNoneSelected => _selectedUserIds.isEmpty;
  int get _selectedCount => _selectedUserIds.length;
  bool get _showDeleteButton => _selectedUserIds.isNotEmpty;

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
      create: (_) => UserBloc(UserRepository())..add(LoadUsers()),
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
              title: const Text("Users", style: TextStyle(color: Colors.black)),
            )
          else
            const TopBar(title: "Users"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionBar(isMobileNav, isMobile),
                  const SizedBox(height: 24),
                  if (_showDeleteButton) _buildDeleteBar(),
                  _buildTable(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isMobileNav, bool isMobile) {
    if (isMobileNav) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 12),
              _buildAddButton(isIconOnly: false),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _roleFilters(),
            ),
            const SizedBox(height: 12),
            _buildStatusToggle(),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField()),
        const SizedBox(width: 12),
        _buildAddButton(),
        const Spacer(),
        _buildStatusToggle(),
        const SizedBox(width: 12),
        _roleFilters(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Builder(
      builder: (context) => TextField(
        controller: _searchController,
        onChanged: (v) {
          final roleParam = _activeRoleFilter == 'All'
              ? null
              : _activeRoleFilter;
          context.read<UserBloc>().add(LoadUsers(query: v, role: roleParam));
        },
        decoration: InputDecoration(
          hintText: "Search users...",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildAddButton({bool isIconOnly = false}) {
    if (isIconOnly) {
      return ElevatedButton(
        onPressed: () => context.push('/usersform'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => context.push('/usersform'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "ADD USER",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusFilterButton('ACTIVE'),
          _statusFilterButton('INACTIVE'),
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
        mainAxisSize: MainAxisSize.min,
        children: roles.entries.map((entry) {
          return _filterButton(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _filterButton(String roleCode, String roleLabel) {
    bool isSelected = _activeRoleFilter == roleCode;
    return Builder(
      builder: (context) => GestureDetector(
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
                  ? 'Delete 1 User'
                  : 'Delete $_selectedCount Users',
            ),
            onPressed: _onDeleteSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(bool isMobile) {
    return Expanded(
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is UserLoaded) {
            List<UserModel> filteredUsers = List.from(state.users);

            // Apply Status Filtering and Sorting
            if (_statusFilter == 'ACTIVE') {
              filteredUsers.sort((a, b) {
                if (a.status.toUpperCase() == 'ACTIVE' &&
                    b.status.toUpperCase() != 'ACTIVE')
                  return -1;
                if (a.status.toUpperCase() != 'ACTIVE' &&
                    b.status.toUpperCase() == 'ACTIVE')
                  return 1;
                return 0;
              });
            } else if (_statusFilter == 'INACTIVE') {
              filteredUsers.sort((a, b) {
                if (a.status.toUpperCase() == 'INACTIVE' &&
                    b.status.toUpperCase() != 'INACTIVE')
                  return -1;
                if (a.status.toUpperCase() != 'INACTIVE' &&
                    b.status.toUpperCase() == 'INACTIVE')
                  return 1;
                return 0;
              });
            } else {
              filteredUsers.sort((a, b) {
                if (a.status.toUpperCase() == 'ACTIVE' &&
                    b.status.toUpperCase() != 'ACTIVE')
                  return -1;
                if (a.status.toUpperCase() != 'ACTIVE' &&
                    b.status.toUpperCase() == 'ACTIVE')
                  return 1;
                return 0;
              });
            }

            _currentUsers = filteredUsers;

            final List<TableColumnConfig<UserModel>> columns = [
              TableColumnConfig(
                title: "Name",
                key: "name",
                valueGetter: (u) => u.name,
              ),
              if (!isMobile)
                TableColumnConfig(
                  title: "Role",
                  key: "role",
                  valueGetter: (u) => _getRoleLabel(u.role),
                ),
              TableColumnConfig(
                title: "Email",
                key: "email",
                valueGetter: (u) => u.email,
              ),
              if (isMobile)
                TableColumnConfig(
                  title: "Phone",
                  key: "phone",
                  valueGetter: (u) => u.phone,
                ),
              if (!isMobile) ...[
                TableColumnConfig(
                  title: "Hotels",
                  key: "hotels",
                  valueGetter: (u) => u.hotelNames.join(", "),
                ),
                TableColumnConfig(
                  title: "Status",
                  key: "status",
                  valueGetter: (u) => u.status,
                ),
              ],
              const TableColumnConfig(
                title: "Actions",
                key: "actions",
                minWidth: 100,
              ),
            ];

            return ResponsiveTable<UserModel>(
              columns: columns,
              items: filteredUsers,
              headerCheckboxValue: _headerCheckboxValue,
              onHeaderCheckboxChanged: () {
                setState(() {
                  if (_isAllSelected) {
                    _selectedUserIds.clear();
                  } else {
                    _selectedUserIds = filteredUsers.map((e) => e.id).toSet();
                  }
                });
              },
              leadingWidgetBuilder: (context, user) => Checkbox(
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
              cellBuilder: (context, user, key) {
                switch (key) {
                  case 'name':
                    return Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    );
                  case 'role':
                    final label = _getRoleLabel(user.role);
                    return label.length > 15
                        ? Text(
                            label,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Chip(
                            label: Text(
                              label,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            backgroundColor: Colors.grey.shade100,
                          );
                  case 'email':
                    return Text(
                      user.email,
                      style: const TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    );
                  case 'phone':
                    return Text(
                      user.phone,
                      style: const TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    );
                  case 'hotels':
                    return Text(
                      user.hotelNames.isEmpty
                          ? "No Hotel"
                          : user.hotelNames.join(", "),
                      style: const TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    );
                  case 'status':
                    final isActive = user.status.toUpperCase() == 'ACTIVE';
                    return Chip(
                      label: Text(
                        user.status.toUpperCase(),
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: isActive
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
                          onPressed: () =>
                              context.push('/usersdetail', extra: user),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          onPressed: () =>
                              context.push('/usersform', extra: user),
                        ),
                      ],
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            );
          }
          if (state is UserError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }

  String _getRoleLabel(String roleCode) {
    const roles = {
      'HA': 'Hotel Admin',
      'RO': 'Regional Officer',
      'SO': 'Safety Officer',
      'CHEF': 'Chef',
    };
    return roles[roleCode] ?? roleCode;
  }

  void _onDeleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this user?'
              : 'Are you sure you want to delete $_selectedCount users?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UserBloc>().add(
                DeleteUsers(_selectedUserIds.toList()),
              );
              setState(() => _selectedUserIds.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
