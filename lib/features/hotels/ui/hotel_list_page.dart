import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/data/hotel_repository.dart';
import 'package:ftrace_web/features/hotels/ui/hoteL_form_page.dart';
const double colName = 220;
const double colEmail = 260;
const double colPhone = 140;
const double colKitchen = 240;
const double colStatus = 120;
const double colAction = 90;
class HotelListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    context.read<HotelBloc>().add(LoadHotels());

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      drawer: isMobile ? const Drawer(child: Sidebar()) : null,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: isMobile
            ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : null,
        title: const Text("Hotels", style: TextStyle(color: Colors.black)),
      ),

      body: Row(
        children: [
          if (!isMobile) const Sidebar(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<HotelBloc, HotelState>(
                builder: (context, state) {
                  if (state is HotelLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HotelLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 SEARCH + ADD
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search hotels...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HotelFormPage()),
                                );
                              },
                              child: const Text("ADD HOTEL"),
                            ),
                            const Spacer(),
                            OutlinedButton(
                                onPressed: () {},
                                child: const Text("Active")),
                            const SizedBox(width: 8),
                            OutlinedButton(
                                onPressed: () {},
                                child: const Text("Inactive")),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 📋 TABLE
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _tableHeader(isMobile),
                              ...state.hotels.map((hotel) {
                                return _tableRow(context, hotel);
                              }),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text("Error"));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _tableHeader(isMobile) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child:  Row(
        children: [
          SizedBox(width: 200, child: Text("Name")),
          Expanded(child: Text("Email")),
          SizedBox(width: 120, child: Text("Phone")),
          if(!isMobile)
          SizedBox(width: 200, child: Text("Kitchens")),
          SizedBox(width: 120, child: Text("Status")),
          SizedBox(width: 80, child: Text("Actions")),
        ],
      ),
    );
  }

  // ---------- ROW ----------
  Widget _tableRow(BuildContext context, hotel) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAEAEA)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NAME
          SizedBox(
            width: colName,
            child: Text(
              hotel.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // EMAIL
          SizedBox(
            width: colEmail,
            child: Text(
              hotel.email,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // PHONE
          SizedBox(
            width: colPhone,
            child: Text(hotel.phone),
          ),

          // KITCHENS
          SizedBox(
            width: colKitchen,
            child: Builder(
              builder: (_) {
                final kitchens = hotel.kitchens;

                if (kitchens.isEmpty) {
                  return const Text("-");
                }

                final visible = kitchens.take(2).toList();
                final extra = kitchens.length - visible.length;

                return Row(
                  children: [
                    ...visible.map(
                          (k) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(k),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    if (extra > 0)
                      Chip(
                        label: Text("+$extra"),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                );
              },
            ),
          ),



          // STATUS
          SizedBox(
            width: colStatus,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  hotel.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.green.shade100,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // ACTIONS
          SizedBox(
            width: colAction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.visibility, size: 18),
                SizedBox(width: 14),
                Icon(Icons.edit, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
