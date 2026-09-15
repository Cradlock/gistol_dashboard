import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/view/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _sections = <_HomeSection>[
    _HomeSection(
      path: '/groups',
      icon: Icons.group_outlined,
      titleKey: 'groups.title',
      descriptionKey: 'home.groups_desc',
    ),
    _HomeSection(
      path: '/students',
      icon: Icons.school_outlined,
      titleKey: 'students.title',
      descriptionKey: 'home.students_desc',
    ),
    _HomeSection(
      path: '/tasks',
      icon: Icons.assignment_outlined,
      titleKey: 'tasks.title',
      descriptionKey: 'home.tasks_desc',
    ),
    _HomeSection(
      path: '/exams',
      icon: Icons.quiz_outlined,
      titleKey: 'exams.title',
      descriptionKey: 'home.exams_desc',
    ),
    _HomeSection(
      path: '/settings',
      icon: Icons.settings_outlined,
      titleKey: 'settings.title',
      descriptionKey: 'home.settings_desc',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final padding = isMobile ? 20.0 : 32.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isMobile) ...[
                  IconButton(
                    tooltip: AppStrings.navigation.menu.tr(),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    AppStrings.home.title.tr(),
                    style: isMobile
                        ? theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : theme.textTheme.displayLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1024
                          ? 3
                          : constraints.maxWidth >= 640
                          ? 2
                          : 1;
                      const gap = 16.0;
                      final cardWidth =
                          (constraints.maxWidth - gap * (columns - 1)) /
                          columns;

                      return ListView(
                        children: [
                          const _HomeHero(),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              for (final section in _sections)
                                SizedBox(
                                  width: cardWidth,
                                  child: _HomeSectionCard(section: section),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = context.watch<AuthProvider>().user;
    final name = '${user?.name ?? ''} ${user?.surname ?? ''}'.trim();
    final greeting = name.isEmpty
        ? AppStrings.home.welcome.tr()
        : AppStrings.home.welcomeNamed.tr(args: [name]);
    final isNarrow = ResponsiveLayout.isMobile(context);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gistology',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          greeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.home.subtitle.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onPrimaryContainer.withValues(alpha: 0.82),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 20 : 28),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const AppIcon(size: 72), const SizedBox(height: 16), text],
            )
          : Row(
              children: [
                const AppIcon(size: 72),
                const SizedBox(width: 20),
                Expanded(child: text),
              ],
            ),
    );
  }
}

class _HomeSection {
  const _HomeSection({
    required this.path,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  final String path;
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
}

class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({required this.section});

  final _HomeSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(section.path),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(section.icon, color: colors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                section.titleKey.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.descriptionKey.tr(),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    AppStrings.home.open.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 18, color: colors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
