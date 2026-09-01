import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../app/providers/ceremony_provider.dart';
import '../app/providers/profile_provider.dart';
import '../app/services/sound_service.dart';
import 'ceremonies/ceremonies.dart';
import 'sheets/quest_editor_sheet.dart';
import 'theme/tokens.dart';

class RootScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return _RootScaffoldView(navigationShell: navigationShell);
  }
}

class _RootScaffoldView extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _RootScaffoldView({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    // Sync sound effects setting with SoundService
    ref.listen<AsyncValue<bool>>(soundEnabledProvider, (prev, next) {
      if (next.hasValue) {
        SoundService.soundEnabled = next.value!;
      }
    });

    // Listen for ceremony events
    ref.listen<CeremonyEvent?>(activeCeremonyProvider, (prev, next) {
      if (next != null) {
        if (next is LevelUpCeremonyEvent) {
          SoundService.playLevelUp();
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
          SoundService.playUnlock();
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
              icon: Symbols.checklist,
              label: 'TODAY',
              isSelected: currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),

            // Rune Add Quest Button: Rectangle inside rectangle with plus sign
            GestureDetector(
              onTap: () => QuestEditorSheet.show(context),
              child: Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: tokens.textPrimary,
                    width: 1.5,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: tokens.tonal,
                    border: Border.all(
                      color: tokens.lineRest,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.add,
                    size: 20,
                    color: tokens.textPrimary,
                    weight: 700,
                  ),
                ),
              ),
            ),

            // Insights Tab
            _buildNavTab(
              context,
              tokens,
              icon: Symbols.grid_view,
              label: 'INSIGHTS',
              isSelected: currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),

            // Profile Tab
            _buildNavTab(
              context,
              tokens,
              icon: Symbols.person,
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
              fill: isSelected ? 1.0 : 0.0,
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
