// user_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import 'package:ftrace_web/features/users/bolc/users_bloc.dart';
import 'package:ftrace_web/features/users/bolc/users_event.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String role = 'Hotel Admin';
  String status = 'Active';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // 📱 MOBILE DRAWER
      drawer: isMobile
          ? const Drawer(
        child: Sidebar(),
      )
          : null,

      // ---------- TOP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        // 📱 Show menu icon ONLY on mobile
        leading: isMobile
            ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : null,

        title: const Text(
          "Users/Form",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(_name, 'Name'),
            _field(_email, 'Email'),
            _field(_phone, 'Phone'),
            DropdownButtonFormField(
              value: role,
              items: const [
                DropdownMenuItem(value: 'Hotel Admin', child: Text('Hotel Admin')),
                DropdownMenuItem(value: 'Chef', child: Text('Chef')),
                DropdownMenuItem(value: 'Safety Officer', child: Text('Safety Officer')),
              ],
              onChanged: (v) => setState(() => role = v!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            DropdownButtonFormField(
              value: status,
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (v) => setState(() => status = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _save() {
    final user = UserModel(
      id: '',
      name: _name.text,
      email: _email.text,
      role: role,
      phone: _phone.text,
      status: status,
      hotelIds: [],
      kitchenIds: [],
    );

    context.read<UserBloc>().add(AddUser(user));
    Navigator.pop(context);
  }
}
