// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/kitchen_bloc.dart';
// import '../bloc/kitchen_event.dart';
// import '../bloc/kitchen_state.dart';
// import '../model/kitchen_model.dart';
// import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
// import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
// import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
// import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
//
// class KitchenFormPage extends StatefulWidget {
//   final String? hotelId;
//   final KitchenModel? kitchen;
//   const KitchenFormPage({super.key, this.hotelId, this.kitchen});
//
//   @override
//   State<KitchenFormPage> createState() => _KitchenFormPageState();
// }
//
// class _KitchenFormPageState extends State<KitchenFormPage> {
//   late TextEditingController _nameController;
//   String? _selectedHotelId;
//   String? _selectedHotelName;
//   String _status = 'Active';
//   List<String> _selectedStorages = [];
//
//   final List<String> _storageOptions = [
//     'Chilled Storage',
//     'Frozen Storage',
//     'Dry Storage',
//     'Ambient Storage',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.kitchen?.name ?? '');
//     _selectedHotelId = widget.hotelId ?? widget.kitchen?.hotelId;
//     _selectedHotelName = widget.kitchen?.hotelName;
//     _status = widget.kitchen?.status ?? 'Active';
//     _selectedStorages = widget.kitchen?.storages ?? [];
//
//     context.read<HotelBloc>().add(LoadHotels());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final isMobile = width < 900;
//
//     return Column(
//       children: [
//         if (isMobile)
//           AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0.5,
//             leading: Builder(
//               builder: (context) => IconButton(
//                 icon: const Icon(Icons.menu, color: Colors.black),
//                 onPressed: () => Scaffold.of(context).openDrawer(),
//               ),
//             ),
//             title: const Text(
//               "Kitchen Form",
//               style: TextStyle(color: Colors.black, fontSize: 18),
//             ),
//           ),
//         Expanded(
//           child: BlocListener<KitchenBloc, KitchenState>(
//             listener: (context, state) {
//               if (state is KitchenSaved) {
//                 Navigator.pop(context);
//               }
//             },
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.all(32),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.kitchen == null
//                           ? "Add New Kitchen"
//                           : "Edit Kitchen",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     if (isMobile)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _label("Select Hotel", required: true),
//                           BlocBuilder<HotelBloc, HotelState>(
//                             builder: (context, state) {
//                               List<HotelModel> hotels = [];
//                               if (state is HotelLoaded) {
//                                 hotels = state.hotels;
//                               }
//                               return DropdownButtonFormField<String>(
//                                 isExpanded: true,
//                                 value: _selectedHotelId,
//                                 hint: const Text("Select Select Hotel"),
//                                 decoration: _inputDecoration(),
//                                 items: hotels
//                                     .map(
//                                       (h) => DropdownMenuItem(
//                                         value: h.id,
//                                         child: Text(h.name),
//                                       ),
//                                     )
//                                     .toList(),
//                                 onChanged: (v) {
//                                   setState(() {
//                                     _selectedHotelId = v;
//                                     _selectedHotelName = hotels
//                                         .firstWhere((h) => h.id == v)
//                                         .name;
//                                   });
//                                 },
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 24),
//                           _label("Kitchen Name", required: true),
//                           TextField(
//                             controller: _nameController,
//                             decoration: _inputDecoration(
//                               hint: "Enter kitchen name",
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           _label("Assign Storages"),
//                           DropdownButtonFormField<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               _selectedStorages.isEmpty
//                                   ? "Select Assign Storages"
//                                   : _selectedStorages.join(", "),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             decoration: _inputDecoration(),
//                             items: _storageOptions
//                                 .map(
//                                   (s) => DropdownMenuItem(
//                                     value: s,
//                                     child: Row(
//                                       children: [
//                                         Checkbox(
//                                           value: _selectedStorages.contains(s),
//                                           onChanged: (v) {
//                                             setState(() {
//                                               if (v!) {
//                                                 _selectedStorages.add(s);
//                                               } else {
//                                                 _selectedStorages.remove(s);
//                                               }
//                                             });
//                                           },
//                                         ),
//                                         Text(s),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (v) {},
//                           ),
//                           const SizedBox(height: 24),
//                           _label("Status", required: true),
//                           DropdownButtonFormField<String>(
//                             isExpanded: true,
//                             value: _status,
//                             decoration: _inputDecoration(),
//                             items: ['Active', 'Inactive']
//                                 .map(
//                                   (s) => DropdownMenuItem(
//                                     value: s,
//                                     child: Text(s),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (v) => setState(() => _status = v!),
//                           ),
//                         ],
//                       )
//                     else
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // LEFT COLUMN
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("Select Hotel", required: true),
//                                 BlocBuilder<HotelBloc, HotelState>(
//                                   builder: (context, state) {
//                                     List<HotelModel> hotels = [];
//                                     if (state is HotelLoaded) {
//                                       hotels = state.hotels;
//                                     }
//                                     return DropdownButtonFormField<String>(
//                                       isExpanded: true,
//                                       value: _selectedHotelId,
//                                       hint: const Text("Select Select Hotel"),
//                                       decoration: _inputDecoration(),
//                                       items: hotels
//                                           .map(
//                                             (h) => DropdownMenuItem(
//                                               value: h.id,
//                                               child: Text(h.name),
//                                             ),
//                                           )
//                                           .toList(),
//                                       onChanged: (v) {
//                                         setState(() {
//                                           _selectedHotelId = v;
//                                           _selectedHotelName = hotels
//                                               .firstWhere((h) => h.id == v)
//                                               .name;
//                                         });
//                                       },
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(height: 24),
//                                 _label("Status", required: true),
//                                 DropdownButtonFormField<String>(
//                                   isExpanded: true,
//                                   value: _status,
//                                   decoration: _inputDecoration(),
//                                   items: ['Active', 'Inactive']
//                                       .map(
//                                         (s) => DropdownMenuItem(
//                                           value: s,
//                                           child: Text(s),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (v) =>
//                                       setState(() => _status = v!),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 32),
//                           // RIGHT COLUMN
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _label("Kitchen Name", required: true),
//                                 TextField(
//                                   controller: _nameController,
//                                   decoration: _inputDecoration(
//                                     hint: "Enter kitchen name",
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 _label("Assign Storages"),
//                                 DropdownButtonFormField<String>(
//                                   isExpanded: true,
//                                   hint: Text(
//                                     _selectedStorages.isEmpty
//                                         ? "Select Assign Storages"
//                                         : _selectedStorages.join(", "),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   decoration: _inputDecoration(),
//                                   items: _storageOptions
//                                       .map(
//                                         (s) => DropdownMenuItem(
//                                           value: s,
//                                           child: Row(
//                                             children: [
//                                               Checkbox(
//                                                 value: _selectedStorages
//                                                     .contains(s),
//                                                 onChanged: (v) {
//                                                   setState(() {
//                                                     if (v!) {
//                                                       _selectedStorages.add(s);
//                                                     } else {
//                                                       _selectedStorages.remove(
//                                                         s,
//                                                       );
//                                                     }
//                                                   });
//                                                 },
//                                               ),
//                                               Text(s),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (v) {},
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 48),
//                     Row(
//                       children: [
//                         OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 32,
//                               vertical: 20,
//                             ),
//                             backgroundColor: Colors.grey.shade100,
//                             side: BorderSide.none,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             "CANCEL",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             if (_selectedHotelId != null &&
//                                 _nameController.text.isNotEmpty) {
//                               if (widget.kitchen == null) {
//                                 context.read<KitchenBloc>().add(
//                                   AddKitchen(
//                                     hotelId: _selectedHotelId!,
//                                     hotelName: _selectedHotelName ?? '',
//                                     name: _nameController.text,
//                                     status: _status,
//                                     storages: _selectedStorages,
//                                   ),
//                                 );
//                               } else {
//                                 context.read<KitchenBloc>().add(
//                                   UpdateKitchen(
//                                     widget.kitchen!.copyWith(
//                                       hotelId: _selectedHotelId!,
//                                       hotelName: _selectedHotelName ?? '',
//                                       name: _nameController.text,
//                                       status: _status,
//                                       storages: _selectedStorages,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 48,
//                               vertical: 20,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             "SAVE",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _label(String text, {bool required = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: RichText(
//         text: TextSpan(
//           text: text,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//             fontSize: 13,
//           ),
//           children: [
//             if (required)
//               const TextSpan(
//                 text: " *",
//                 style: TextStyle(color: Colors.red),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration({String? hint}) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/kitchen_bloc.dart';
import '../bloc/kitchen_event.dart';
import '../bloc/kitchen_state.dart';
import '../model/kitchen_model.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';

