import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ftrace_web/features/users/bloc/users_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:intl/intl.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;
  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        UserModel currentUser = user;

        if (state is UserLoaded) {
          try {
            currentUser = state.users.firstWhere((u) => u.id == user.id);
          } catch (_) {
            // User might be deleted
          }
        }

        return Column(
          children: [
            if (isMobile)
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.dashboard, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.people_outline, size: 20, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "Users Detail",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BREADCRUMB + TITLE + EDIT BUTTON
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/usersform', extra: currentUser);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "EDIT USER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // MAIN CONTENT GRID
                    if (isMobile)
                      Column(
                        children: [
                          _leftColumn(context, currentUser,isMobile),
                          const SizedBox(height: 24),
                          _rightColumn(currentUser),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _leftColumn(context, currentUser,isMobile),
                          ),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _rightColumn(currentUser)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _leftColumn(BuildContext context, UserModel currentUser,isMobile) {
    return Column(
      children: [
        _basicInfoCard(currentUser),
        const SizedBox(height: 24),
        _assignedHotelsCard(context, currentUser,isMobile),
        const SizedBox(height: 24),
        _assignedKitchensCard(context, currentUser,isMobile),
      ],
    );
  }

  Widget _rightColumn(UserModel currentUser) {
    return Column(
      children: [
        _infoCard("Role", _roleChip(currentUser.role)),
        const SizedBox(height: 16),
        _infoCard("Status", _statusChip(currentUser.status)),
        const SizedBox(height: 16),
        _timestampsCard(currentUser),
      ],
    );
  }

  Widget _basicInfoCard(UserModel currentUser) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Basic Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _detailItem(Icons.person_outline, "Name", currentUser.name),
          const SizedBox(height: 16),
          _detailItem(Icons.email_outlined, "Email", currentUser.email),
          const SizedBox(height: 16),
          _detailItem(
            Icons.lock_outline,
            "Password",
            currentUser.password.isEmpty ? "******" : currentUser.password,
          ),
          const SizedBox(height: 16),
          _detailItem(
            Icons.phone_outlined,
            "Phone",
            currentUser.phone.isEmpty ? "N/A" : currentUser.phone,
          ),
          const SizedBox(height: 16),
          _detailItem(
            Icons.location_on_outlined,
            "Address",
            currentUser.address.isEmpty ? "N/A" : currentUser.address,
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _assignedHotelsCard(BuildContext context, UserModel currentUser,isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Assigned Hotels",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const Spacer(),
              if(!isMobile)
                Row(
                  children: [TextButton(
                    onPressed: () => context.push('/hotels'),
                    child: const Text("View All Hotels"),
                  ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddHotelDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        "Add Hotel",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),],
                ),
              if(isMobile)
                Column(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/hotels'),
                      child: const Text("View All Hotels"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddHotelDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        "Add Hotel",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                )


            ],
          ),
          const SizedBox(height: 24),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF5FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: const [
                Text(
                  "Hotel Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (currentUser.hotelNames.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: const Center(
                child: Text(
                  "No hotels assigned to this user",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...currentUser.hotelNames.map(
                  (name) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(children: [Text(name)]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _assignedKitchensCard(BuildContext context, UserModel currentUser,isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Assigned Kitchens",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if(!isMobile)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/kitchen'),
                      child: const Text("View All Kitchens"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddKitchenDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        "Add Kitchen",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              if(isMobile)
                Column(
                  children: [
                    TextButton(
                      onPressed: () => context.push('/kitchen'),
                      child: const Text("View All Kitchens"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAddKitchenDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        "Add Kitchen",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                )

            ],
          ),
          const SizedBox(height: 24),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF5FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: const [
                Text(
                  "Kitchen ID",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (currentUser.kitchenIds.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: const Center(
                child: Text(
                  "No kitchens assigned to this user",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...currentUser.kitchenIds.map(
                  (id) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    right: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(children: [Text(id)]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _roleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final active = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: active ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _timestampsCard(UserModel currentUser) {
    final dateFormat = DateFormat('MMMM dd, yyyy at HH:mm');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Timestamps",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _timestampItem(
            Icons.calendar_today_outlined,
            "Created",
            currentUser.createdAt != null
                ? dateFormat.format(currentUser.createdAt!)
                : "N/A",
          ),
          const SizedBox(height: 16),
          _timestampItem(
            Icons.access_time,
            "Last Updated",
            currentUser.updatedAt != null
                ? dateFormat.format(currentUser.updatedAt!)
                : "N/A",
          ),
        ],
      ),
    );
  }

  Widget _timestampItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddHotelDialog(BuildContext context) {
    final TextEditingController hotelNamesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Hotels'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hotel Name(s)*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hotelNamesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                  'Enter hotel names separated by commas (e.g., Hotel A, Hotel B, Hotel C)',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final names = hotelNamesController.text.trim();
              if (names.isNotEmpty) {
                // TODO: Process hotel names and add them
                // For now, just close the dialog
                Navigator.of(dialogContext).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hotels added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddKitchenDialog(BuildContext context) {
    final TextEditingController kitchenNamesController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Kitchens'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kitchen Name(s)*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kitchenNamesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                  'Enter kitchen names separated by commas (e.g., Kitchen A, Kitchen B, Kitchen C)',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final names = kitchenNamesController.text.trim();
              if (names.isNotEmpty) {
                // TODO: Process kitchen names and add them
                // For now, just close the dialog
                Navigator.of(dialogContext).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kitchens added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
