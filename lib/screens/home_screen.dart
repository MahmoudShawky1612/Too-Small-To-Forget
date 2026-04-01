import 'package:flutter/material.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/screens/add_memory_screen.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
import 'package:toosmalltoforget/widgets/memory_card.dart';

import 'home_screen_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late HomeScreenHelper _helper;

  @override
  void initState() {
    super.initState();
    _helper = HomeScreenHelper(
      dbHelper: _dbHelper,
      context: context,
      refresh: () => setState(() {}),
      // triggers rebuild when helper changes data
      categories: [],
      // will be replaced later by helper's loadCategories
      memories: [],
      // will be replaced later
      selectedCategoryId: null,
      searchQuery: '',
    );
    // Load initial data
    _helper.loadCategories();
    _helper.loadMemories();
  }

  // Called when adding a new memory from add screen
  Future<void> _onAddMemory(Memory newMemory) async {
    await _dbHelper.insertMemory(newMemory);
    // Refresh categories (in case a new category was created) and memories
    await _helper.loadCategories();
    _helper.loadMemories();
  }

  // Called when deleting a memory
  Future<void> _onDeleteMemory(Memory memory) async {
    await _dbHelper.deleteMemory(memory.id!);
    _helper.loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    // Use helper's data directly
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
              onChanged: _helper.onSearchChanged,
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
                    selected: _helper.selectedCategoryId == null,
                    onSelected: (_) => _helper.selectCategory(null),
                  ),
                  const SizedBox(width: 8),

                  // User categories
                  ..._helper.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: _helper.selectedCategoryId == category.id,
                        onSelected: (_) => _helper.selectCategory(category.id),
                      ),
                    );
                  }).toList(),

                  // Add category button (a chip with plus icon)
                  ActionChip(
                    label: const Icon(Icons.add, size: 18),
                    onPressed: _helper.addCategory,
                    backgroundColor: Colors.grey.shade800,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of memories
            Expanded(
              child: ListView.builder(
                itemCount: _helper.memories.length,
                itemBuilder: (context, index) {
                  final memory = _helper.memories[index];
                  return MemoryCard(
                    memory: memory,
                    categoryName: _helper.getCategoryName(memory.categoryId),
                    onDelete: () => _onDeleteMemory(memory),
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
              builder: (context) => AddMemoryScreen(onAdd: _onAddMemory),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