class KitchenFormPage extends StatefulWidget {
  final String? hotelId;
  final KitchenModel? kitchen;

  const KitchenFormPage({super.key, this.hotelId, this.kitchen});

  @override
  State<KitchenFormPage> createState() => _KitchenFormPageState();
}

class _KitchenFormPageState extends State<KitchenFormPage> {
  late TextEditingController _nameController;

  String? _selectedHotelId;
  String _status = 'ACTIVE';
  List<String> _selectedStorages = [];

  final List<String> _storageOptions = [
    'Chilled Storage',
    'Frozen Storage',
    'Dry Storage',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.kitchen?.name ?? '');
    _selectedHotelId = widget.kitchen?.hotelId ?? widget.hotelId;
    _status = widget.kitchen?.status ?? 'ACTIVE';
    _selectedStorages = List.from(widget.kitchen?.storages ?? []);

    context.read<HotelBloc>().add(LoadHotels());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Column(
      children: [
        if (isMobile)
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text(
              "Kitchen Form",
              style: TextStyle(color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),

        Expanded(
          child: BlocListener<KitchenBloc, KitchenState>(
            listener: (context, state) {
              if (state is KitchenSaved) {
                Navigator.pop(context);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kitchen == null
                          ? "Add New Kitchen"
                          : "Edit Kitchen",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),

                    isMobile ? _mobileForm() : _desktopForm(),

                    const SizedBox(height: 48),
                    _actionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- MOBILE ----------------
  Widget _mobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hotelDropdown(),
        const SizedBox(height: 24),
        _kitchenNameField(),
        const SizedBox(height: 24),
        _storageSelector(),
        const SizedBox(height: 24),
        _statusDropdown(),
      ],
    );
  }

  // ---------------- DESKTOP ----------------
  Widget _desktopForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _hotelDropdown(),
              const SizedBox(height: 24),
              _statusDropdown(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kitchenNameField(),
              const SizedBox(height: 24),
              _storageSelector(),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- FIELDS ----------------

  Widget _hotelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Select Hotel", required: true),

        /// 👉 ADD MODE → SHOW TEXT FIELD
        if (widget.kitchen != null)
          TextField(
            readOnly: true, // or false if you want manual entry
            controller: TextEditingController(
              text: widget.kitchen?.hotelName ?? "",
            ),
            decoration: _inputDecoration(hint: "Select hotel from list"),
          )
        /// 👉 EDIT MODE → SHOW DROPDOWN
        else
          BlocBuilder<HotelBloc, HotelState>(
            builder: (context, state) {
              final hotels = state is HotelLoaded
                  ? state.hotels
                  : <HotelModel>[];

              // ✅ IMPORTANT FIX
              final validHotelIds = hotels.map((h) => h.id).toSet();
              final dropdownValue = validHotelIds.contains(_selectedHotelId)
                  ? _selectedHotelId
                  : null;

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: dropdownValue, // 👈 SAFE VALUE
                hint: const Text("Select Hotel"),
                decoration: _inputDecoration(),
                items: hotels
                    .map(
                      (h) => DropdownMenuItem<String>(
                        value: h.id,
                        child: Text(h.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedHotelId = v;
                  });
                },
              );
            },
          ),
      ],
    );
  }

