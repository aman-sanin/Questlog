import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/profile_view_provider.dart';
import '../../app/services/sound_service.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/radio_row.dart';
import '../widgets/segmented_control.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final profileAsync = ref.watch(profileStreamProvider);
    final profileViewAsync = ref.watch(profileViewStateProvider);
    final profile = profileAsync.value;
    final currentLevel = profileViewAsync.value?.progression.level ?? 1;

    if (profile == null) {
      return Scaffold(
        backgroundColor: tokens.bg,
        body: Center(child: CircularProgressIndicator(color: tokens.accent)),
      );
    }

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'SETTINGS',
          style: tokens.monoText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: tokens.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Theme Section
          Text(
            'APPEARANCE',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedControl<int>(
            items: const [
              SegmentItem(value: 1, label: 'Onyx (Dark)'),
              SegmentItem(value: 0, label: 'System'),
              SegmentItem(value: 2, label: 'Ivory (Light)'),
            ],
            selectedValue: profile.themeMode,
            onSelected: (mode) {
              ref.read(profileActionsProvider).setThemeMode(mode);
            },
          ),
          const SizedBox(height: 24),

          // Accent Palette Section
          Text(
            'MOTION ACCENT PALETTE',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildAccentOption(
            context,
            ref,
            label: 'Frost (Default)',
            accentKey: 'frost',
            currentAccent: profile.accent,
            isUnlocked: true,
          ),
          const SizedBox(height: 6),
          _buildAccentOption(
            context,
            ref,
            label: 'Sage',
            accentKey: 'sage',
            currentAccent: profile.accent,
            isUnlocked: currentLevel >= 3,
            unlockRequirement: 'Unlocks at Level 3',
          ),
          const SizedBox(height: 6),
          _buildAccentOption(
            context,
            ref,
            label: 'Ice',
            accentKey: 'ice',
            currentAccent: profile.accent,
            isUnlocked: currentLevel >= 5,
            unlockRequirement: 'Unlocks at Level 5',
          ),
          const SizedBox(height: 6),
          _buildAccentOption(
            context,
            ref,
            label: 'Copper',
            accentKey: 'copper',
            currentAccent: profile.accent,
            isUnlocked: currentLevel >= 13,
            unlockRequirement: 'Unlocks at Level 13',
          ),
          const SizedBox(height: 6),
          _buildAccentOption(
            context,
            ref,
            label: 'Ember (Prestige)',
            accentKey: 'ember',
            currentAccent: profile.accent,
            isUnlocked: currentLevel >= 16,
            unlockRequirement: 'Unlocks at Level 16',
          ),
          const SizedBox(height: 24),

          // Cadence & Day Reset Section
          Text(
            'CADENCE & BOUNDARIES',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          RadioRow<int>(
            value: 0,
            groupValue: profile.resetMinute,
            title: 'Midnight (00:00)',
            subtitle: 'Day resets at regular midnight.',
            onChanged: (val) {
              ref.read(profileActionsProvider).setCadenceSettings(
                    resetMinute: val,
                    weekStart: profile.weekStart,
                  );
            },
          ),
          const SizedBox(height: 6),
          RadioRow<int>(
            value: 240,
            groupValue: profile.resetMinute,
            title: 'Late Night (04:00 AM)',
            subtitle: 'For night owls. Day resets 4 hours past midnight.',
            onChanged: (val) {
              ref.read(profileActionsProvider).setCadenceSettings(
                    resetMinute: val,
                    weekStart: profile.weekStart,
                  );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'WEEK START',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedControl<int>(
            items: const [
              SegmentItem(value: 1, label: 'Monday'),
              SegmentItem(value: 7, label: 'Sunday'),
            ],
            selectedValue: profile.weekStart,
            onSelected: (val) {
              ref.read(profileActionsProvider).setCadenceSettings(
                    resetMinute: profile.resetMinute,
                    weekStart: val,
                  );
            },
          ),
          const SizedBox(height: 24),

          // Feedback & Audio
          Text(
            'FEEDBACK & AUDIO',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final isSoundEnabled = ref.watch(soundEnabledProvider);
              return RadioRow<bool>(
                value: true,
                groupValue: isSoundEnabled,
                title: 'Tactile Sound Effects',
                subtitle: 'Play subtle audio feedback on completions and level ups.',
                onChanged: (val) {
                  ref.read(soundEnabledProvider.notifier).state = val;
                  SoundService.soundEnabled = val;
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Backup & Data
          Text(
            'DATA & PRIVACY',
            style: tokens.monoText(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your log survives reinstall on this device',
            style: tokens.body(
              fontSize: 12,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'EXPORT BACKUP',
                  variant: ActionButtonVariant.secondary,
                  onPressed: () async {
                    final jsonStr = await ref.read(backupServiceProvider).exportBackupJson();
                    final tempDir = await getTemporaryDirectory();
                    final now = DateTime.now();
                    final dateStr =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final file = File('${tempDir.path}/questlog_backup_$dateStr.json');
                    await file.writeAsString(jsonStr);
                    await Share.shareXFiles(
                      [XFile(file.path, mimeType: 'application/json')],
                      subject: 'QuestLog Backup $dateStr',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ActionButton(
                  label: 'IMPORT BACKUP',
                  variant: ActionButtonVariant.secondary,
                  onPressed: () async {
                    final files = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (files.isNotEmpty && files.first.path != null) {
                      try {
                        final file = File(files.first.path!);
                        final content = await file.readAsString();
                        final success = await ref.read(backupServiceProvider).importBackupJson(content);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? 'Backup imported successfully.' : 'Failed to import backup.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Import error: $e'),
                              backgroundColor: tokens.miss,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // App Meta Info & Debug Entry
          Center(
            child: GestureDetector(
              onTap: () => context.push('/debug'),
              onLongPress: () => context.push('/debug'),
              child: Text(
                'QUESTLOG v1.0 · LOCAL FIRST · NO ACCOUNTS',
                style: tokens.monoText(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: tokens.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAccentOption(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String accentKey,
    required String currentAccent,
    required bool isUnlocked,
    String? unlockRequirement,
  }) {
    final tokens = context.tokens;
    final isSelected = currentAccent == accentKey;

    return InkWell(
      onTap: isUnlocked
          ? () {
              ref.read(profileActionsProvider).setAccent(accentKey);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? tokens.tonal : Colors.transparent,
          border: Border.all(
            color: isSelected ? tokens.lineRest : tokens.lineRule,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              color: _accentColorFor(tokens, accentKey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: tokens.body(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isUnlocked ? tokens.textPrimary : tokens.textSecondary.withOpacity(0.5),
                ),
              ),
            ),
            if (!isUnlocked)
              Text(
                unlockRequirement ?? 'Locked',
                style: tokens.monoText(
                  fontSize: 11,
                  color: tokens.textSecondary.withOpacity(0.6),
                ),
              )
            else if (isSelected)
              Icon(Symbols.check, size: 16, color: tokens.accent, weight: 700),
          ],
        ),
      ),
    );
  }

  Color _accentColorFor(AppTokens tokens, String key) {
    switch (key) {
      case 'sage':
        return const Color(0xFF9CAF9C);
      case 'ice':
        return const Color(0xFF8FD3E8);
      case 'copper':
        return const Color(0xFFCD7F32);
      case 'ember':
        return const Color(0xFFE0A458);
      case 'frost':
      default:
        return const Color(0xFF4A90E2);
    }
  }
}
