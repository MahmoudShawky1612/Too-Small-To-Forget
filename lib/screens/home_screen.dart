// lib/screens/home_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/screens/add_memory_screen.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
import 'package:toosmalltoforget/services/notification_service.dart';
import 'package:toosmalltoforget/theme/app_colors.dart';
import 'package:toosmalltoforget/widgets/memory_card.dart';
import '../helpers/home_screen_helper.dart';

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
      categories: [],
      memories: [],
      selectedCategoryId: null,
      searchQuery: '',
    );
    _helper.loadCategories();
    _helper.loadMemories();
  }

  Future<void> _onAddMemory(Memory newMemory) async {
    final id = await _dbHelper.insertMemory(newMemory);
    if (newMemory.reminder != null) {
      await NotificationService().scheduleNotification(
        id: id,
        title: 'Reminder: ${newMemory.title}',
        body: newMemory.details.isNotEmpty
            ? newMemory.details
            : 'Tap to view memory',
        scheduledDate: newMemory.reminder!,
      );
    }
    await _helper.loadCategories();
    _helper.loadMemories();
  }

  Future<void> _onDeleteMemory(Memory memory) async {
    if (memory.id != null) {
      await NotificationService().cancelNotification(memory.id!);
    }
    await _dbHelper.deleteMemory(memory.id!);
    _helper.loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(),
                  SizedBox(height: 20.h),
                  _buildCategoryRow(),
                  SizedBox(height: 24.h),
                  _buildMemoriesSection(),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }


  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      expandedHeight: 100.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 14.h),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
            children: const [
              TextSpan(text: 'Too Small ', style: TextStyle(color: AppColors.textLight)),
              TextSpan(text: 'To Forget', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.background.withOpacity(0.95),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        onChanged: _helper.onSearchChanged,
        style: TextStyle(color: AppColors.textLight, fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: 'Search memories...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 10.w),
            child: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22.sp),
          ),
          prefixIconConstraints: const BoxConstraints(),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          filled: false,
        ),
      ),
    );
  }


  Widget _buildCategoryRow() {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('All', _helper.selectedCategoryId == null, () => _helper.selectCategory(null)),
          SizedBox(width: 8.w),
          ..._helper.categories.map((cat) => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _buildChip(
              cat.name,
              _helper.selectedCategoryId == cat.id,
              () => _helper.selectCategory(cat.id),
              onLongPress: () => _helper.deleteCategory(cat),
            ),
          )),
          _buildAddCategoryButton(),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.chipSelectedText : AppColors.chipUnselectedText,
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: _helper.addCategory,
      child: Container(
        height: 40.h,
        width: 40.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Icon(Icons.add_rounded, color: AppColors.primary, size: 20.sp),
      ),
    );
  }


  Widget _buildMemoriesSection() {
    if (_helper.memories.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_helper.memories.length} ${_helper.memories.length == 1 ? 'memory' : 'memories'}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_helper.memories.length, (index) {
          final memory = _helper.memories[index];
          return MemoryCard(
            memory: memory,
            categoryName: _helper.getCategoryName(memory.categoryId),
            onDelete: () => _onDeleteMemory(memory),
            onTap: () => _showMemoryDetail(memory),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 32.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              'No memories yet',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the + button to capture\nyour first little moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14.sp,
                height: 1.6.h,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showMemoryDetail(Memory memory) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            memory.title,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded, color: AppColors.textMid, size: 22.sp),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                      children: [
                        if (memory.photoPath != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: Image.file(
                              File(memory.photoPath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 120.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted, size: 40.sp),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                        _detailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Memory date',
                          value: _formatDetailDate(memory.date),
                        ),
                        if (memory.reminder != null) ...[
                          SizedBox(height: 14.h),
                          _detailRow(
                            icon: Icons.alarm_rounded,
                            label: 'Reminder',
                            value: _formatDetailReminder(memory.reminder!),
                          ),
                          if (memory.id != null) ...[
                            SizedBox(height: 14.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _confirmRemoveReminder(ctx, memory),
                                icon: Icon(
                                  Icons.notifications_off_outlined,
                                  size: 18.sp,
                                  color: AppColors.textMid,
                                ),
                                label: Text(
                                  'Remove reminder',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textLight,
                                  side: const BorderSide(color: AppColors.border),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                        if (_helper.getCategoryName(memory.categoryId).isNotEmpty) ...[
                          SizedBox(height: 14.h),
                          _detailRow(
                            icon: Icons.label_outline_rounded,
                            label: 'Category',
                            value: _helper.getCategoryName(memory.categoryId),
                          ),
                        ],
                        if (memory.details.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          Text(
                            'DETAILS',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            memory.details,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 15.sp,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(color: AppColors.textLight, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDetailDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _confirmRemoveReminder(
    BuildContext sheetContext,
    Memory memory,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Remove reminder?',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You will no longer get a notification for this memory.',
          style: TextStyle(color: AppColors.textMid, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Remove',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || memory.id == null) return;

    final updated = Memory(
      id: memory.id,
      title: memory.title,
      details: memory.details,
      date: memory.date,
      categoryId: memory.categoryId,
      reminder: null,
      photoPath: memory.photoPath,
    );
    await _dbHelper.updateMemory(updated);
    await NotificationService().cancelNotification(memory.id!);
    if (sheetContext.mounted) Navigator.pop(sheetContext);
    _helper.loadMemories();
  }

  String _formatDetailReminder(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = d.hour;
    final m = d.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $hour12:${m.toString().padLeft(2, '0')} $period';
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddMemoryScreen(onAdd: _onAddMemory)),
      ),
      backgroundColor: AppColors.primary,
      elevation: 8,
      child: Icon(Icons.add_rounded, size: 30.sp, color: Colors.white),
    );
  }
}