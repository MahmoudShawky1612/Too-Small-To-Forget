// lib/screens/add_memory_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toosmalltoforget/models/category.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
import 'package:toosmalltoforget/helpers/add_memory_helper.dart';
import 'package:toosmalltoforget/theme/app_colors.dart';

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
      refresh: () => setState(_syncFromHelper),
      categories: _categories,
      selectedCategory: _selectedCategory,
      selectedDate: _selectedDate,
      reminderDate: _reminderDate,
      selectedImage: _selectedImage,
    );
    helper.loadCategories();
  }

  /// Helper mutates its own fields; the screen's state must mirror them for UI & save.
  void _syncFromHelper() {
    _reminderDate = helper.reminderDate;
    _selectedDate = helper.selectedDate;
    _categories = helper.categories;
    _selectedCategory = helper.selectedCategory;
    _selectedImage = helper.selectedImage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
            children: [
               _buildSectionLabel('Title'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _titleController,
                hint: 'What happened?',
                maxLines: 1,
                validator: (v) => v?.trim().isEmpty == true ? 'Please add a title' : null,
              ),
              SizedBox(height: 22.h),

               _buildSectionLabel('Details'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _detailsController,
                hint: 'Tell the full story…',
                maxLines: 5,
              ),
              SizedBox(height: 26.h),

               _buildSectionLabel('When'),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTappableTile(
                      label: 'Date',
                      value: _formatDate(_selectedDate),
                      icon: Icons.calendar_today_rounded,
                      onTap: helper.selectDate,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTappableTile(
                      label: 'Reminder',
                      value: _reminderDate == null
                          ? 'None'
                          : _formatReminder(_reminderDate!),
                      icon: Icons.alarm_rounded,
                      onTap: helper.selectReminder,
                      hasValue: _reminderDate != null,
                    ),
                  ),
                ],
              ),
              if (_reminderDate != null) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: helper.clearReminder,
                    child: Text(
                      'Remove reminder',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 26.h),

               _buildSectionLabel('Category'),
              SizedBox(height: 8.h),
              _buildCategoryDropdown(),
              SizedBox(height: 8.h),
              _buildAddCategoryButton(),
              SizedBox(height: 26.h),

               _buildSectionLabel('Photo'),
              SizedBox(height: 8.h),
              _buildPhotoSection(),
              SizedBox(height: 36.h),

               _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(Icons.arrow_back_rounded, color: AppColors.textMid, size: 18.sp),
        ),
      ),
      title: Text(
        'New Memory',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
    );
  }


  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textLight, fontSize: 15.sp, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
      ),
      validator: validator,
    );
  }


  Widget _buildTappableTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool hasValue = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w500),
                ),
                Icon(icon, size: 14.sp, color: hasValue ? AppColors.primary : AppColors.textMuted),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                color: hasValue ? AppColors.textLight : AppColors.textMuted,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category?>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.surfaceElevated,
          style: TextStyle(color: AppColors.textLight, fontSize: 15.sp),
          iconEnabledColor: AppColors.primary,
          hint: Text('None', style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp)),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('None', style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp)),
            ),
            ..._categories.map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat.name, style: TextStyle(color: AppColors.textLight, fontSize: 15.sp)),
            )),
          ],
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: helper.addCategory,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            'Add new category',
            style: TextStyle(color: AppColors.primary, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }


  Widget _buildPhotoSection() {
    return Column(
      children: [
        if (_selectedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              children: [
                Image.file(
                  _selectedImage!,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        GestureDetector(
          onTap: helper.pickImage,
          child: Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _selectedImage != null ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedImage != null ? Icons.camera_alt_rounded : Icons.add_photo_alternate_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _selectedImage != null ? 'Change photo' : 'Add a photo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _save,
      child: Text(
        'Save Memory',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
    );
  }


  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatReminder(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = date.hour;
    final m = date.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour12:${m.toString().padLeft(2, '0')} $period';
  }
}