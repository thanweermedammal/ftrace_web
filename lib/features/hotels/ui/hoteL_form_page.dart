import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_event.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_state.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';

class HotelFormPage extends StatefulWidget {
  final HotelModel? hotel;
  const HotelFormPage({super.key, this.hotel});

  @override
  State<HotelFormPage> createState() => _HotelFormPageState();
}

class _HotelFormPageState extends State<HotelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String _status = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      final h = widget.hotel!;
      nameCtrl.text = h.name;
      emailCtrl.text = h.email;
      phoneCtrl.text = h.phone;
      addressCtrl.text = h.address;
      _status = h.status;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    final isEditing = widget.hotel != null;

    return BlocListener<HotelBloc, HotelState>(
      listener: (context, state) {
        if (state is HotelSaved) {
          Navigator.pop(context);
        } else if (state is HotelError) {
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
              title: Text(
                isEditing ? "Edit Hotel" : "Add Hotel",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEditing ? "Edit Hotel" : "Add New Hotel",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                controller: nameCtrl,
                                label: "Hotel Name",
                                validator: (v) => v?.isEmpty == true
                                    ? "Name is required"
                                    : null,
                              ),
                              // Only show other fields when editing
                              if (isEditing) ...[
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: emailCtrl,
                                  label: "Email (Optional)",
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: phoneCtrl,
                                  label: "Phone (Optional)",
                                ),
                              ],
                            ],
                          )
                        else ...[
                          _buildTextField(
                            controller: nameCtrl,
                            label: "Hotel Name",
                            validator: (v) =>
                                v?.isEmpty == true ? "Name is required" : null,
                          ),
                          // Only show email/phone when editing
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: _buildTextField(
                                      controller: emailCtrl,
                                      label: "Email (Optional)",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: _buildTextField(
                                      controller: phoneCtrl,
                                      label: "Phone (Optional)",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                        // Only show address when editing
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: addressCtrl,
                            label: "Address (Optional)",
                            maxLines: 3,
                          ),
                        ],
                        // Only show status when editing
                        if (isEditing) ...[
                          const SizedBox(height: 16),

                          // STATUS
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _status,
                                    isExpanded: true,
                                    items: ["ACTIVE", "INACTIVE"]
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _status = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),

                        // BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("CANCEL"),
                            ),
                            const SizedBox(width: 16),
                            BlocBuilder<HotelBloc, HotelState>(
                              builder: (context, state) {
                                if (state is HotelSaving) {
                                  return const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (isEditing) {
                                        // UPDATE
                                        context.read<HotelBloc>().add(
                                          UpdateHotel(
                                            widget.hotel!.copyWith(
                                              name: nameCtrl.text,
                                              email: emailCtrl.text,
                                              phone: phoneCtrl.text,
                                              address: addressCtrl.text,
                                              status: _status,
                                            ),
                                          ),
                                        );
                                      } else {
                                        // ADD
                                        context.read<HotelBloc>().add(
                                          AddHotel(name: nameCtrl.text),
                                        );
                                      }
                                    }
                                  },
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
                                    isEditing ? "UPDATE" : "SAVE HOTEL",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
