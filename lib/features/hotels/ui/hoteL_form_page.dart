import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';

class HotelFormPage extends StatelessWidget {
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

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
          "Hotels/Form",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: idCtrl, decoration: InputDecoration(labelText: "Hotel ID (hotel_001)")),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Hotel Name")),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "Phone")),
            TextField(controller: addressCtrl, decoration: InputDecoration(labelText: "Address")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<HotelBloc>().add(
                  AddHotel(
                    id: idCtrl.text,
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    phone: phoneCtrl.text,
                    address: addressCtrl.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("SAVE"),
            ),
          ],
        ),
      ),
    );
  }
}
