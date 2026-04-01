// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/screens/add_memory_screen.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
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
    await _dbHelper.insertMemory(newMemory);
    await _helper.loadCategories();
    _helper.loadMemories();
  }

  Future<void> _onDeleteMemory(Memory memory) async {
    await _dbHelper.deleteMemory(memory.id!);
    _helper.loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ),
          )),
          _buildAddCategoryButton(),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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