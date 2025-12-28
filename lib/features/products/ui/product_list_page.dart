import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/bloc/auth_state.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../bloc/products_bloc.dart';
import '../model/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ftrace_web/features/products/bloc/categories_bloc.dart';
import 'package:ftrace_web/features/products/bloc/suppliers_bloc.dart';
import 'package:ftrace_web/features/products/utils/products_excel_helper.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:ftrace_web/features/products/ui/widgets/product_filter_bar.dart';
import 'package:ftrace_web/features/products/ui/widgets/product_table.dart';

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

  int get _selectedCount => _selectedProductIds.length;
  bool get _showDeleteButton => _selectedProductIds.isNotEmpty;

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
    final isMobileNav = width < 900;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: isMobileNav
          ? AppBar(
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
          : null,
      body: Column(
        children: [
          if (!isMobileNav) const TopBar(title: "Products"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobileNav ? 12.0 : 24.0),
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
                  if (_currentProducts != products) {
                    _currentProducts = products;
                  }
                  _currentProducts = products;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state is ProductsLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      _buildTopActionBar(context, isMobile, isMobileNav),
                      if (_showFilters && !isMobile) ...[
                        const SizedBox(height: 20),
                        ProductFilterBar(
                          selectedSupplier: _selectedSupplier,
                          selectedUom: _selectedUom,
                          selectedInventoryUom: _selectedInventoryUom,
                          selectedCategory: _selectedCategory,
                          onChanged: (supplier, uom, invUom, cat) {
                            setState(() {
                              _selectedSupplier = supplier;
                              _selectedUom = uom;
                              _selectedInventoryUom = invUom;
                              _selectedCategory = cat;
                            });
                            _onFilterChanged();
                          },
                          onClear: _clearFilters,
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (_showDeleteButton) _buildDeleteBar(context),
                      Expanded(child: _buildTableContainer(products, isMobile)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionBar(
    BuildContext context,
    bool isMobile,
    bool isMobileNav,
  ) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _searchBar(context)),
              const SizedBox(width: 8),
              _actionButton(
                icon: Icons.add,
                label: "ADD PRODUCT",
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () => context.push('/productform'),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      );
    }

    return Row(
      children: [
        Expanded(child: _searchBar(context)),
        const SizedBox(width: 8),
        _actionButton(
          icon: Icons.add,
          label: "ADD PRODUCT",
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () => context.push('/productform'),
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
          icon: _showFilters ? Icons.filter_list_off : Icons.filter_list,
          label: _showFilters ? "HIDE FILTERS" : "SHOW FILTERS",
          color: Colors.white,
          textColor: Colors.black87,
          border: BorderSide(color: Colors.grey.shade300),
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
      ],
    );
  }

  Widget _buildDeleteBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }

  Widget _buildTableContainer(List<ProductModel> products, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ProductTable(
        products: products,
        selectedIds: _selectedProductIds,
        isMobile: isMobile,
        onSelectionChanged: (id, selected) {
          setState(() {
            if (selected) {
              _selectedProductIds.add(id);
            } else {
              _selectedProductIds.remove(id);
            }
          });
        },
        onSelectAll: (all) {
          setState(() {
            if (all) {
              _selectedProductIds = products.map((e) => e.id).toSet();
            } else {
              _selectedProductIds.clear();
            }
          });
        },
      ),
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
      html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "products_export_${DateTime.now().millisecondsSinceEpoch}.xlsx",
        )
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
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
          ],
        ),
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
    _showImportConfirmation(bytes, file.extension ?? '', authState.user);
  }

  void _showImportConfirmation(Uint8List bytes, String ext, UserModel user) {
    try {
      List<ProductModel> products = ext == 'csv'
          ? ProductsExcelHelper.parseCsv(
              bytes,
              user.hotelIds.first,
              user.hotelNames.first,
            )
          : ProductsExcelHelper.parseExcel(
              bytes,
              user.hotelIds.first,
              user.hotelNames.first,
            );
      int selectedIndex = 0;
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Import ${products.length} Products"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.hotelIds.length > 1)
                    DropdownButton<int>(
                      value: selectedIndex,
                      items: List.generate(
                        user.hotelIds.length,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(user.hotelNames[i]),
                        ),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => selectedIndex = v!),
                    ),
                  Text("Confirm import to ${user.hotelNames[selectedIndex]}?"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final finalProducts = products
                        .map(
                          (p) => p.copyWith(
                            hotelId: user.hotelIds[selectedIndex],
                            hotelName: user.hotelNames[selectedIndex],
                          ),
                        )
                        .toList();
                    context.read<ProductsBloc>().add(
                      BulkAddProducts(finalProducts),
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
      ).showSnackBar(SnackBar(content: Text("Import Failed: $e")));
    }
  }

  void _onDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete $_selectedCount products?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final selected = (_currentProducts ?? [])
                  .where((p) => _selectedProductIds.contains(p.id))
                  .toList();
              context.read<ProductsBloc>().add(DeleteProducts(selected));
              setState(() => _selectedProductIds.clear());
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
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: EdgeInsets.zero,
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
}
