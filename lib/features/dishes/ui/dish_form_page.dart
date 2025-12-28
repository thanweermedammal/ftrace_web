import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dishes_bloc.dart';
import '../data/dishes_repository.dart';
import '../model/dish_model.dart';
import '../../hotels/data/hotel_repository.dart';
import '../../hotels/model/hotel_model.dart';
import '../../products/data/products_repository.dart';
import '../../products/model/product_model.dart';

class DishFormPage extends StatefulWidget {
  final DishModel? dish;
  const DishFormPage({super.key, this.dish});

  @override
  State<DishFormPage> createState() => _DishFormPageState();
}

class _DishFormPageState extends State<DishFormPage> {
  final _name = TextEditingController();
  final _allergens = TextEditingController();
  List<RecipeItem> _recipeItems = [];
  List<String> _preCookedIds = [];
  String _hotelId = '';
  String _hotelName = '';

  @override
  void initState() {
    super.initState();
    if (widget.dish != null) {
      _name.text = widget.dish!.name;
      _allergens.text = widget.dish!.allergens.join(", ");
      _recipeItems = List.from(widget.dish!.recipeItems);
      _preCookedIds = List.from(widget.dish!.preCookedItemIds);
      _hotelId = widget.dish!.hotelId;
      _hotelName = widget.dish!.hotelName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => DishesBloc(DishesRepository()),
      child: BlocListener<DishesBloc, DishesState>(
        listener: (context, state) {
          if (state is DishSaved) {
            context.pop();
          }
          if (state is DishesError) {
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
                  widget.dish == null ? "Add New Dish" : "Edit Dish",
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dish Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                      color: Colors.grey,
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
                                        hint: const Text("Select Hotel"),
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
                                              if (_hotelId != val) {
                                                _hotelId = val;
                                                _hotelName = selectedHotel.name;
                                                // Clear dependent data on hotel change
                                                _recipeItems.clear();
                                                _preCookedIds.clear();
                                              }
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

                          // 🔹 DATA STREAMS (Products & Dishes) dependent on Hotel
                          StreamBuilder<List<ProductModel>>(
                            stream: _hotelId.isNotEmpty
                                ? ProductsRepository().fetchProducts(_hotelId)
                                : Stream.value([]),
                            builder: (context, prodSnap) {
                              if (prodSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final products = prodSnap.data ?? [];

                              return StreamBuilder<List<DishModel>>(
                                stream: _hotelId.isNotEmpty
                                    ? DishesRepository().fetchDishes(_hotelId)
                                    : Stream.value([]),
                                builder: (context, dishSnap) {
                                  if (dishSnap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final allDishes = dishSnap.data ?? [];
                                  // Exclude current dish from pre-cooked options (recursion check)
                                  final availableDishes = widget.dish == null
                                      ? allDishes
                                      : allDishes
                                            .where(
                                              (d) => d.id != widget.dish!.id,
                                            )
                                            .toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isMobile) ...[
                                        _labelTextField(
                                          "Dish Name",
                                          "Enter dish name",
                                          _name,
                                        ),
                                        const SizedBox(height: 24),
                                        _labelTextField(
                                          "Allergens",
                                          "Enter allergens (comma separated)",
                                          _allergens,
                                        ),
                                      ] else
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _labelTextField(
                                                "Dish Name",
                                                "Enter dish name",
                                                _name,
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              child: _labelTextField(
                                                "Allergens",
                                                "Enter allergens (comma separated)",
                                                _allergens,
                                              ),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        "Dish Image",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _imageUploadPlaceholder(),
                                      const SizedBox(height: 32),
                                      // PRE-COOKED ITEMS
                                      const Text(
                                        "Pre Cooked items",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FB),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Text(
                                              "Select Pre Cooked items",
                                            ),
                                            items:
                                                availableDishes
                                                    .where(
                                                      (d) => !_preCookedIds
                                                          .contains(d.id),
                                                    )
                                                    .isEmpty
                                                ? [
                                                    const DropdownMenuItem(
                                                      value: null,
                                                      enabled: false,
                                                      child: Text(
                                                        "No pre-cooked items",
                                                      ),
                                                    ),
                                                  ]
                                                : availableDishes
                                                      .where(
                                                        (d) => !_preCookedIds
                                                            .contains(d.id),
                                                      )
                                                      .map((d) {
                                                        return DropdownMenuItem(
                                                          value: d.id,
                                                          child: Text(d.name),
                                                        );
                                                      })
                                                      .toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _preCookedIds.add(val);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: _preCookedIds.map((id) {
                                          final d = allDishes.firstWhere(
                                            (element) => element.id == id,
                                            orElse: () => DishModel(
                                              id: '',
                                              name: 'Unknown',
                                              allergens: [],
                                              imageUrl: '',
                                              recipeItems: [],
                                              preCookedItemIds: [],
                                            ),
                                          );
                                          return Chip(
                                            label: Text(d.name),
                                            onDeleted: () {
                                              setState(() {
                                                _preCookedIds.remove(id);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 24),

                                      const Text(
                                        "Recipe Items",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton.icon(
                                          onPressed: _addRecipeItem,
                                          icon: const Icon(
                                            Icons.add,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          label: const Text(
                                            "ADD ITEM +",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Each product can only be used once in a recipe",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _recipeItems.isEmpty
                                          ? _emptyRecipePlaceholder()
                                          : _recipeItemsTable(products),
                                    ], // Column children
                                  ); // Column
                                }, // Dish StreamBuilder
                              ); // Dish StreamBuilder
                            }, // Product StreamBuilder
                          ), // Product StreamBuilder
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
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
                              Builder(
                                builder: (bCtx) => ElevatedButton(
                                  onPressed: () => _save(bCtx),
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
                                  child: Text(
                                    widget.dish == null ? "SAVE" : "UPDATE",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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

  Widget _labelTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageUploadPlaceholder() {
    return Container(
      width: 250,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.none,
        ), // Should be dashed if possible
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          const Text(
            "Drop your image here,",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "or browse",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const Text(
            "Supports JPEG, PNG, and WebP (max 5MB)",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _emptyRecipePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Text(
            "No recipe items added yet.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          Text(
            "Click \"Add Item\" to start building your recipe.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _recipeItemsTable(List<ProductModel> products) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(50),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(2),
          3: FixedColumnWidth(90),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "#",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "PRODUCT",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "QUANTITY",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "ACTION",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          ..._recipeItems.asMap().entries.map((entry) {
            int idx = entry.key;
            RecipeItem item = entry.value;

            // Filter products: Show all that are NOT in recipeItems, OR the one currently selected in this row
            final rowAvailableProducts = products.where((p) {
              final isUsed = _recipeItems.any((r) => r.productId == p.id);
              return !isUsed || p.id == item.productId;
            }).toList();

            return TableRow(
              decoration: BoxDecoration(
                border: idx < _recipeItems.length - 1
                    ? const Border(
                        bottom: BorderSide(color: Colors.white, width: 2),
                      )
                    : null,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    (idx + 1).toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            (item.productId.isNotEmpty &&
                                rowAvailableProducts.any(
                                  (p) => p.id == item.productId,
                                ))
                            ? item.productId
                            : null,
                        hint: const Text("Select Product"),
                        items: rowAvailableProducts
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final p = products.firstWhere(
                            (element) => element.id == val,
                          );
                          setState(() {
                            _recipeItems[idx] = RecipeItem(
                              productId: p.id,
                              productName: p.name,
                              quantity: item.quantity,
                              unit: p.uom, // Use product UOM
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (v) => _recipeItems[idx] = RecipeItem(
                      productId: item.productId,
                      productName: item.productName,
                      quantity: double.tryParse(v) ?? 0,
                      unit: item.unit,
                    ),
                    controller: TextEditingController(
                      text: item.quantity.toString(),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      suffixText: item.unit, // Show Unit
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => setState(() => _recipeItems.removeAt(idx)),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _addRecipeItem() {
    setState(() {
      _recipeItems.add(
        RecipeItem(productId: '', productName: '', quantity: 0, unit: 'GRM'),
      );
    });
  }

  void _save(BuildContext context) {
    if (_name.text.isEmpty) return;
    if (_hotelId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a hotel")));
      return;
    }

    final dish = DishModel(
      id: widget.dish?.id ?? '',
      name: _name.text,
      allergens: _allergens.text.split(',').map((e) => e.trim()).toList(),
      imageUrl: '', // For now
      recipeItems: _recipeItems,
      preCookedItemIds: _preCookedIds,
      hotelId: _hotelId,
      hotelName: _hotelName,
    );

    if (widget.dish == null) {
      context.read<DishesBloc>().add(AddDish(dish));
    } else {
      context.read<DishesBloc>().add(UpdateDish(dish));
    }
  }
}
