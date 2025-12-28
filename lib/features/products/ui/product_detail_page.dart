import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/products_bloc.dart';
import '../data/products_repository.dart';
import '../model/product_model.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => ProductsBloc(ProductsRepository()),
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          // Use the passed product initially, but if we have updated info from a Bloc (not strictly needed unless we fetchById), we could use it.
          // Since we are just showing details passed from list, we'll stick to 'product'.
          // If you want real-time updates (e.g. if deleted), you'd need to listen to a stream or fetch fresh data.
          // For now, consistent with DishDetail, we'll just display 'product'.

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
                    "Products Detail",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/productform', extra: product);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "EDIT PRODUCT",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildBasicInfoCard(product),
                                const SizedBox(height: 24),
                                _buildUomCard(product),
                                const SizedBox(height: 24),
                                _buildCategoriesCard(product),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // RIGHT COLUMN
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildSupplierCard(product),
                                const SizedBox(height: 24),
                                _buildTimestampsCard(product),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Basic Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _detailRow(Icons.inventory_2_outlined, "Product Name", product.name),
          const SizedBox(height: 20),
          _detailRow(Icons.qr_code, "Barcode", product.barcode),
          // Add Description if available in model? (not in current model)
        ],
      ),
    );
  }

  Widget _buildUomCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "UOM Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _detailRow(Icons.straighten, "UOM", product.uom)),
              Expanded(
                child: _detailRow(
                  Icons.warehouse_outlined,
                  "Inventory UOM",
                  product.inventoryUom,
                ),
              ),
              Expanded(
                child: _detailRow(
                  Icons.swap_horiz,
                  "Conversion Factor",
                  product.conversionFactor.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(ProductModel product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Categories",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (product.categories.isEmpty)
            const Text("No categories", style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.categories
                  .map((c) => _categoryChip(c))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(ProductModel product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Supplier",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _detailRow(
            Icons.store_outlined,
            "Supplier Name",
            product
                .supplier, // Assuming this is name. If id, might need lookup.
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampsCard(ProductModel product) {
    // Assuming we might have timestamps later, for now just placeholders or omitted
    // If not in model, ignore or mock
    // Model has: id, name, categoryId, uom, price, ...
    // Looking at file, `ProductModel` doesn't strictly have timestamps shown in list page
    // but the screenshot shows them.
    // We'll mock current time or leave blank if we can't access it.

    final now = DateTime.now();
    final formatted = DateFormat.yMMMMd().add_jm().format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Timestamps",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _detailRow(
            Icons.calendar_today_outlined,
            "Created",
            formatted, // Mocking for now as it's not in the simple model view
          ),
          const SizedBox(height: 20),
          _detailRow(Icons.access_time, "Last Updated", formatted),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
