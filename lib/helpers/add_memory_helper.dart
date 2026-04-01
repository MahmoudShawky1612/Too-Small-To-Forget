import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';
import '../services/database_helper.dart';

class AddMemoryHelper {
  final DatabaseHelper dbHelper;
  final BuildContext context;
  final VoidCallback refresh;

  List<Category> categories;
  Category? selectedCategory;
  DateTime selectedDate;
  DateTime? reminderDate;
  File? selectedImage;

  AddMemoryHelper({
    required this.dbHelper,
    required this.context,
    required this.refresh,
    required this.categories,
    required this.selectedCategory,
    required this.selectedDate,
    required this.reminderDate,
    required this.selectedImage,
  });

  Future<void> loadCategories() async {
    categories = await dbHelper.getAllCategories();
    refresh();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate = picked;
      refresh();
    }
  }

  Future<void> selectReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        reminderDate ?? DateTime.now(),
      ),
    );

    if (pickedTime == null) return;

    reminderDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    refresh();
  }

  Future<void> pickImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';

    final file = File(pickedFile.path);
    await file.copy(savedPath);

    selectedImage = File(savedPath);
    refresh();
  }

  Future<void> addCategory() async {
    String? newCategoryName;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newCategoryName != null &&
                  newCategoryName!.trim().isNotEmpty) {
                await dbHelper.insertCategory(
                  Category(name: newCategoryName!.trim()),
                );

                await loadCategories();

                selectedCategory = categories.firstWhere(
                      (c) => c.name == newCategoryName!.trim(),
                  orElse: () => Category(name: ''),
                );

                refresh();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}