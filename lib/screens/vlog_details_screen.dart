import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/vlog.dart';
import '../services/vlog_provider.dart';
import 'vlog_form_screen.dart';

class VlogDetailsScreen extends StatelessWidget {
  final Vlog vlog;

  const VlogDetailsScreen({super.key, required this.vlog});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final theme = Theme.of(context);
    final provider = context.read<VlogProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'thumb-${vlog.id}',
                child: vlog.thumbnailPath.isNotEmpty
                    ? Image.file(
                        File(vlog.thumbnailPath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 72,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => provider.toggleFavorite(vlog.id),
                icon: Icon(
                  vlog.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: vlog.isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vlog.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(vlog.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          vlog.status,
                          style: TextStyle(
                            color: _statusColor(vlog.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    vlog.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _detailChip(
                        context,
                        Icons.ondemand_video,
                        'Platform',
                        vlog.platform,
                      ),
                      _detailChip(
                        context,
                        Icons.category,
                        'Category',
                        vlog.category,
                      ),
                      _detailChip(
                        context,
                        Icons.calendar_month,
                        'Publish Date',
                        dateFormat.format(vlog.uploadDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VlogFormScreen(vlog: vlog),
                              ),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Content'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(value),
            ],
          ),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<VlogProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete content?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await provider.deleteVlog(vlog.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
