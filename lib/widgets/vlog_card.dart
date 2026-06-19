import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vlog.dart';

class VlogCard extends StatelessWidget {
  final Vlog vlog;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const VlogCard({
    super.key,
    required this.vlog,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'thumb-${vlog.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: vlog.thumbnailPath.isNotEmpty
                          ? Image.file(
                              File(vlog.thumbnailPath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _fallbackThumbnail(context),
                            )
                          : _fallbackThumbnail(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vlog.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onFavoriteToggle,
                            icon: Icon(
                              vlog.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: vlog.isFavorite ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vlog.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(vlog.platform, Icons.ondemand_video_outlined),
                          _infoChip(vlog.status, Icons.circle, color: _statusColor(vlog.status)),
                          _infoChip(
                            dateFormat.format(vlog.uploadDate),
                            Icons.calendar_today,
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
      ),
    );
  }

  Widget _fallbackThumbnail(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color != null ? color.withValues(alpha: 0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Idea':
        return Colors.amber;
      case 'Draft':
        return Colors.blue;
      case 'Recording':
        return Colors.indigo;
      case 'Editing':
        return Colors.purple;
      case 'Scheduled':
        return Colors.orange;
      case 'Published':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
