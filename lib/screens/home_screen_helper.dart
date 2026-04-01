import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/memory.dart';
import '../services/database_helper.dart';

class HomeScreenHelper {
  final DatabaseHelper dbHelper;
  final BuildContext context;
  final VoidCallback refresh;

  List<Category> categories;
  List<Memory> memories;
  int? selectedCategoryId;
  String searchQuery;

  HomeScreenHelper({
    required this.dbHelper,
    required this.context,
    required this.refresh,
    required this.categories,
    required this.memories,
    required this.selectedCategoryId,
    required this.searchQuery,
  });
  final DatabaseHelper _dbHelper = DatabaseHelper();


  // Load categories from database
  Future<void> loadCategories() async {
    categories = await dbHelper.getAllCategories();
    refresh();
  }

  // Load memories based on current filters
  Future<void> loadMemories() async {
    memories = await dbHelper.getMemories(
      categoryId: selectedCategoryId,
      searchQuery: searchQuery.isEmpty ? null : searchQuery,
    );
    refresh();
  }

  // Called when search text changes
  void onSearchChanged(String query) {
    searchQuery = query;
    loadMemories();
  }

  // Called when a category chip is tapped
  void selectCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    refresh();
    loadMemories();
  }

  // Show dialog to add a new category
  Future<void> addCategory() async {
    String? newCategoryName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Category name',
          ),
          onChanged: (value) => newCategoryName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newCategoryName != null && newCategoryName!.isNotEmpty) {
                await dbHelper.insertCategory(
                  Category(name: newCategoryName!),
                );

                await loadCategories();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Helper to get category name from ID for display in MemoryCard
  String getCategoryName(int? categoryId) {
    if (categoryId == null) return '';
    final category = categories.firstWhere(
          (c) => c.id == categoryId,
      orElse: () => Category(name: ''),
    );
    return category.name;
  }

}