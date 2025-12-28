import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
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
  List<DishModel>? _currentDishes;

  bool get _isAllSelected =>
      _currentDishes != null &&
      _currentDishes!.isNotEmpty &&
      _selectedDishIds.length == _currentDishes!.length;
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
    final isMobileNav = width < 900;
    final isMobile = width < 600;

    return BlocProvider(
      create: (context) => DishesBloc(DishesRepository())..add(LoadDishes()),
      child: Column(
        children: [
          if (isMobileNav)
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24.0),
              child: BlocBuilder<DishesBloc, DishesState>(
                builder: (context, state) {
                  if (state is DishesLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is DishesLoaded) {
                    _currentDishes = state.dishes;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionBar(isMobileNav, isMobile),
                        const SizedBox(height: 20),
                        if (_showDeleteButton) _buildDeleteBar(),
                        _buildTable(state.dishes, isMobile),
                      ],
                    );
                  }
                  if (state is DishesError)
                    return Center(child: Text(state.message));
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isMobileNav, bool isMobile) {
    if (isMobile) {
      return Row(
        children: [
          Expanded(child: _buildSearchField()),
          const SizedBox(width: 8),
          _buildAddButton(isIconOnly: false),
        ],
      );
    }
    if (isMobileNav) {
      return Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _buildAddButton())]),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 16),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Builder(
      builder: (context) => TextField(
        controller: _searchController,
        onChanged: (v) => context.read<DishesBloc>().add(LoadDishes(query: v)),
        decoration: InputDecoration(
          hintText: "Search a dish...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
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
      ),
    );
  }

  Widget _buildAddButton({bool isIconOnly = false}) {
    if (isIconOnly) {
      return ElevatedButton(
        onPressed: () => context.push('/dishform'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => context.push('/dishform'),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "NEW DISH",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteBar() {
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
                  ? 'Delete 1 Dish'
                  : 'Delete $_selectedCount Dishes',
            ),
            onPressed: () => _onDeleteSelected(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<DishModel> dishes, bool isMobile) {
    final columns = [
      const TableColumnConfig(
        title: "Image",
        key: "image",
        flex: 0,
        minWidth: 60,
      ),
      const TableColumnConfig(
        title: "Dish Name",
        key: "name",
        flex: 3,
        minWidth: 200,
      ),
      const TableColumnConfig(
        title: "Allergens",
        key: "allergens",
        flex: 2,
        minWidth: 150,
      ),
      if (!isMobile) ...[
        const TableColumnConfig(
          title: "Recipes",
          key: "recipes",
          flex: 3,
          minWidth: 250,
        ),
        const TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          flex: 2,
          minWidth: 150,
        ),
      ],
      const TableColumnConfig(
        title: "Actions",
        key: "actions",
        flex: 1,
        minWidth: 100,
      ),
    ];

    return Expanded(
      child: ResponsiveTable<DishModel>(
        columns: columns,
        items: dishes,
        headerCheckboxValue: _headerCheckboxValue,
        onHeaderCheckboxChanged: () {
          setState(() {
            if (_isAllSelected) {
              _selectedDishIds.clear();
            } else {
              _selectedDishIds = dishes.map((e) => e.id).toSet();
            }
          });
        },
        leadingWidgetBuilder: (context, dish) => Checkbox(
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
        cellBuilder: (context, dish, key) {
          switch (key) {
            case 'image':
              return dish.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        dish.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey);
            case 'name':
              return Text(
                dish.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              );
            case 'allergens':
              return Text(
                dish.allergens.join(", "),
                style: const TextStyle(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              );
            case 'recipes':
              return Wrap(
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
              );
            case 'hotel':
              return Text(
                dish.hotelName,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              );
            case 'actions':
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => context.push('/dishdetail', extra: dish),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () => context.push('/dishform', extra: dish),
                  ),
                ],
              );
            default:
              return const SizedBox.shrink();
          }
        },
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
              if (_currentDishes == null) return;
              final selectedModels = _currentDishes!
                  .where((d) => _selectedDishIds.contains(d.id))
                  .toList();
              context.read<DishesBloc>().add(DeleteDishes(selectedModels));
              setState(() => _selectedDishIds.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
