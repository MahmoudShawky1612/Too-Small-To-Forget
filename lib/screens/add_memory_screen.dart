import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toosmalltoforget/models/category.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/services/database_helper.dart';

import '../helpers/add_memory_helper.dart';

class AddMemoryScreen extends StatefulWidget {
  final Function(Memory) onAdd;

  const AddMemoryScreen({super.key, required this.onAdd});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  DateTime? _reminderDate;
  File? _selectedImage;

  late AddMemoryHelper helper;

  @override
  void initState() {
    super.initState();

    helper = AddMemoryHelper(
      dbHelper: _dbHelper,
      context: context,
      refresh: () {
        setState(() {
          _categories = helper.categories;
          _selectedCategory = helper.selectedCategory;
          _selectedDate = helper.selectedDate;
          _reminderDate = helper.reminderDate;
          _selectedImage = helper.selectedImage;
        });
      },
      categories: _categories,
      selectedCategory: _selectedCategory,
      selectedDate: _selectedDate,
      reminderDate: _reminderDate,
      selectedImage: _selectedImage,
    );

    helper.loadCategories();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final memory = Memory(
      title: _titleController.text.trim(),
      details: _detailsController.text.trim(),
      date: _selectedDate,
      categoryId: _selectedCategory?.id,
      reminder: _reminderDate,
      photoPath: _selectedImage?.path,
    );

    widget.onAdd(memory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Memory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  _selectedDate.toLocal().toString().split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: helper.selectDate,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Reminder'),
                subtitle: Text(
                  _reminderDate == null
                      ? 'None'
                      : _reminderDate.toString(),
                ),
                trailing: const Icon(Icons.alarm),
                onTap: helper.selectReminder,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category?>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem<Category?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._categories.map(
                        (cat) => DropdownMenuItem<Category?>(
                      value: cat,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    helper.selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: helper.addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add new category'),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Photo (optional)'),
                  const SizedBox(height: 8),
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: helper.pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Pick Image'),
                      ),
                      if (_selectedImage != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;

                            });
                          },
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Memory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}