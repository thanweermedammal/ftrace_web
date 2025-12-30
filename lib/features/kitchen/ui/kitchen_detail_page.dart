import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/kitchen_bloc.dart';
import '../bloc/kitchen_state.dart';
import '../model/kitchen_model.dart';

class KitchenDetailPage extends StatelessWidget {
  final KitchenModel kitchen;
  const KitchenDetailPage({super.key, required this.kitchen});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocBuilder<KitchenBloc, KitchenState>(
      builder: (context, state) {
        KitchenModel currentKitchen = kitchen;

        if (state is KitchenLoaded) {
          try {
            currentKitchen = state.kitchens.firstWhere(
              (k) => k.id == kitchen.id,
            );
          } catch (_) {
            // Kitchen might be deleted
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
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: const Text(
                  "Kitchen Details",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentKitchen.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/kitchenform', extra: currentKitchen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "EDIT KITCHEN",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    if (isMobile)
                      Column(
                        children: [
                          _basicInfoCard(currentKitchen),
                          const SizedBox(height: 24),
                          _assignedStoragesCard(context, currentKitchen),
                          const SizedBox(height: 24),
                          _statusCard(currentKitchen),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _basicInfoCard(currentKitchen),
                                const SizedBox(height: 24),
                                _assignedStoragesCard(context, currentKitchen),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // RIGHT COLUMN
                          Expanded(flex: 1, child: _statusCard(currentKitchen)),
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

  Widget _basicInfoCard(KitchenModel kitchen) {
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
            "Basic Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          _infoRow(Icons.grid_view_outlined, "Kitchen Name", kitchen.name),
          const SizedBox(height: 16),
          _infoRow(Icons.business_outlined, "Hotel", kitchen.hotelName),
        ],
      ),
    );
  }

  Widget _statusCard(KitchenModel kitchen) {
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
            "Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              kitchen.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignedStoragesCard(BuildContext context, KitchenModel kitchen) {
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
          Row(
            children: [
              const Text(
                "Assigned Storages",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // TextButton(
              //   onPressed: () => context.push('/products'),
              //   child: const Text("View All Storages"),
              // ),
              // const SizedBox(width: 8),
              // ElevatedButton.icon(
              //   onPressed: () => context.push('/products'), // storage form?
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //     elevation: 0,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 8,
              //     ),
              //   ),
              //   icon: const Icon(Icons.add, size: 16, color: Colors.white),
              //   label: const Text(
              //     "Add Storage",
              //     style: TextStyle(color: Colors.white, fontSize: 13),
              //   ),
              // ),
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
                  "Storage Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (kitchen.storages.isEmpty)
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
                  "No storages assigned to this kitchen.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...kitchen.storages.map(
              (s) => Container(
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
                child: Row(
                  children: [
                    Text(s, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