  Widget _kitchenNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Kitchen Name", required: true),
        TextField(
          controller: _nameController,
          decoration: _inputDecoration(hint: "Enter kitchen name"),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Status", required: true),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: _inputDecoration(),
          items: [
            'ACTIVE',
            'INACTIVE',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
      ],
    );
  }

  // ---------------- STORAGE MULTI SELECT ----------------

  Widget _storageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Assign Storages"),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _storageOptions.map((s) {
            final selected = _selectedStorages.contains(s);
            return FilterChip(
              label: Text(s),
              selected: selected,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _selectedStorages.add(s);
                  } else {
                    _selectedStorages.remove(s);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------- ACTION BUTTONS ----------------

  Widget _actionButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("CANCEL"),
        ),
        const SizedBox(width: 16),
        BlocBuilder<KitchenBloc, KitchenState>(
          builder: (context, state) {
            if (state is KitchenSaving) {
              return const SizedBox(
                width: 48, // Match standard button height approx
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.kitchen == null ? "SAVE" : "UPDATE",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------- SAVE LOGIC ----------------

  void _onSave() {
    if (_selectedHotelId == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hotelState = context.read<HotelBloc>().state;
    String hotelName = '';

    if (hotelState is HotelLoaded) {
      hotelName = hotelState.hotels
          .firstWhere((h) => h.id == _selectedHotelId)
          .name;
    }

    if (widget.kitchen == null) {
      context.read<KitchenBloc>().add(
        AddKitchen(
          hotelId: _selectedHotelId!,
          hotelName: hotelName,
          name: _nameController.text,
          status: _status,
          storages: _selectedStorages,
        ),
      );
    } else {
      context.read<KitchenBloc>().add(
        UpdateKitchen(
          widget.kitchen!.copyWith(
            hotelId: _selectedHotelId!,
            hotelName: hotelName,
            name: _nameController.text,
            status: _status,
            storages: _selectedStorages,
          ),
        ),
      );
    }
  }

  // ---------------- UI HELPERS ----------------

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (required)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
