import 'package:flutter/material.dart';
import 'package:ftrace_web/core/widgets/sidebar_item.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFFF8F9FB),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ftrace\nv1.0.4",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          SidebarItem(icon: Icons.dashboard, title: "Dashboard", selected: true,onTap: ()=>context.go('/dashboard'),),
          SidebarItem(icon: Icons.hotel, title: "Hotels",onTap: ()=>context.go('/hotels'),),
          SidebarItem(icon: Icons.kitchen, title: "Kitchens",),
          SidebarItem(icon: Icons.people, title: "Users"),
          SidebarItem(icon: Icons.list_alt, title: "Operations"),
          SidebarItem(icon: Icons.restaurant, title: "Dishes"),

          const Spacer(),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          )
        ],
      ),
    );
  }
}
