import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_event.dart';
import 'package:ftrace_web/features/users/bloc/users_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/kitchen/bloc/kitchen_bloc.dart';
import 'package:ftrace_web/features/kitchen/bloc/kitchen_event.dart';
import 'package:ftrace_web/features/kitchen/bloc/kitchen_state.dart';
import 'package:ftrace_web/features/kitchen/model/kitchen_model.dart';
import 'package:ftrace_web/core/widgets/multi_select_dropdown.dart';

class UserFormPage extends StatefulWidget {
  final UserModel? user;
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _password;
  late TextEditingController _confirmPassword;
  late TextEditingController _address;

  String _role = 'Hotel Admin';
  String _status = 'Active';
  List<String> _selectedHotelIds = [];
  List<String> _selectedHotelNames = [];
  List<String> _selectedKitchenIds = [];

  final List<String> _roleOptions = [
    'HO Admin',
    'Regional Officer',
    'Safety Officer',
    'Chef',
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.name ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _phone = TextEditingController(text: widget.user?.phone ?? '');
    _password = TextEditingController(text: widget.user?.password ?? '');
    _confirmPassword = TextEditingController(text: widget.user?.password ?? '');
    _address = TextEditingController(text: widget.user?.address ?? '');
    _role = widget.user?.role ?? 'Chef';
    _status = widget.user?.status ?? 'Active';
    _selectedHotelIds = widget.user?.hotelIds ?? [];
    _selectedHotelNames = widget.user?.hotelNames ?? [];
    _selectedKitchenIds = widget.user?.kitchenIds ?? [];

    context.read<HotelBloc>().add(LoadHotels());
    context.read<KitchenBloc>().add(
      LoadKitchens(hotelId: ''),
    ); // Fetch all kitchens
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserSaved) {
          context.pop();
        } else if (state is UserError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
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
                "User Form",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user == null ? "Add New User" : "Edit User",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Full Name", required: true),
                          _inputField(_name, "Enter full name"),
                          const SizedBox(height: 20),
                          _label("Role", required: true),
                          DropdownButtonFormField<String>(
                            value: _roleOptions.contains(_role)
                                ? _role
                                : _roleOptions.last,
                            decoration: _inputDecoration(),
                            items: _roleOptions
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _role = v!),
                          ),
                          const SizedBox(height: 20),
                          _label("Email Address", required: true),
                          _inputField(_email, "Enter email address"),
                          const SizedBox(height: 20),
                          _label("Phone Number", required: true),
                          _inputField(_phone, "Enter phone number"),
                          const SizedBox(height: 20),
                          _label("Password", required: widget.user == null),
                          _inputField(
                            _password,
                            "Enter password",
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          _label(
                            "Confirm Password",
                            required: widget.user == null,
                          ),
                          _inputField(
                            _confirmPassword,
                            "Confirm password",
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),
                          _label("Assign Hotels"),
                          BlocBuilder<HotelBloc, HotelState>(
                            builder: (context, state) {
                              List<HotelModel> hotels = [];
                              if (state is HotelLoaded) hotels = state.hotels;
                              return _multiSelectField<HotelModel>(
                                hint: _selectedHotelNames.isEmpty
                                    ? "Select Hotels"
                                    : _selectedHotelNames.join(", "),
                                items: hotels,
                                selectedIds: _selectedHotelIds,
                                labelMapper: (h) => h.name,
                                idMapper: (h) => h.id,
                                onChanged: (newIds, newItems) {
                                  setState(() {
                                    _selectedHotelIds = newIds;
                                    _selectedHotelNames = newItems
                                        .map((h) => h.name)
                                        .toList();
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _label("Assign Kitchens"),
                          BlocBuilder<KitchenBloc, KitchenState>(
                            builder: (context, state) {
                              List<KitchenModel> kitchens = [];
                              if (state is KitchenLoaded)
                                kitchens = state.kitchens;
                              return _multiSelectField<KitchenModel>(
                                hint: _selectedKitchenIds.isEmpty
                                    ? "Select Kitchens"
                                    : "${_selectedKitchenIds.length} kitchens selected",
                                items: kitchens,
                                selectedIds: _selectedKitchenIds,
                                labelMapper: (k) => k.name,
                                idMapper: (k) => k.id,
                                onChanged: (newIds, newItems) {
                                  setState(() {
                                    _selectedKitchenIds = newIds;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _label("Address"),
                          _inputField(_address, "Enter address", maxLines: 3),
                          const SizedBox(height: 20),
                          _label("Status", required: true),
                          DropdownButtonFormField<String>(
                            value: _status,
                            decoration: _inputDecoration(),
                            items: ['Active', 'Inactive']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Full Name", required: true),
                                _inputField(_name, "Enter full name"),
                                const SizedBox(height: 20),
                                _label("Email Address", required: true),
                                _inputField(_email, "Enter email address"),
                                const SizedBox(height: 20),
                                _label(
                                  "Password",
                                  required: widget.user == null,
                                ),
                                _inputField(
                                  _password,
                                  "Enter password",
                                  isPassword: true,
                                ),
                                const SizedBox(height: 20),
                                _label("Assign Hotels"),
                                BlocBuilder<HotelBloc, HotelState>(
                                  builder: (context, state) {
                                    List<HotelModel> hotels = [];
                                    if (state is HotelLoaded)
                                      hotels = state.hotels;
                                    return _multiSelectField<HotelModel>(
                                      hint: _selectedHotelNames.isEmpty
                                          ? "Select Hotels"
                                          : _selectedHotelNames.join(", "),
                                      items: hotels,
                                      selectedIds: _selectedHotelIds,
                                      labelMapper: (h) => h.name,
                                      idMapper: (h) => h.id,
                                      onChanged: (newIds, newItems) {
                                        setState(() {
                                          _selectedHotelIds = newIds;
                                          _selectedHotelNames = newItems
                                              .map((h) => h.name)
                                              .toList();
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                _label("Address"),
                                _inputField(
                                  _address,
                                  "Enter address",
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // RIGHT COLUMN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Role", required: true),
                                DropdownButtonFormField<String>(
                                  value: _roleOptions.contains(_role)
                                      ? _role
                                      : _roleOptions.last,
                                  decoration: _inputDecoration(),
                                  items: _roleOptions
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _role = v!),
                                ),
                                const SizedBox(height: 20),
                                _label("Phone Number", required: true),
                                _inputField(_phone, "Enter phone number"),
                                const SizedBox(height: 20),
                                _label(
                                  "Confirm Password",
                                  required: widget.user == null,
                                ),
                                _inputField(
                                  _confirmPassword,
                                  "Confirm password",
                                  isPassword: true,
                                ),
                                const SizedBox(height: 20),
                                _label("Assign Kitchens"),
                                BlocBuilder<KitchenBloc, KitchenState>(
                                  builder: (context, state) {
                                    List<KitchenModel> kitchens = [];
                                    if (state is KitchenLoaded)
                                      kitchens = state.kitchens;
                                    return _multiSelectField<KitchenModel>(
                                      hint: _selectedKitchenIds.isEmpty
                                          ? "Select Kitchens"
                                          : "${_selectedKitchenIds.length} kitchens selected",
                                      items: kitchens,
                                      selectedIds: _selectedKitchenIds,
                                      labelMapper: (k) => k.name,
                                      idMapper: (k) => k.id,
                                      onChanged: (newIds, newItems) {
                                        setState(() {
                                          _selectedKitchenIds = newIds;
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                _label("Status", required: true),
                                DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: _inputDecoration(),
                                  items: ['Active', 'Inactive']
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _status = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            if (state is UserSaving) {
                              return const SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "SAVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 13,
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

  Widget _inputField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _multiSelectField<T>({
    required String hint,
    required List<T> items,
    required List<String> selectedIds,
    required String Function(T) labelMapper,
    required String Function(T) idMapper,
    required void Function(List<String>, List<T>) onChanged,
  }) {
    return MultiSelectDropdown<T>(
      hint: hint,
      items: items,
      selectedIds: selectedIds,
      labelMapper: labelMapper,
      idMapper: idMapper,
      onChanged: onChanged,
    );
  }

  void _save() {
    if (_name.text.isEmpty || _email.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final user = UserModel(
      id: widget.user?.id ?? '',
      name: _name.text,
      email: _email.text,
      role: _role,
      phone: _phone.text,
      status: _status,
      hotelIds: _selectedHotelIds,
      hotelNames: _selectedHotelNames,
      kitchenIds: _selectedKitchenIds,
      address: _address.text,
      password: _password.text,
    );

    if (widget.user != null) {
      context.read<UserBloc>().add(UpdateUser(user));
    } else {
      context.read<UserBloc>().add(AddUser(user));
    }
  }
}
