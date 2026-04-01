import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/models/category.dart';
import 'package:toosmalltoforget/services/database_helper.dart';

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
  DateTime _selectedDate = DateTime.now();
  DateTime? _reminderDate;
  Category? _selectedCategory;
  File? _selectedImage;
  List<Category> _categories = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories from DB for the dropdown
  Future<void> _loadCategories() async {
    final cats = await _dbHelper.getAllCategories();
    setState(() {
      _categories = cats;
    });
  }

  // Date picker for the memory date
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Reminder picker (date + time)
  Future<void> _selectReminder(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _reminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Show bottom sheet to choose image source (camera or gallery)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Actually pick image and save it to app's documents directory
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // Copy the image to the app's documents folder so it persists
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      final savedPath = '${appDir.path}/$fileName';
      final file = File(pickedFile.path);
      await file.copy(savedPath);
      setState(() {
        _selectedImage = File(savedPath);
      });
    }
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
                final insertedId = await _dbHelper.insertCategory(newCategory);
                // Reload categories and select the newly created one
                await _loadCategories();
                setState(() {
                  // Find the new category by name (or use insertedId)
                  _selectedCategory = _categories.firstWhere(
                        (c) => c.name == newCategoryName,
                    orElse: () => Category(name: ''),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Save the memory
  void _save() async {
    if (_formKey.currentState!.validate()) {
      final memory = Memory(
        title: _titleController.text,
        details: _detailsController.text,
        date: _selectedDate,
        categoryId: _selectedCategory?.id,
        reminder: _reminderDate,
        photoPath: _selectedImage?.path,
      );
      widget.onAdd(memory);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Memory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Details field
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_selectedDate.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Reminder picker
              ListTile(
                title: const Text('Reminder'),
                subtitle: Text(_reminderDate == null
                    ? 'None'
                    : _reminderDate!.toLocal().toString()),
                trailing: const Icon(Icons.alarm),
                onTap: () => _selectReminder(context),
              ),
              const SizedBox(height: 16),

              // Category dropdown with "Add New" option
              DropdownButtonFormField<Category>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem<Category>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._categories.map((cat) => DropdownMenuItem<Category>(
                    value: cat,
                    child: Text(cat.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add new category'),
              ),
              const SizedBox(height: 16),

              // Image picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Photo (optional)'),
                  const SizedBox(height: 8),
                  if (_selectedImage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
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