import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/database_provider.dart';
import '../../app/providers/profile_provider.dart';
import '../../app/providers/today_provider.dart';
import '../../data/db/database.dart';
import '../../domain/engine/schedule_rule.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/app_input.dart';
import '../widgets/segmented_control.dart';
import '../widgets/sigil_widget.dart';
import '../widgets/weekday_toggles.dart';

class QuestEditorSheet extends ConsumerStatefulWidget {
  final QuestData? quest;

  const QuestEditorSheet({super.key, this.quest});

  static Future<void> show(BuildContext context, {QuestData? quest}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuestEditorSheet(quest: quest),
    );
  }

  @override
  ConsumerState<QuestEditorSheet> createState() => _QuestEditorSheetState();
}

class _QuestEditorSheetState extends ConsumerState<QuestEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _unitController;
  late Cadence _cadence;
  late ScheduleRule _rule;
  late TargetType _targetType;
  late int _targetValue;
  late Difficulty _difficulty;
  late bool _essential;
  String? _selectedGoalId;
  CallingDomain? _selectedDomain;
  Set<int> _selectedDays = {1, 2, 3, 4, 5};
  int _timesPerPeriod = 3;

  @override
  void initState() {
    super.initState();
    final q = widget.quest;
    _titleController = TextEditingController(text: q?.title ?? '');
    _unitController = TextEditingController(text: q?.unit ?? '');
    _cadence = q?.rule.cadence ?? Cadence.daily;
    _rule = q?.rule ?? const DailyEveryDayRule();
    _targetType = q != null ? TargetType.values[q.targetType] : TargetType.checkbox;
    _targetValue = q?.targetValue ?? 1;
    _difficulty = q != null ? Difficulty.values[q.difficulty] : Difficulty.medium;
    _essential = q?.essential ?? false;
    _selectedGoalId = q?.goalId;
    _selectedDomain = q?.domain != null ? CallingDomain.values[q!.domain!] : CallingDomain.warrior;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _updateRuleForCadence(Cadence newCadence) {
    setState(() {
      _cadence = newCadence;
      switch (newCadence) {
        case Cadence.daily:
          _rule = const DailyEveryDayRule();
          break;
        case Cadence.weekly:
          _rule = WeeklyTimesRule(times: _timesPerPeriod);
          break;
        case Cadence.monthly:
          _rule = const MonthlyTimesRule(times: 1);
          break;
        case Cadence.yearly:
          _rule = const YearlyTimesRule(times: 1);
          break;
      }
    });
  }

  Future<void> _saveQuest() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final actions = ref.read(questActionsProvider);
    final now = DateTime.now();

    if (widget.quest == null) {
      await actions.createQuest(
        title: title,
        rule: _rule,
        targetType: _targetType,
        targetValue: _targetValue,
        unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        difficulty: _difficulty,
        essential: _essential,
        goalId: _selectedGoalId,
        domain: _selectedDomain,
        now: now,
      );
    } else {
      await actions.updateQuest(
        id: widget.quest!.id,
        title: title,
        rule: _rule,
        targetType: _targetType,
        targetValue: _targetValue,
        unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        difficulty: _difficulty,
        essential: _essential,
        goalId: _selectedGoalId,
        domain: _selectedDomain,
        pausedUntil: widget.quest!.pausedUntil,
        archivedAt: widget.quest!.archivedAt,
        createdAt: widget.quest!.createdAt,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final goalsAsync = ref.watch(activeGoalsStreamProvider);
    final goals = goalsAsync.value ?? [];

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: tokens.bg,
        border: Border(
          top: BorderSide(color: tokens.lineRest, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                color: tokens.lineRule,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.quest == null ? 'NEW QUEST' : 'EDIT QUEST',
              style: tokens.monoText(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Quest Title
            AppInput(
              controller: _titleController,
              hintText: 'What is your quest?',
              autofocus: widget.quest == null,
            ),
            const SizedBox(height: 20),

            // Cadence Selector
            Text(
              'CADENCE',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedControl<Cadence>(
              items: const [
                SegmentItem(value: Cadence.daily, label: 'Daily'),
                SegmentItem(value: Cadence.weekly, label: 'Weekly'),
                SegmentItem(value: Cadence.monthly, label: 'Monthly'),
                SegmentItem(value: Cadence.yearly, label: 'Yearly'),
              ],
              selectedValue: _cadence,
              onSelected: _updateRuleForCadence,
            ),
            const SizedBox(height: 16),

            // Sub-rule schedule selectors
            if (_cadence == Cadence.daily) ...[
              SegmentedControl<int>(
                items: const [
                  SegmentItem(value: 0, label: 'Every Day'),
                  SegmentItem(value: 1, label: 'Weekdays'),
                ],
                selectedValue: _rule is DailyEveryDayRule ? 0 : 1,
                onSelected: (val) {
                  setState(() {
                    if (val == 0) {
                      _rule = const DailyEveryDayRule();
                    } else {
                      _rule = DailyWeekdaysRule(days: _selectedDays.toList());
                    }
                  });
                },
              ),
              if (_rule is DailyWeekdaysRule) ...[
                const SizedBox(height: 12),
                WeekdayToggles(
                  selectedDays: _selectedDays,
                  onChanged: (days) {
                    setState(() {
                      _selectedDays = days;
                      _rule = DailyWeekdaysRule(days: days.toList());
                    });
                  },
                ),
              ],
            ] else if (_cadence == Cadence.weekly) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIMES PER WEEK',
                    style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _timesPerPeriod > 1
                            ? () {
                                setState(() {
                                  _timesPerPeriod--;
                                  _rule = WeeklyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$_timesPerPeriod×',
                        style: tokens.monoText(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _timesPerPeriod < 7
                            ? () {
                                setState(() {
                                  _timesPerPeriod++;
                                  _rule = WeeklyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Calling Domain
            Text(
              'CALLING DOMAIN',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CallingDomain.values.map((domain) {
                final isSelected = _selectedDomain == domain;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDomain = domain),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.tonal : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? tokens.hero : tokens.lineRule,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SigilWidget(domain: domain, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          domain.name.toUpperCase(),
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? tokens.hero : tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Difficulty & Essential Switches
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIFFICULTY',
                        style: tokens.monoText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedControl<Difficulty>(
                        items: const [
                          SegmentItem(value: Difficulty.easy, label: 'Easy'),
                          SegmentItem(value: Difficulty.medium, label: 'Med'),
                          SegmentItem(value: Difficulty.hard, label: 'Hard'),
                        ],
                        selectedValue: _difficulty,
                        onSelected: (d) => setState(() => _difficulty = d),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESSENTIAL',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _essential = !_essential),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _essential ? tokens.hero.withOpacity(0.15) : tokens.tonal,
                          border: Border.all(
                            color: _essential ? tokens.hero : tokens.lineRule,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _essential ? Icons.star : Icons.star_border,
                              size: 18,
                              color: _essential ? tokens.hero : tokens.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _essential ? 'YES' : 'NO',
                              style: tokens.monoText(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _essential ? tokens.hero : tokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Action Button
            ActionButton(
              label: widget.quest == null ? 'CREATE QUEST' : 'SAVE CHANGES',
              onPressed: _saveQuest,
            ),
            if (widget.quest != null) ...[
              const SizedBox(height: 10),
              ActionButton(
                label: 'ARCHIVE QUEST',
                variant: ActionButtonVariant.destructive,
                onPressed: () async {
                  await ref.read(questActionsProvider).archiveQuest(
                        widget.quest!.id,
                        DateTime.now(),
                      );
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
