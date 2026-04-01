import 'package:flutter/material.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/models/category.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
import 'package:toosmalltoforget/screens/add_memory_screen.dart';
import 'package:toosmalltoforget/widgets/memory_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Memory> _memories = [];
  List<Category> _categories = [];
  int? _selectedCategoryId; // null = All
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories(); // load categories first
    _loadMemories();   // then load memories
  }

  // Load categories from database
  Future<void> _loadCategories() async {
    final cats = await _dbHelper.getAllCategories();
    setState(() {
      _categories = cats;
    });
  }

  // Load memories based on current filters
  Future<void> _loadMemories() async {
    final memories = await _dbHelper.getMemories(
      categoryId: _selectedCategoryId,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
    setState(() {
      _memories = memories;
    });
  }

  // Called when search text changes
  void _onSearchChanged(String query) {
    _searchQuery = query;
    _loadMemories();
  }

  // Called when a category chip is tapped
  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadMemories();
  }

  // Show dialog to add a new category
  Future<void> _addCategory() async {
    String? newCategoryName;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
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
                final newCategory = Category(name: newCategoryName!);
                await _dbHelper.insertCategory(newCategory);
                await _loadCategories(); // refresh chips
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
  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return '';
    final category = _categories.firstWhere(
          (c) => c.id == categoryId,
      orElse: () => Category(name: ''),
    );
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Too Small To Forget'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search memories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),

            // Category chips row with horizontal scroll and add button
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // "All" chip
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) => _selectCategory(null),
                  ),
                  const SizedBox(width: 8),

                  // User categories
                  ..._categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (_) => _selectCategory(category.id),
                      ),
                    );
                  }).toList(),

                  // Add category button (a chip with plus icon)
                  ActionChip(
                    label: const Icon(Icons.add, size: 18),
                    onPressed: _addCategory,
                    backgroundColor: Colors.grey.shade800,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of memories
            Expanded(
              child: ListView.builder(
                itemCount: _memories.length,
                itemBuilder: (context, index) {
                  final memory = _memories[index];
                  // Pass the memory and its category name to MemoryCard
                  return MemoryCard(
                    memory: memory,
                    categoryName: _getCategoryName(memory.categoryId),
                    onDelete: () async {
                      await _dbHelper.deleteMemory(memory.id!);
                      _loadMemories(); // refresh list
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMemoryScreen(
                onAdd: (newMemory) async {
                  await _dbHelper.insertMemory(newMemory);
                  // After adding, we should reload categories and memories
                  // because the new memory might have a new category or new photo.
                  await _loadCategories(); // in case a new category was created in Add screen
                  _loadMemories();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}