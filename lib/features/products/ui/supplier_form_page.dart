import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/suppliers_bloc.dart';
import '../data/suppliers_repository.dart';
import '../model/supplier_model.dart';
import '../../hotels/data/hotel_repository.dart';
import '../../hotels/model/hotel_model.dart';

class SupplierFormPage extends StatefulWidget {
  final SupplierModel? supplier;
  const SupplierFormPage({super.key, this.supplier});

  @override
  State<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends State<SupplierFormPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _hotelId = '';
  String _hotelName = '';

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.name;
      _emailController.text = widget.supplier!.email;
      _phoneController.text = widget.supplier!.phone;
      _addressController.text = widget.supplier!.address;
      _hotelId = widget.supplier!.hotelId;
      _hotelName = widget.supplier!.hotelName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.supplier != null;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => SuppliersBloc(SuppliersRepository()),
      child: BlocListener<SuppliersBloc, SuppliersState>(
        listener: (context, state) {
          if (state is SuppliersSaved) context.pop();
          if (state is SuppliersError) {
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
                  "Supplier Form",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? "Edit Supplier" : "Add New Suppliers",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Hotel Dropdown
                          StreamBuilder<List<HotelModel>>(
                            stream: HotelRepository().getHotels(),
                            builder: (context, snapshot) {
                              final hotels = snapshot.data ?? [];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Select Hotel *",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF495057),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: const Text(
                                          "Select Hotel",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        value: _hotelId.isNotEmpty
                                            ? _hotelId
                                            : null,
                                        items: hotels.map((h) {
                                          return DropdownMenuItem(
                                            value: h.id,
                                            child: Text(h.name),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            final selectedHotel = hotels
                                                .firstWhere((h) => h.id == val);
                                            setState(() {
                                              _hotelId = val;
                                              _hotelName = selectedHotel.name;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          if (!isEditing) ...[
                            _label("Supplier Name(s) *"),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText:
                                    "Enter supplier names separated by commas (e.g., Supplier A, Supplier B, Supplier C)",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            if (isMobile && isEditing)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _labelField(
                                    "Supplier Name *",
                                    "Enter supplier name",
                                    _nameController,
                                  ),
                                  const SizedBox(height: 24),
                                  _labelField(
                                    "Email",
                                    "Enter email address",
                                    _emailController,
                                  ),
                                  const SizedBox(height: 24),
                                  _labelField(
                                    "Phone",
                                    "Enter phone number",
                                    _phoneController,
                                  ),
                                  const SizedBox(height: 24),
                                  _labelField(
                                    "Address",
                                    "Enter supplier address",
                                    _addressController,
                                    maxLines: 3,
                                  ),
                                ],
                              )
                            else if (isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _labelField(
                                      "Supplier Name *",
                                      "Enter supplier name",
                                      _nameController,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _labelField(
                                      "Email",
                                      "Enter email address",
                                      _emailController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _labelField(
                                      "Phone",
                                      "Enter phone number",
                                      _phoneController,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _labelField(
                                "Address",
                                "Enter supplier address",
                                _addressController,
                                maxLines: 3,
                              ),
                            ],
                          ],
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                flex: isMobile ? 1 : 0,
                                child: OutlinedButton(
                                  onPressed: () => context.pop(),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8F9FB),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 16 : 48,
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade100,
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: isMobile ? 1 : 0,
                                child: Builder(
                                  builder: (bCtx) => ElevatedButton(
                                    onPressed: () => _save(bCtx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 16 : 48,
                                        vertical: 20,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      isEditing ? "UPDATE" : "SAVE",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    final bool isRequired = text.contains("*");
    final label = isRequired ? text.replaceAll("*", "").trim() : text;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _labelField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  void _save(BuildContext context) {
    final input = _nameController.text.trim();
    if (input.isEmpty) return;
    if (_hotelId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a hotel")));
      return;
    }

    if (widget.supplier != null) {
      // EDIT
      final updated = SupplierModel(
        id: widget.supplier!.id,
        name: input,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        createdAt: widget.supplier!.createdAt,
        hotelId: _hotelId,
        hotelName: _hotelName,
      );
      context.read<SuppliersBloc>().add(UpdateSupplier(updated));
    } else {
      // BULK ADD
      final names = input.split(",").where((s) => s.trim().isNotEmpty).toList();
      context.read<SuppliersBloc>().add(
        AddSuppliers(names, _hotelId, _hotelName),
      );
    }
  }
}
