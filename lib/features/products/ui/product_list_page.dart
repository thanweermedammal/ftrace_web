import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../bloc/products_bloc.dart';
import '../data/products_repository.dart';
import '../model/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ftrace_web/features/products/bloc/categories_bloc.dart';
import 'package:ftrace_web/features/products/bloc/suppliers_bloc.dart';
import 'package:ftrace_web/features/products/utils/products_excel_helper.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedProductIds = {};
  List<ProductModel>? _currentProducts;

  bool _showFilters = false;
  String? _selectedSupplier;
  String? _selectedUom;
  String? _selectedInventoryUom;
  String? _selectedCategory;

  bool get _isAllSelected =>
      _currentProducts != null &&
      _selectedProductIds.isNotEmpty &&
      _selectedProductIds.length == _currentProducts!.length;
  bool get _isNoneSelected => _selectedProductIds.isEmpty;
  int get _selectedCount => _selectedProductIds.length;
  bool get _showDeleteButton => _selectedProductIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        context.read<SuppliersBloc>().add(
          LoadSuppliers(currentUser: authState.user),
        );
        context.read<CategoriesBloc>().add(
          LoadCategories(currentUser: authState.user),
        );
        context.read<ProductsBloc>().add(
          LoadProducts(currentUser: authState.user),
        );
      }
    });
  }

  void _onFilterChanged() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;
    context.read<ProductsBloc>().add(
      LoadProducts(
        query: _searchController.text,
        supplier: _selectedSupplier,
        uom: _selectedUom,
        inventoryUom: _selectedInventoryUom,
        category: _selectedCategory,
        currentUser: user,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSupplier = null;
      _selectedUom = null;
      _selectedInventoryUom = null;
      _selectedCategory = null;
      _searchController.clear();
    });
    _onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthSuccess ? authState.user : null;

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
              "Products",
              style: TextStyle(color: Colors.black),
            ),
          )
        else
          const TopBar(title: "Products"),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading && _currentProducts == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductsError && _currentProducts == null) {
                    return Center(child: Text(state.message));
                  }

                  final products = state is ProductsLoaded
                      ? state.products
                      : _currentProducts ?? [];
                  _currentProducts = products;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state is ProductsLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      // 🔹 TOP ACTION BAR
                      isMobile
                          ? Column(
                              children: [
                                _searchBar(context),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            context.push('/productform'),
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          "ADD PRODUCT",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _actionButton(
                                        icon: _showFilters
                                            ? Icons.filter_list_off
                                            : Icons.filter_list,
                                        label: _showFilters
                                            ? "HIDE FILTERS"
                                            : "SHOW FILTERS",
                                        color: Colors.white,
                                        textColor: Colors.black87,
                                        border: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        onPressed: () => setState(
                                          () => _showFilters = !_showFilters,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _actionButton(
                                        icon: Icons.file_upload_outlined,
                                        label: "IMPORT",
                                        color: const Color(0xFFE8F5E9),
                                        textColor: const Color(0xFF2E7D32),
                                        onPressed: _importExcel,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _actionButton(
                                        icon: Icons.file_download_outlined,
                                        label: "EXPORT",
                                        color: const Color(0xFFE8F5E9),
                                        textColor: const Color(0xFF2E7D32),
                                        onPressed: _exportExcel,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _searchBar(context)),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => context.push('/productform'),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "ADD PRODUCT",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                ),
                                const SizedBox(width: 8),
                                _actionButton(
                                  icon: Icons.file_upload_outlined,
                                  label: "IMPORT",
                                  color: const Color(0xFFE8F5E9),
                                  textColor: const Color(0xFF2E7D32),
                                  onPressed: _importExcel,
                                ),
                                const SizedBox(width: 8),
                                _actionButton(
                                  icon: Icons.file_download_outlined,
                                  label: "EXPORT",
                                  color: const Color(0xFFE8F5E9),
                                  textColor: const Color(0xFF2E7D32),
                                  onPressed: _exportExcel,
                                ),
                                const SizedBox(width: 8),
                                _actionButton(
                                  icon: _showFilters
                                      ? Icons.filter_list_off
                                      : Icons.filter_list,
                                  label: _showFilters
                                      ? "HIDE FILTERS"
                                      : "SHOW FILTERS",
                                  color: Colors.white,
                                  textColor: Colors.black87,
                                  border: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                  onPressed: () => setState(
                                    () => _showFilters = !_showFilters,
                                  ),
                                ),
                              ],
                            ),

                      if (_showFilters) ...[
                        const SizedBox(height: 20),
                        _buildFilters(context),
                      ],

                      const SizedBox(height: 20),
                      if (_showDeleteButton)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: Text(
                                  _selectedCount == 1
                                      ? 'Delete 1 Product'
                                      : 'Delete $_selectedCount Products',
                                ),
                                onPressed: () => _onDeleteSelected(context),
                              ),
                            ],
                          ),
                        ),

                      // LIST CONTAINER
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(
                          0,
                        ), // Removed padding to let scroll work better
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildTable(context, products, isMobile),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _exportExcel() {
    if (_currentProducts == null || _currentProducts!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No products to export")));
      return;
    }

    final bytes = ProductsExcelHelper.generateExcel(_currentProducts!);
    if (bytes == null) return;

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "products_export_${DateTime.now().millisecondsSinceEpoch}.xlsx",
        )
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, we'd use path_provider and file_picker to save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Export currently supported on Web")),
      );
    }
  }

  void _importExcel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Import Products"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a file to import (.xlsx, .xls, .csv)",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _pickAndProcessFile();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Browse or Drag & Drop",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Accepted formats: Excel (.xlsx, .xls), CSV (.csv)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL"),
          ),
        ],
      ),
    );
  }

  void _pickAndProcessFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;
    final user = authState.user;

    // Show confirmation dialog before importing
    _showImportConfirmation(bytes, file.extension ?? '', user);
  }

  void _showImportConfirmation(Uint8List bytes, String ext, UserModel user) {
    try {
      List<ProductModel> products;
      // Parse initially with first hotel as default (we will update if needed)
      if (ext == 'csv') {
        products = ProductsExcelHelper.parseCsv(
          bytes,
          user.hotelIds.first,
          user.hotelNames.first,
        );
      } else {
        products = ProductsExcelHelper.parseExcel(
          bytes,
          user.hotelIds.first,
          user.hotelNames.first,
        );
      }

      int selectedHotelIndex = 0;

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Import ${products.length} Products"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.hotelIds.length > 1) ...[
                    const Text(
                      "Select Hotel for Import:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedHotelIndex,
                          items: List.generate(
                            user.hotelIds.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(user.hotelNames[index]),
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedHotelIndex = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    "Are you sure you want to import these products to ${user.hotelNames[selectedHotelIndex]}?",
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update products with selected hotel info
                    final selectedHotelId = user.hotelIds[selectedHotelIndex];
                    final selectedHotelName =
                        user.hotelNames[selectedHotelIndex];

                    final updatedProducts = products
                        .map(
                          (p) => p.copyWith(
                            hotelId: selectedHotelId,
                            hotelName: selectedHotelName,
                          ),
                        )
                        .toList();

                    context.read<ProductsBloc>().add(
                      BulkAddProducts(updatedProducts),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("IMPORT"),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Import Failed: ${e.toString()}")));
    }
  }

  void _onDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this product?'
              : 'Are you sure you want to delete $_selectedCount products?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final selectedModels = (_currentProducts ?? [])
                  .where((p) => _selectedProductIds.contains(p.id))
                  .toList();
              context.read<ProductsBloc>().add(DeleteProducts(selectedModels));

              setState(() {
                _selectedProductIds.clear();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (v) => _onFilterChanged(),
      decoration: InputDecoration(
        hintText: "Search products...",
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    List<ProductModel> products,
    bool isMobile,
  ) {
    if (products.isEmpty) {
      return const Center(child: Text("No products found."));
    }

    final tableContent = Column(
      children: [
        _buildTableHeader(isMobile),
        ...products.map((p) => _buildTableRow(context, p, isMobile)),
      ],
    );

    if (isMobile) {
      return tableContent;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: 1200, child: tableContent),
    );
  }

  Widget _buildTableHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              activeColor: Colors.blue,
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedProductIds = (_currentProducts ?? [])
                        .map((e) => e.id)
                        .toSet();
                  } else {
                    _selectedProductIds.clear();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text("Name", style: primaryTextStyle)),
          Expanded(flex: 2, child: Text("Barcode", style: primaryTextStyle)),
          if (!isMobile) ...[
            Expanded(flex: 1, child: Text("UOM", style: primaryTextStyle)),
            Expanded(flex: 1, child: Text("Qty", style: primaryTextStyle)),
            Expanded(
              flex: 2,
              child: Text("Inventory UOM", style: primaryTextStyle),
            ),
            Expanded(flex: 3, child: Text("Supplier", style: primaryTextStyle)),
            Expanded(
              flex: 3,
              child: Text("Categories", style: primaryTextStyle),
            ),
            Expanded(flex: 2, child: Text("Hotel", style: primaryTextStyle)),
          ],
          SizedBox(width: 80, child: Text("Actions", style: primaryTextStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ProductModel p, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              activeColor: Colors.blue,
              value: _selectedProductIds.contains(p.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedProductIds.add(p.id);
                  } else {
                    _selectedProductIds.remove(p.id);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              p.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(p.barcode, style: const TextStyle(fontSize: 13)),
          ),
          if (!isMobile) ...[
            Expanded(
              flex: 1,
              child: Text(p.uom, style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              flex: 1,
              child: Text(
                p.quantity.toString(),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(p.inventoryUom, style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              flex: 3,
              child: Text(p.supplier, style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              flex: 3,
              child: Wrap(
                spacing: 4,
                children: p.categories.map((c) => _categoryChip(c)).toList(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(p.hotelName, style: const TextStyle(fontSize: 13)),
            ),
          ],
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  onPressed: () {
                    context.push('/productdetail', extra: p);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () {
                    context.push('/productform', extra: p);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    BorderSide? border,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: border ?? BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final suppliers = context.watch<SuppliersBloc>().state is SuppliersLoaded
        ? (context.watch<SuppliersBloc>().state as SuppliersLoaded).suppliers
              .map((e) => e.name)
              .toList()
        : <String>[];
    final categories = context.watch<CategoriesBloc>().state is CategoriesLoaded
        ? (context.watch<CategoriesBloc>().state as CategoriesLoaded).categories
              .map((e) => e.name)
              .toList()
        : <String>[];
    final uoms = ProductModel.uomOptions;
    final invUoms = ProductModel.uomOptions;


    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: "Supplier",
                  value: _selectedSupplier,
                  items: suppliers,
                  onChanged: (v) => setState(() {
                    _selectedSupplier = v;
                    _onFilterChanged();
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: "UOM",
                  value: _selectedUom,
                  items: uoms,
                  onChanged: (v) => setState(() {
                    _selectedUom = v;
                    _onFilterChanged();
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  label: "Inventory UOM",
                  value: _selectedInventoryUom,
                  items: invUoms,
                  onChanged: (v) => setState(() {
                    _selectedInventoryUom = v;
                    _onFilterChanged();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: "Categories",
                  value: _selectedCategory,
                  items: categories,
                  onChanged: (v) => setState(() {
                    _selectedCategory = v;
                    _onFilterChanged();
                  }),
                ),
              ),
              const Spacer(flex: 2),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.close, size: 18),
                label: const Text("CLEAR FILTERS"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text("Select $label", style: const TextStyle(fontSize: 14)),
              value: value,
              items: [
                const DropdownMenuItem<String>(value: null, child: Text("All")),
                ...items.map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
