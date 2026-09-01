import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/ceremony_provider.dart';
import '../../app/providers/database_provider.dart';
import '../../domain/engine/calling.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/burst_widget.dart';
import '../widgets/sigil_widget.dart';

class LevelUpCeremonyDialog extends StatelessWidget {
  final LevelUpCeremonyEvent event;
  final VoidCallback onDismiss;

  const LevelUpCeremonyDialog({
    super.key,
    required this.event,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: tokens.bg,
          border: Border.all(color: tokens.hero, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BurstWidget(
              size: 140,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.tonal,
                  border: Border.all(color: tokens.hero, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${event.newLevel}',
                  style: tokens.monoText(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: tokens.hero,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'LEVEL REACHED',
              style: tokens.monoText(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: tokens.hero,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.title.toUpperCase(),
              style: tokens.display(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            if (event.unlocks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.tonal,
                  border: Border.all(color: tokens.lineRest, width: 1),
                ),
                child: Column(
                  children: event.unlocks
                      .map((u) => Row(
                            children: [
                              Icon(Symbols.lock_open, size: 16, color: tokens.accent),
                              const SizedBox(width: 8),
                              Text(
                                u.title,
                                style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ActionButton(
              label: 'CLAIM & CONTINUE',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

class CallingSelectionSheet extends ConsumerStatefulWidget {
  const CallingSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CallingSelectionSheet(),
    );
  }

  @override
  ConsumerState<CallingSelectionSheet> createState() => _CallingSelectionSheetState();
}

class _CallingSelectionSheetState extends ConsumerState<CallingSelectionSheet> {
  CallingDomain _selected = CallingDomain.warrior;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final info = CallingEngine.getInfo(_selected);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                color: tokens.lineRule,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CHOOSE YOUR CALLING',
              style: tokens.headline(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Shapes your title ladder and crest sigil.',
              style: tokens.body(fontSize: 14, color: tokens.textSecondary),
            ),
            const SizedBox(height: 20),

            // 2x3 Grid of Calling choices
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: CallingDomain.values.map((d) {
                final isSelected = d == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.tonal : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? tokens.accent : tokens.lineRule,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SigilWidget(
                          domain: d,
                          size: 28,
                          color: isSelected ? tokens.accent : tokens.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.name.toUpperCase(),
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? tokens.accent : tokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Calling Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.tonal,
                border: Border.all(color: tokens.lineRest, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.tagline,
                    style: tokens.title(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.description,
                    style: tokens.body(fontSize: 13, color: tokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button
            ActionButton(
              label: 'TAKE UP THIS CALLING',
              onPressed: () async {
                await ref.read(profileActionsProvider).chooseCalling(
                      _selected,
                      DateTime.now(),
                    );
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
