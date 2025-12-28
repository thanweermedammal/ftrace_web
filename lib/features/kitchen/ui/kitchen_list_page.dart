import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import '../bloc/kitchen_bloc.dart';
import '../bloc/kitchen_event.dart';
import '../bloc/kitchen_state.dart';
import 'kitchen_form_page.dart';

class KitchenListPage extends StatelessWidget {
  final String hotelId;
  const KitchenListPage({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    context.read<KitchenBloc>().add(LoadKitchens(hotelId: hotelId));

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
            "Kitchens",
            style: TextStyle(color: Colors.black),
          ),
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KitchenFormPage(hotelId: hotelId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<KitchenBloc, KitchenState>(
        builder: (context, state) {
          if (state is KitchenLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KitchenLoaded) {
            if (state.kitchens.isEmpty) {
              return const Center(child: Text('No kitchens found'));
            }

            return ListView.builder(
              itemCount: state.kitchens.length,
              itemBuilder: (context, i) {
                final k = state.kitchens[i];
                return ListTile(
                  title: Text(k.name),
                  subtitle: Text(k.status),
                );
              },
            );
          }

          if (state is KitchenError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
