import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vlog_provider.dart';
import '../widgets/vlog_card.dart';
import 'vlog_form_screen.dart';
import 'vlog_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VlogProvider>().loadVlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VlogProvider>();
    final vlogs = provider.filteredVlogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vlog Planner'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sort') {
                provider.toggleSortByDate();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sort',
                child: Text(
                  provider.isSortedByDate
                      ? 'Show newest first'
                      : 'Sort by date',
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search vlogs by title or description',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: provider.setSearchQuery,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: const ['All', 'Idea', 'Recording', 'Editing', 'Uploaded']
                    .length,
                itemBuilder: (context, index) {
                  final status = const ['All', 'Idea', 'Recording', 'Editing', 'Uploaded'][index];
                  final selected = provider.selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: selected,
                    onSelected: (_) => provider.setSelectedStatus(status),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: vlogs.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: vlogs.length,
                    itemBuilder: (context, index) {
                      final vlog = vlogs[index];
                      return VlogCard(
                        vlog: vlog,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VlogDetailsScreen(vlog: vlog),
                            ),
                          );
                          provider.loadVlogs();
                        },
                        onFavoriteToggle: () => provider.toggleFavorite(vlog.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VlogFormScreen(),
            ),
          );
          provider.loadVlogs();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Vlog'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.movie_creation_outlined,
                size: 72,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No vlogs yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Plan your next video idea and start creating amazing content.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
