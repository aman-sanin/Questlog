import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../app/providers/database_provider.dart';
import '../../data/packs/quest_pack_service.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/chips.dart';
import '../widgets/sigil_widget.dart';

class PackPreviewScreen extends ConsumerStatefulWidget {
  final QuestPackValidationResult validation;

  const PackPreviewScreen({
    super.key,
    required this.validation,
  });

  static Future<void> show(BuildContext context, QuestPackValidationResult validation) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PackPreviewScreen(validation: validation),
      ),
    );
  }

  @override
  ConsumerState<PackPreviewScreen> createState() => _PackPreviewScreenState();
}

class _PackPreviewScreenState extends ConsumerState<PackPreviewScreen> {
  late final Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = {};
    for (int i = 0; i < widget.validation.validQuests.length; i++) {
      if (widget.validation.validQuests[i].isSelectedByDefault) {
        _selectedIndices.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final val = widget.validation;

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        backgroundColor: tokens.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'PREVIEW QUEST PACK',
          style: tokens.headline(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pack Metadata Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.tonal,
                      border: Border.all(color: tokens.accent, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          val.packName.toUpperCase(),
                          style: tokens.headline(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: tokens.accent,
                          ),
                        ),
                        if (val.packDescription != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            val.packDescription!,
                            style: tokens.body(fontSize: 13, color: tokens.textSecondary),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${val.validQuests.length} QUESTS',
                              style: tokens.monoText(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                            ),
                            if (val.goals.isNotEmpty) ...[
                              Text(' · ', style: tokens.monoText(color: tokens.textSecondary)),
                              Text(
                                '${val.goals.length} EMBEDDED GOALS',
                                style: tokens.monoText(fontSize: 11, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Caution Alert if >5 essential dailies
                  if (val.hasTooManyEssentials)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tokens.miss.withOpacity(0.12),
                        border: Border.all(color: tokens.miss, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.warning, size: 18, color: tokens.miss),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pack contains ${val.essentialDailyCount} essential daily quests. Maintaining more than 5 essential dailies increases risk of discipline burnout.',
                              style: tokens.body(fontSize: 12, color: tokens.miss),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Quests List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUESTS TO IMPORT (${_selectedIndices.length}/${val.validQuests.length})',
                        style: tokens.monoText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: tokens.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedIndices.length == val.validQuests.length) {
                              _selectedIndices.clear();
                            } else {
                              _selectedIndices.addAll(List.generate(val.validQuests.length, (i) => i));
                            }
                          });
                        },
                        child: Text(
                          _selectedIndices.length == val.validQuests.length ? 'DESELECT ALL' : 'SELECT ALL',
                          style: tokens.monoText(fontSize: 11, fontWeight: FontWeight.w700, color: tokens.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Valid Quests
                  for (int i = 0; i < val.validQuests.length; i++) ...[
                    _QuestRowItem(
                      item: val.validQuests[i],
                      isSelected: _selectedIndices.contains(i),
                      onToggle: () {
                        setState(() {
                          if (_selectedIndices.contains(i)) {
                            _selectedIndices.remove(i);
                          } else {
                            _selectedIndices.add(i);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Rejected Quests (if any)
                  if (val.rejectedQuests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'REJECTED ROWS (${val.rejectedQuests.length})',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: tokens.miss,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final r in val.rejectedQuests) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.tonal,
                          border: Border.all(color: tokens.miss.withOpacity(0.5), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.rawJson['title']?.toString() ?? 'Unnamed Quest',
                              style: tokens.title(fontSize: 14, color: tokens.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.reason,
                              style: tokens.monoText(fontSize: 11, color: tokens.miss),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],

                  const SizedBox(height: 16),

                  // Privacy Line
                  Center(
                    child: Text(
                      'Packs contain quest setups only — your history stays on your device.',
                      textAlign: TextAlign.center,
                      style: tokens.body(fontSize: 11, color: tokens.textSecondary.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: tokens.bg,
              border: Border(top: BorderSide(color: tokens.lineRule, width: 1)),
            ),
            child: ActionButton(
              label: 'IMPORT ${_selectedIndices.length} QUESTS',
              variant: ActionButtonVariant.primary,
              onPressed: _selectedIndices.isNotEmpty
                  ? () => _handleImport(context, ref)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _handleImport(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final selectedQuests = _selectedIndices
        .map((i) => widget.validation.validQuests[i].quest)
        .toList();

    final createdIds = await QuestPackService.importPack(
      db: db,
      quests: selectedQuests,
      goals: widget.validation.goals,
      now: DateTime.now(),
    );

    if (context.mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('Imported ${createdIds.length} quests successfully.'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.amber,
            onPressed: () async {
              await QuestPackService.undoImport(db, createdIds);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pack import undone.')),
                );
              }
            },
          ),
        ),
      );
    }
  }
}

class _QuestRowItem extends StatelessWidget {
  final ValidPackQuest item;
  final bool isSelected;
  final VoidCallback onToggle;

  const _QuestRowItem({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final q = item.quest;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? tokens.tonal : Colors.transparent,
          border: Border.all(
            color: isSelected ? tokens.accent : tokens.lineRule,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? tokens.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? tokens.accent : tokens.lineRest,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Icon(Symbols.check, size: 14, color: tokens.onSolid, weight: 700)
                  : null,
            ),
            const SizedBox(width: 12),

            SigilWidget(domain: q.domain, size: 20),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          q.title,
                          style: tokens.title(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      if (q.essential)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: EssentialStar(isEssential: true),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${q.cadence.name.toUpperCase()} · ${q.difficulty.name.toUpperCase()}',
                        style: tokens.monoText(fontSize: 11, color: tokens.textSecondary),
                      ),
                      if (item.isDuplicate) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.accent.withOpacity(0.15),
                            border: Border.all(color: tokens.accent, width: 1),
                          ),
                          child: Text(
                            'DUPLICATE',
                            style: tokens.monoText(fontSize: 9, fontWeight: FontWeight.w700, color: tokens.accent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
