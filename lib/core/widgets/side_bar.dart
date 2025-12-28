import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/sidebar_item.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_event.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.path;

    return Container(
      width: 250,
      color: const Color(0xFFF8F9FB),
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ftrace",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    Text(
                      "V1.0.4",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Menu Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SidebarItem(
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                    selected: location == '/dashboard',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/dashboard');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.apartment_outlined,
                    title: "Hotels",
                    selected:
                        location.startsWith('/hotels') ||
                        location == '/hotelsform' ||
                        location == '/hoteldetail',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/hotels');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.kitchen_outlined,
                    title: "Kitchens",
                    selected: location.startsWith('/kitchen'),
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/kitchen');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.people_outline,
                    title: "Users",
                    selected: location.startsWith('/users'),
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/users');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.assignment_outlined,
                    title: "Operations",
                    selected: location.startsWith('/operations'),
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/operations');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.restaurant_outlined,
                    title: "Dishes",
                    selected:
                        location.startsWith('/dishes') ||
                        location == '/dishform' ||
                        location == '/dishdetail',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/dishes');
                    },
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    "Product",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SidebarItem(
                    icon: Icons.inventory_2_outlined,
                    title: "Products",
                    selected:
                        location.startsWith('/products') ||
                        location == '/productform',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/products');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.category_outlined,
                    title: "Categories",
                    selected:
                        location.startsWith('/categories') ||
                        location == '/categoryform',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/categories');
                    },
                  ),
                  SidebarItem(
                    icon: Icons.local_shipping_outlined,
                    title: "Suppliers",
                    selected:
                        location.startsWith('/suppliers') ||
                        location == '/supplierform',
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Navigator.pop(context);
                      }
                      context.go('/suppliers');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Logout Section
          Padding(padding: const EdgeInsets.all(16.0), child: _LogoutButton()),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        transform: Matrix4.identity()..translate(isHover ? 6.0 : 0.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isHover ? Colors.red.withOpacity(0.3) : Colors.grey[200]!,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isHover ? Colors.red.withOpacity(0.05) : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 20,
                    color: isHover ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "LOGOUT",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isHover ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
