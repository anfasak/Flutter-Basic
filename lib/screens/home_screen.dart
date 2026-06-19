import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/vlog_provider.dart';
import '../widgets/vlog_card.dart';
import 'vlog_details_screen.dart';
import 'vlog_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final AnimationController _shimmerController;
  late final ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VlogProvider>().loadVlogs();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VlogProvider>();
    final vlogs = provider.filteredVlogs;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'CreatorFlow',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => provider.toggleSortByDate(),
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: provider.isSortedByDate ? 0 : 0.5,
                      child: Icon(
                        provider.isSortedByDate
                            ? Icons.sort_by_alpha
                            : Icons.calendar_month,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStaggeredItem(
                        index: 0,
                        child: _buildSearchSection(context, provider),
                      ),
                      const SizedBox(height: 24),
                      _buildStaggeredItem(
                        index: 1,
                        child: _buildWelcomeBanner(context),
                      ),
                      const SizedBox(height: 24),
                      _buildStaggeredItem(
                        index: 2,
                        child: _buildSectionHeader(theme, 'Quick Tools'),
                      ),
                      const SizedBox(height: 12),
                      _buildStaggeredItem(
                        index: 3,
                        child: _buildQuickActions(context, provider),
                      ),
                      const SizedBox(height: 24),
                      _buildStaggeredItem(
                        index: 4,
                        child: _buildSectionHeader(theme, 'Insights'),
                      ),
                      const SizedBox(height: 12),
                      _buildStaggeredItem(
                        index: 5,
                        child: _buildStatsGrid(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Content',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('View all'),
                        onPressed: () => provider.setSelectedStatus('All'),
                      ),
                    ],
                  ),
                ),
              ),
              if (vlogs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildStaggeredItem(
                      index: 6,
                      child: _buildEmptyState(context),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final vlog = vlogs[index];
                    return _buildStaggeredItem(
                      index: index + 6,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: VlogCard(
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
                          onFavoriteToggle: () =>
                              provider.toggleFavorite(vlog.id),
                        ),
                      ),
                    );
                  }, childCount: vlogs.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 400),
          scale: _isFabVisible ? 1 : 0,
          curve: Curves.easeOutBack,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VlogFormScreen()),
              );
              provider.loadVlogs();
            },
            elevation: 8,
            highlightElevation: 2,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create New'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStaggeredItem({required int index, required Widget child}) {
    final start = index * 0.1;
    final end = (start + 0.5).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutQuart),
        );
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0,
                (_shimmerController.value - 0.2).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.2).clamp(0.0, 1.0),
                1,
              ],
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
                theme.colorScheme.tertiary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Creator 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your creative journey continues. You have 5 tasks pending.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ScalePulseIcon(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, VlogProvider provider) {
    final theme = Theme.of(context);
    final actions = [
      _QuickAction(
        icon: Icons.edit_document,
        label: 'Create',
        color: Colors.orange,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VlogFormScreen()),
          );
          provider.loadVlogs();
        },
      ),
      _QuickAction(
        icon: Icons.insights_rounded,
        label: 'Stats',
        color: Colors.green,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.event_note_rounded,
        label: 'Plans',
        color: Colors.blue,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.star_rounded,
        label: 'Best',
        color: Colors.amber,
        onTap: () {},
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _InteractiveScale(
            onTap: action.onTap,
            child: Container(
              width: 85,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, VlogProvider provider) {
    final theme = Theme.of(context);
    final stats = [
      _StatItem(
        'Total',
        provider.totalContent.toString(),
        Icons.folder_rounded,
        Colors.indigo,
      ),
      _StatItem(
        'Ideas',
        provider.ideasCount.toString(),
        Icons.lightbulb_rounded,
        Colors.amber,
      ),
      _StatItem(
        'Drafts',
        provider.draftsCount.toString(),
        Icons.history_edu_rounded,
        Colors.blue,
      ),
      _StatItem(
        'Queue',
        provider.scheduledCount.toString(),
        Icons.layers_rounded,
        Colors.purple,
      ),
      _StatItem(
        'Done',
        provider.publishedCount.toString(),
        Icons.verified_rounded,
        Colors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _InteractiveScale(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(stat.icon, color: stat.color.withValues(alpha: 0.7), size: 22),
                const SizedBox(height: 8),
                Text(
                  stat.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context, VlogProvider provider) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search your creative flow...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => provider.setSearchQuery(''),
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final status in VlogProvider.statusOptions)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: provider.selectedStatus == status,
                      onSelected: (_) => provider.setSelectedStatus(status),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: provider.selectedStatus == status
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight: provider.selectedStatus == status
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                      elevation: provider.selectedStatus == status ? 2 : 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        _ScalePulseIcon(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_motion_rounded,
              size: 60,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Empty Canvas',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your next big project today.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}

class _InteractiveScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _InteractiveScale({required this.child, required this.onTap});

  @override
  State<_InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<_InteractiveScale> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _ScalePulseIcon extends StatefulWidget {
  final Widget child;
  const _ScalePulseIcon({required this.child});

  @override
  State<_ScalePulseIcon> createState() => _ScalePulseIconState();
}

class _ScalePulseIconState extends State<_ScalePulseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem(this.label, this.value, this.icon, this.color);
}
