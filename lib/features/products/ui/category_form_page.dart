import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/categories_bloc.dart';
import '../data/categories_repository.dart';
import '../model/category_model.dart';
import '../../hotels/data/hotel_repository.dart';
import '../../hotels/model/hotel_model.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoryModel? category;
  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _hotelId = '';
  String _hotelName = '';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _hotelId = widget.category!.hotelId;
      _hotelName = widget.category!.hotelName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.category != null;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => CategoriesBloc(CategoriesRepository()),
      child: BlocListener<CategoriesBloc, CategoriesState>(
        listener: (context, state) {
          if (state is CategoriesSaved) context.pop();
          if (state is CategoriesError) {
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
                  "Category Form",
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
                            isEditing ? "Edit Category" : "Add New Categories",
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
                                  // Reusing the style from ProductFormPage for consistency
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

                          if (isMobile && isEditing)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Category Name *"),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: "Enter category name",
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
                                const SizedBox(height: 24),
                                _label("Description"),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: "Enter description (optional)",
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
                              ],
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _label(
                                        isEditing
                                            ? "Category Name *"
                                            : "Category Name(s) *",
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          hintText: isEditing
                                              ? "Enter category name"
                                              : "Enter category names separated by commas (e.g., Cat A, Cat B, Cat C)",
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF8F9FB),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isEditing) ...[
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _label("Description"),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _descriptionController,
                                          decoration: InputDecoration(
                                            hintText:
                                                "Enter description (optional)",
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF8F9FB),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
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

  void _save(BuildContext context) {
    final input = _nameController.text.trim();
    if (input.isEmpty) return;
    if (_hotelId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a hotel")));
      return;
    }

    if (widget.category != null) {
      // EDIT
      final updated = CategoryModel(
        id: widget.category!.id,
        name: input,
        description: _descriptionController.text.trim(),
        createdAt: widget.category!.createdAt,
        hotelId: _hotelId,
        hotelName: _hotelName,
      );
      context.read<CategoriesBloc>().add(UpdateCategory(updated));
    } else {
      // BULK ADD
      final names = input.split(",").where((s) => s.trim().isNotEmpty).toList();
      context.read<CategoriesBloc>().add(
        AddCategories(names, _hotelId, _hotelName),
      );
    }
  }
}
