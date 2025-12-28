import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HotelDetailPage extends StatelessWidget {
  final HotelModel hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        HotelModel currentHotel = hotel;

        // Try to find the latest version of this hotel from the Bloc state
        if (state is HotelLoaded) {
          try {
            currentHotel = state.hotels.firstWhere((h) => h.id == hotel.id);
          } catch (_) {
            // Hotel might have been deleted or not found in the current list
          }
        }

        return Column(
          children: [
            if (isMobile)
              AppBar(
                title: const Text(
                  "Hotels Detail",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.hotel_outlined,
                          size: 28,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentHotel.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/hotelsform', extra: currentHotel);
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
                            "EDIT HOTEL",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CONTENT
                    if (width < 1000)
                      Column(
                        children: [
                          _basicInfoCard(currentHotel),
                          const SizedBox(height: 24),
                          _kitchensTable(currentHotel, context),
                          const SizedBox(height: 24),
                          _statusCard(currentHotel),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN (Info + Kitchens)
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _basicInfoCard(currentHotel),
                                const SizedBox(height: 24),
                                _kitchensTable(currentHotel, context),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // RIGHT COLUMN (Status + Timestamps)
                          Expanded(flex: 1, child: _statusCard(currentHotel)),
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

  Widget _basicInfoCard(HotelModel hotel) {
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
          _infoRow(
            Icons.location_on_outlined,
            "Address",
            hotel.address.isEmpty ? "No address provided" : hotel.address,
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.phone_outlined, "Phone", hotel.phone),
          const SizedBox(height: 16),
          _infoRow(Icons.email_outlined, "Email", hotel.email),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _statusCard(HotelModel hotel) {
    final dateFormat = DateFormat("MMMM dd, yyyy 'at' hh:mm a");
    return Column(
      children: [
        Container(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Chip(
                label: Text(
                  hotel.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: Colors.green.shade100,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
              const SizedBox(height: 16),
              _timestampRow(
                Icons.calendar_today,
                "Created",
                hotel.createdAt != null
                    ? dateFormat.format(hotel.createdAt!.toDate())
                    : "-",
              ),
              const SizedBox(height: 16),
              _timestampRow(
                Icons.access_time,
                "Last Updated",
                hotel.updatedAt != null
                    ? dateFormat.format(hotel.updatedAt!.toDate())
                    : "-",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timestampRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kitchensTable(HotelModel hotel, BuildContext context) {
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
          // Section Title & Actions
          Row(
            children: [
              const Text(
                "Kitchens",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.push('/kitchen');
                },
                child: const Text("View All Kitchens"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/kitchenform?hotelId=${hotel.id}');
                },
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
                Expanded(
                  child: Text(
                    "Kitchen Name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    "Status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List or Empty View
          if (hotel.kitchens.isEmpty)
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
              child: Column(
                children: [
                  Icon(
                    Icons.kitchen_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No kitchens assigned to this hotel.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ...hotel.kitchens.map((k) {
              return Container(
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
                    Expanded(child: Text(k)),
                    const SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(
                            "ACTIVE",
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                          backgroundColor: Color(0xFFE8F5E9),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
