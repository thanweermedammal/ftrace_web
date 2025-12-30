import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';
import '../data/products_repository.dart';
import '../data/categories_repository.dart';
import '../data/suppliers_repository.dart';
import '../model/product_model.dart';
import '../model/category_model.dart';
import '../model/supplier_model.dart';
import '../../hotels/data/hotel_repository.dart';
import '../../hotels/model/hotel_model.dart';
import '../../../../core/widgets/multi_select_dropdown.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _description = TextEditingController();
  final _factor = TextEditingController(text: '1.0');
  String _uom = '';
  String _invUom = '';
  String _status = 'ACTIVE';
  String _supplier = '';
  List<String> _categories = [];
  String _hotelId = '';
  String _hotelName = '';

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name.text = widget.product!.name;
      _barcode.text = widget.product!.barcode;
      _description.text = widget.product!.description;
      _factor.text = widget.product!.conversionFactor.toString();
      _uom = widget.product!.uom;
      _invUom = widget.product!.inventoryUom;
      _status = widget.product!.status;
      _supplier = widget.product!.supplier;
      _categories = List.from(widget.product!.categories);
      _hotelId = widget.product!.hotelId;
      _hotelName = widget.product!.hotelName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => ProductsBloc(ProductsRepository()),
      child: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductSaved) context.pop();
          if (state is ProductsError) {
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
                  "Product Form",
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Add New Product",
                            style: TextStyle(
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

                          if (isMobile) ...[
                            _labelTextField(
                              "Product Name *",
                              "Enter product name",
                              _name,
                            ),
                            const SizedBox(height: 24),
                            _labelTextField(
                              "Barcode",
                              "Enter barcode (optional)",
                              _barcode,
                            ),
                            const SizedBox(height: 24),
                            _labelTextField(
                              "Description",
                              "Enter product description (optional)",
                              _description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            _labelDropdown(
                              "UOM *",
                              "Select UOM",
                              _uom,
                              _uomOptions,
                              (v) => setState(() => _uom = v!),
                            ),
                            const SizedBox(height: 24),
                            _labelDropdown(
                              "Inventory UOM *",
                              "Select Inventory UOM",
                              _invUom,
                              _uomOptions,
                              (v) => setState(() => _invUom = v!),
                            ),
                            const SizedBox(height: 24),
                            _labelTextField(
                              "Conversion Factor *",
                              "1.0",
                              _factor,
                            ),
                            const SizedBox(height: 24),
                            _labelDropdown(
                              "Status",
                              "ACTIVE",
                              _status,
                              _statusOptions,
                              (v) => setState(() => _status = v!),
                            ),
                            const SizedBox(height: 24),
                            StreamBuilder<List<SupplierModel>>(
                              stream: _hotelId.isNotEmpty
                                  ? SuppliersRepository().fetchSuppliers(
                                      _hotelId,
                                    )
                                  : Stream.value([]),
                              builder: (context, snapshot) {
                                final suppliers =
                                    snapshot.data
                                        ?.map((e) => e.name)
                                        .toList() ??
                                    [];
                                return _labelDropdown(
                                  "Supplier *",
                                  "Select Supplier",
                                  _supplier,
                                  suppliers,
                                  (v) => setState(() => _supplier = v!),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            StreamBuilder<List<CategoryModel>>(
                              stream: _hotelId.isNotEmpty
                                  ? CategoriesRepository().fetchCategories(
                                      _hotelId,
                                    )
                                  : Stream.value([]),
                              builder: (context, snapshot) {
                                final categoriesList = snapshot.data ?? [];
                                return _categoryPickerField(
                                  context,
                                  categoriesList,
                                );
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _labelTextField(
                                    "Product Name *",
                                    "Enter product name",
                                    _name,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _labelTextField(
                                    "Barcode",
                                    "Enter barcode (optional)",
                                    _barcode,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _labelTextField(
                              "Description",
                              "Enter product description (optional)",
                              _description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _labelDropdown(
                                    "UOM *",
                                    "Select UOM",
                                    _uom,
                                    _uomOptions,
                                    (v) => setState(() => _uom = v!),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _labelDropdown(
                                    "Inventory UOM *",
                                    "Select Inventory UOM",
                                    _invUom,
                                    _uomOptions,
                                    (v) => setState(() => _invUom = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _labelTextField(
                                    "Conversion Factor *",
                                    "1.0",
                                    _factor,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _labelDropdown(
                                    "Status",
                                    "ACTIVE",
                                    _status,
                                    _statusOptions,
                                    (v) => setState(() => _status = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: StreamBuilder<List<SupplierModel>>(
                                    stream: _hotelId.isNotEmpty
                                        ? SuppliersRepository().fetchSuppliers(
                                            _hotelId,
                                          )
                                        : Stream.value([]),
                                    builder: (context, snapshot) {
                                      final suppliers =
                                          snapshot.data
                                              ?.map((e) => e.name)
                                              .toList() ??
                                          [];
                                      return _labelDropdown(
                                        "Supplier *",
                                        "Select Supplier",
                                        _supplier,
                                        suppliers,
                                        (v) => setState(() => _supplier = v!),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: StreamBuilder<List<CategoryModel>>(
                                    stream: _hotelId.isNotEmpty
                                        ? CategoriesRepository()
                                              .fetchCategories(_hotelId)
                                        : Stream.value([]),
                                    builder: (context, snapshot) {
                                      final categoriesList =
                                          snapshot.data ?? [];
                                      return _categoryPickerField(
                                        context,
                                        categoriesList,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          flex: isMobile ? 1 : 0,
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 48,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("CANCEL"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: isMobile ? 1 : 0,
                          child: BlocBuilder<ProductsBloc, ProductsState>(
                            builder: (context, state) {
                              if (state is ProductsSaving) {
                                return const SizedBox(
                                  height: 48,
                                  width: 48,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return ElevatedButton(
                                onPressed: () => _save(context),
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
                        ),
                      ],
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

  // ... (keep _labelTextField, _labelDropdown, _uomOptions, _statusOptions, _showCategoryPicker, _categoryPickerField) ... Do not delete them. Wait, I should keep them as is and only replace build and init.
  // Actually, standardizing by replacing entire class content is cleaner if I copy correctly.
  Widget _labelTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
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

  Widget _labelDropdown(
    String label,
    String hint,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              value: value.isEmpty ? null : value,
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  final List<String> _uomOptions = ProductModel.uomOptions;
  final List<String> _statusOptions = ['ACTIVE', 'INACTIVE'];

  Widget _categoryPickerField(
    BuildContext context,
    List<CategoryModel> categoriesList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        MultiSelectDropdown<CategoryModel>(
          hint: "Select Categories",
          items: categoriesList,
          selectedIds: _categories,
          labelMapper: (c) => c.name,
          idMapper: (c) => c.name, // Using name as ID as per existing logic
          onChanged: (newIds, newItems) {
            setState(() {
              _categories = newIds;
            });
          },
        ),
      ],
    );
  }

  void _save(BuildContext context) {
    if (_name.text.isEmpty) return;
    if (_hotelId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a hotel")));
      return;
    }

    final p = ProductModel(
      id: widget.product?.id ?? '',
      name: _name.text,
      barcode: _barcode.text,
      description: _description.text,
      uom: _uom,
      inventoryUom: _invUom,
      conversionFactor: double.tryParse(_factor.text) ?? 1.0,
      status: _status,
      supplier: _supplier,
      categories: _categories,
      hotelId: _hotelId,
      hotelName: _hotelName,
    );

    if (widget.product == null) {
      context.read<ProductsBloc>().add(AddProduct(p));
    } else {
      context.read<ProductsBloc>().add(UpdateProduct(p));
    }
  }
}
