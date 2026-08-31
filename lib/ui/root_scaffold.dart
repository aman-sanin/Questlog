import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/providers/ceremony_provider.dart';
import 'ceremonies/ceremonies.dart';
import 'sheets/quest_editor_sheet.dart';
import 'theme/tokens.dart';

class RootScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const RootScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    // Listen for ceremony events
    ref.listen<CeremonyEvent?>(activeCeremonyProvider, (prev, next) {
      if (next != null) {
        if (next is LevelUpCeremonyEvent) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => LevelUpCeremonyDialog(
              event: next,
              onDismiss: () {
                ref.read(activeCeremonyProvider.notifier).state = null;
                Navigator.of(ctx).pop();
              },
            ),
          );
        } else if (next is CallingChoiceCeremonyEvent) {
          CallingSelectionSheet.show(context);
        }
      }
    });

    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: tokens.bg,
          border: Border(
            top: BorderSide(color: tokens.lineRule, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Today Tab
            _buildNavTab(
              context,
              tokens,
              icon: Icons.checklist,
              label: 'TODAY',
              isSelected: currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),

            // 56dp Sharp FAB Monolith
            GestureDetector(
              onTap: () => QuestEditorSheet.show(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tokens.textPrimary,
                  border: Border.all(color: tokens.textPrimary, width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: tokens.onSolid,
                ),
              ),
            ),

            // Insights Tab
            _buildNavTab(
              context,
              tokens,
              icon: Icons.grid_view,
              label: 'INSIGHTS',
              isSelected: currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),

            // Profile Tab
            _buildNavTab(
              context,
              tokens,
              icon: Icons.person_outline,
              label: 'PROFILE',
              isSelected: currentIndex == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(
    BuildContext context,
    AppTokens tokens, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: tokens.monoText(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
                color: isSelected ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
