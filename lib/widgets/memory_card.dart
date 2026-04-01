// lib/widgets/memory_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toosmalltoforget/models/memory.dart';
import 'package:toosmalltoforget/theme/app_colors.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final String categoryName;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.categoryName,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(memory.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => _buildDeleteDialog(context),
        );
      },
      background: _buildDismissBackground(),
      onDismissed: (_) => onDelete(),
      child: _buildCard(context),
    );
  }


  Widget _buildCard(BuildContext context) {
    final bool hasPhoto = memory.photoPath != null;
    final bool hasReminder = memory.reminder != null;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        gradient: AppColors.cardOverlay,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.cardBackgroundPressed.withOpacity(0.15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasPhoto) ...[
                  _buildPhotoThumbnail(),
                  SizedBox(width: 14.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + optional reminder icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              memory.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (hasReminder) ...[
                            SizedBox(width: 8.w),
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Icon(
                                Icons.alarm_rounded,
                                size: 15.sp,
                                color: AppColors.amber,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (memory.details.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text(
                          memory.details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                            height: 1.55,
                          ),
                        ),
                      ],

                      SizedBox(height: 12.h),

                      // Footer row: category pill + date
                      Row(
                        children: [
                          if (categoryName.isNotEmpty)
                            _buildCategoryPill(categoryName),
                          const Spacer(),
                          _buildDateLabel(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPhotoThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.file(
        File(memory.photoPath!),
        width: 68.w,
        height: 68.w,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: 68.w,
      height: 68.w,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary, size: 24.sp),
    );
  }


  Widget _buildCategoryPill(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }


  Widget _buildDateLabel() {
    return Row(
      children: [
        Icon(Icons.access_time_rounded, size: 11.sp, color: AppColors.textTertiary),
        SizedBox(width: 3.w),
        Text(
          _formatRelativeTime(memory.date),
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildDismissBackground() {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(18.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26.sp),
          SizedBox(height: 4.h),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDeleteDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Delete memory?',
        style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
      ),
      content: Text(
        '"${memory.title}" will be permanently removed.',
        style: const TextStyle(color: AppColors.textMid),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }


  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}