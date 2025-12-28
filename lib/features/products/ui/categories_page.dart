import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/core/widgets/responsive_table.dart';
import 'package:go_router/go_router.dart';
import '../bloc/categories_bloc.dart';
import '../data/categories_repository.dart';
import '../model/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedCategoryIds = {};
  List<CategoryModel>? _currentCategories;

  bool get _isAllSelected =>
      _currentCategories != null &&
      _currentCategories!.isNotEmpty &&
      _selectedCategoryIds.length == _currentCategories!.length;
  bool get _isNoneSelected => _selectedCategoryIds.isEmpty;
  int get _selectedCount => _selectedCategoryIds.length;
  bool get _showDeleteButton => _selectedCategoryIds.isNotEmpty;

  bool? get _headerCheckboxValue {
    if (_isNoneSelected) return false;
    if (_isAllSelected) return true;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobileNav = width < 900;
    final isMobile = width < 600;

    return BlocProvider(
      create: (context) =>
          CategoriesBloc(CategoriesRepository())..add(LoadCategories()),
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
                "Categories",
                style: TextStyle(color: Colors.black),
              ),
            )
          else
            const TopBar(title: "Categories"),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24.0),
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is CategoriesLoaded) {
                    _currentCategories = state.categories;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionBar(isMobileNav, isMobile),
                        const SizedBox(height: 24),
                        if (_showDeleteButton) _buildDeleteBar(),
                        _buildTable(state.categories, isMobile),
                      ],
                    );
                  }
                  if (state is CategoriesError)
                    return Center(child: Text(state.message));
                  return const Center(child: Text("No categories found."));
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
        onChanged: (v) =>
            context.read<CategoriesBloc>().add(LoadCategories(query: v)),
        decoration: InputDecoration(
          hintText: "Search a category...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
        onPressed: () => context.push('/categoryform'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => context.push('/categoryform'),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "NEW CATEGORY",
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
                  ? 'Delete 1 Category'
                  : 'Delete $_selectedCount Categories',
            ),
            onPressed: () => _onDeleteSelected(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<CategoryModel> categories, bool isMobile) {
    final columns = [
      const TableColumnConfig(
        title: "Name",
        key: "name",
        flex: 3,
        minWidth: 200,
      ),
      if (!isMobile) ...[
        const TableColumnConfig(
          title: "Hotel",
          key: "hotel",
          flex: 2,
          minWidth: 150,
        ),
        const TableColumnConfig(
          title: "Description",
          key: "description",
          flex: 4,
          minWidth: 300,
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
      child: ResponsiveTable<CategoryModel>(
        columns: columns,
        items: categories,
        headerCheckboxValue: _headerCheckboxValue,
        onHeaderCheckboxChanged: () {
          setState(() {
            if (_isAllSelected) {
              _selectedCategoryIds.clear();
            } else {
              _selectedCategoryIds = categories.map((e) => e.id).toSet();
            }
          });
        },
        leadingWidgetBuilder: (context, category) => Checkbox(
          activeColor: Colors.blue,
          value: _selectedCategoryIds.contains(category.id),
          onChanged: (checked) {
            setState(() {
              if (checked == true) {
                _selectedCategoryIds.add(category.id);
              } else {
                _selectedCategoryIds.remove(category.id);
              }
            });
          },
        ),
        cellBuilder: (context, category, key) {
          switch (key) {
            case 'name':
              return Text(category.name, overflow: TextOverflow.ellipsis);
            case 'hotel':
              return Text(category.hotelName, overflow: TextOverflow.ellipsis);
            case 'description':
              return Text(
                category.description.isEmpty ? "-" : category.description,
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              );
            case 'actions':
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    onPressed: () =>
                        context.push('/categoryform', extra: category),
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

  void _onDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          _selectedCount == 1
              ? 'Are you sure you want to delete this category?'
              : 'Are you sure you want to delete $_selectedCount categories?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (_currentCategories == null) return;
              final selectedModels = _currentCategories!
                  .where((c) => _selectedCategoryIds.contains(c.id))
                  .toList();
              context.read<CategoriesBloc>().add(
                DeleteCategories(selectedModels),
              );
              setState(() => _selectedCategoryIds.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
