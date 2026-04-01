import 'dart:io';
import 'package:flutter/material.dart';
import 'package:toosmalltoforget/models/memory.dart';

class MemoryCard extends StatelessWidget {
  final Memory memory;
  final String categoryName;
  final VoidCallback onDelete; // callback to delete the memory

  const MemoryCard({
    super.key,
    required this.memory,
    required this.categoryName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Dismissible wraps the card to allow swipe-to-delete
    return Dismissible(
      key: Key(memory.id.toString()), // each card needs a unique key
      direction: DismissDirection.endToStart, // swipe from right to left
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete(); // call the delete callback passed from parent
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional thumbnail
              if (memory.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(memory.photoPath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If image fails to load, show a placeholder
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              if (memory.photoPath != null) const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (memory.details.isNotEmpty)
                      Text(
                        memory.details,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Category chip (if any)
                        if (categoryName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categoryName,
                              style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
                            ),
                          ),
                        if (categoryName.isNotEmpty) const SizedBox(width: 8),

                        // Relative time
                        Text(
                          _formatRelativeTime(memory.date),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to format relative time (same as before)
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}