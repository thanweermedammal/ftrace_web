import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:go_router/go_router.dart';
import '../bloc/dishes_bloc.dart';
import '../data/dishes_repository.dart';
import '../model/dish_model.dart';

class DishesListPage extends StatefulWidget {
  const DishesListPage({super.key});

  @override
  State<DishesListPage> createState() => _DishesListPageState();
}

class _DishesListPageState extends State<DishesListPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedDishIds = {};
  late List<DishModel> _currentDishes;

  bool get _isAllSelected => _selectedDishIds.length == _currentDishes.length;
  bool get _isNoneSelected => _selectedDishIds.isEmpty;
  int get _selectedCount => _selectedDishIds.length;
  bool get _showDeleteButton => _selectedDishIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null; // indeterminate
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) => DishesBloc(DishesRepository())..add(LoadDishes()),
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
                "Dishes",
                style: TextStyle(color: Colors.black),
              ),
            )
          else
            const TopBar(title: "Dishes"),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<DishesBloc, DishesState>(
                builder: (context, state) {
                  if (state is DishesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DishesLoaded) {
                    _currentDishes = state.dishes;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP BAR
                        isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (v) {
                                      context.read<DishesBloc>().add(
                                        LoadDishes(query: v),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Search a dish...",
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.push('/dishform');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "NEW DISH",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (v) {
                                        context.read<DishesBloc>().add(
                                          LoadDishes(query: v),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search a dish...",
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/dishform');
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
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "NEW DISH",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

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
                                        ? 'Delete 1 Dish'
                                        : 'Delete $_selectedCount Dishes',
                                  ),
                                  onPressed: () => _onDeleteSelected(context),
                                ),
                              ],
                            ),
                          ),

                        // LIST CONTAINER
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildTableHeader(),
                              if (state.dishes.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text("No dishes found."),
                                  ),
                                )
                              else
                                ...state.dishes.map(
                                  (d) => _buildTableRow(context, d),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  if (state is DishesError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this dish?'
              : 'Are you sure you want to delete $_selectedCount dishes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final selectedModels = _currentDishes
                  .where((d) => _selectedDishIds.contains(d.id))
                  .toList();
              context.read<DishesBloc>().add(DeleteDishes(selectedModels));
              // Clear selection after delete? The BlocListener should probably handle this or we do it here optimistically.
              // Logic was here before, keeping it simple.
              setState(() {
                _selectedDishIds.clear(); // Optimistic clear
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Checkbox(
              activeColor: Colors.blue,
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedDishIds = _currentDishes.map((e) => e.id).toSet();
                  } else {
                    _selectedDishIds.clear();
                  }
                });
              },
            ),
          ),
          SizedBox(width: 60, child: Text("Image", style: primaryTextStyle)),
          Expanded(flex: 20, child: Text("Dish Name", style: primaryTextStyle)),
          Expanded(flex: 20, child: Text("Allergens", style: primaryTextStyle)),
          Expanded(flex: 30, child: Text("Recipes", style: primaryTextStyle)),
          Expanded(flex: 15, child: Text("Hotel", style: primaryTextStyle)),
          SizedBox(width: 80, child: Text("Actions", style: primaryTextStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, DishModel dish) {
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
          Expanded(
            flex: 5,
            child: Checkbox(
              activeColor: Colors.blue,
              value: _selectedDishIds.contains(dish.id),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedDishIds.add(dish.id);
                  } else {
                    _selectedDishIds.remove(dish.id);
                  }
                });
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: dish.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      dish.imageUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          Expanded(
            flex: 20,
            child: Text(
              dish.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              dish.allergens.join(", "),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 30,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ...dish.recipeItems
                    .take(2)
                    .map((item) => _recipeChip(item.productName)),
                if (dish.recipeItems.length > 2)
                  _recipeChip(
                    "+${dish.recipeItems.length - 2} more",
                    isMore: true,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              dish.hotelName,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
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
                    context.push('/dishdetail', extra: dish);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () {
                    context.push('/dishform', extra: dish);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipeChip(String label, {bool isMore = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMore ? Colors.transparent : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: isMore ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[800],
          fontWeight: isMore ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
