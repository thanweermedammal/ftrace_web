import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import '../bloc/kitchen_bloc.dart';
import '../bloc/kitchen_event.dart';
import '../bloc/kitchen_state.dart';

class KitchenFormPage extends StatefulWidget {
  final String hotelId;
  const KitchenFormPage({super.key, required this.hotelId});

  @override
  State<KitchenFormPage> createState() => _KitchenFormPageState();
}

class _KitchenFormPageState extends State<KitchenFormPage> {
  final _nameController = TextEditingController();
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
          "Kitchens/Form",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: BlocListener<KitchenBloc, KitchenState>(
        listener: (context, state) {
          if (state is KitchenSaved) {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Kitchen Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (v) => status = v!,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.read<KitchenBloc>().add(
                    AddKitchen(
                      hotelId: widget.hotelId,
                      name: _nameController.text,
                      status: status,
                      storages: [],
                    ),
                  );
                },
                child: const Text('SAVE'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
