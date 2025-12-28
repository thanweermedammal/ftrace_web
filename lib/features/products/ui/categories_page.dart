import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/theme.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
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
  late List<CategoryModel> _currentCategories;

  bool get _isAllSelected =>
      _selectedCategoryIds.length == _currentCategories.length;
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
    final isMobile = width < 900;

    return BlocProvider(
      create: (context) =>
          CategoriesBloc(CategoriesRepository())..add(LoadCategories()),
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
                "Categories",
                style: TextStyle(color: Colors.black),
              ),
            )
          else
            const TopBar(title: "Categories"),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CategoriesLoaded) {
                      _currentCategories = state.categories;
                      return Column(
                        children: [
                          // TOP BAR
                          isMobile
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _searchController,
                                      onChanged: (v) {
                                        context.read<CategoriesBloc>().add(
                                          LoadCategories(query: v),
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search a category...",
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 0,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              context.push('/categoryform');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 20,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "NEW CATEGORY",
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
                                          context.read<CategoriesBloc>().add(
                                            LoadCategories(query: v),
                                          );
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Search a category...",
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                          ),
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
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 0,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.push('/categoryform');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "NEW CATEGORY",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 24),
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
                                          ? 'Delete 1 Category'
                                          : 'Delete $_selectedCount Categories',
                                    ),
                                    onPressed: () => _onDeleteSelected(context),
                                  ),
                                ],
                              ),
                            ),

                          // LIST CONTAINER
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildTable(context, state.categories),
                          ),
                        ],
                      );
                    }

                    if (state is CategoriesError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text("No categories found."));
                  },
                ),
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
              final selectedModels = _currentCategories
                  .where((c) => _selectedCategoryIds.contains(c.id))
                  .toList();
              context.read<CategoriesBloc>().add(
                DeleteCategories(selectedModels),
              );
              setState(() {
                _selectedCategoryIds.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<CategoryModel> categories) {
    return Column(
      children: [
        _buildTableHeader(),
        if (categories.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("No categories found."),
            ),
          )
        else
          ...categories.map((c) => _buildTableRow(context, c)),
      ],
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
            flex: 2,
            child: Checkbox(
              activeColor: Colors.blue,
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCategoryIds = _currentCategories
                        .map((e) => e.id)
                        .toSet();
                  } else {
                    _selectedCategoryIds.clear();
                  }
                });
              },
            ),
          ),
          Expanded(flex: 8, child: Text("Name", style: primaryTextStyle)),
          Expanded(flex: 5, child: Text("Hotel", style: primaryTextStyle)),
          Expanded(
            flex: 10,
            child: Text("Description", style: primaryTextStyle),
          ),
          SizedBox(width: 80, child: Text("Actions", style: primaryTextStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, CategoryModel category) {
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
            flex: 2,
            child: Checkbox(
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
          ),
          Expanded(flex: 8, child: Text(category.name)),
          Expanded(flex: 5, child: Text(category.hotelName)),
          Expanded(
            flex: 10,
            child: Text(
              category.description.isEmpty ? "-" : category.description,
              style: const TextStyle(color: Colors.grey),
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
                  icon: const Icon(Icons.edit_note, size: 24),
                  onPressed: () {
                    context.push('/categoryform', extra: category);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
