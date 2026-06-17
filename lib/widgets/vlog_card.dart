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
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _statusColor(vlog.status).withValues(alpha: 0.15),
                  child: Icon(
                    _statusIcon(vlog.status),
                    color: _statusColor(vlog.status),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onFavoriteToggle,
                            icon: Icon(
                              vlog.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: vlog.isFavorite ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vlog.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(vlog.category, Icons.category),
                          _infoChip(vlog.status, Icons.radio_button_checked),
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

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Idea':
        return Colors.blue;
      case 'Recording':
        return Colors.orange;
      case 'Editing':
        return Colors.purple;
      case 'Uploaded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Idea':
        return Icons.lightbulb;
      case 'Recording':
        return Icons.videocam;
      case 'Editing':
        return Icons.edit;
      case 'Uploaded':
        return Icons.cloud_done;
      default:
        return Icons.help;
    }
  }
}
