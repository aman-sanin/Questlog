import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
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
import 'goal_editor_sheet.dart';
import 'template_picker_sheet.dart';


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
  Set<int> _weeklyAllowedDays = {1, 2, 3, 4, 5};
  bool _isWeeklyConstrained = false;
  int _timesPerPeriod = 3;
  int _intervalDays = 2;
  LocalDate? _singleTargetDate;

  @override
  void initState() {
    super.initState();
    final q = widget.quest;
    _titleController = TextEditingController(text: q?.title ?? '');
    _unitController = TextEditingController(text: q?.unit ?? '');
    _cadence = q?.rule.cadence ?? Cadence.daily;
    _rule = q?.rule ?? const DailyEveryDayRule();
    if (_rule is DailyIntervalRule) {
      _intervalDays = (_rule as DailyIntervalRule).interval ?? 2;
    }
    if (_rule is WeeklyRule) {
      final wr = _rule as WeeklyRule;
      if (wr.times != null) _timesPerPeriod = wr.times!;
      if (wr.allowedDays != null && wr.allowedDays!.isNotEmpty) {
        _isWeeklyConstrained = true;
        _weeklyAllowedDays = wr.allowedDays!.toSet();
      }
    }
    if (_rule is MonthlyRule) {
      final mr = _rule as MonthlyRule;
      if (mr.times != null) _timesPerPeriod = mr.times!;
    }
    if (_rule is YearlyRule) {
      final yr = _rule as YearlyRule;
      if (yr.times != null) _timesPerPeriod = yr.times!;
    }
    if (_rule is SingleRule) {
      _singleTargetDate = (_rule as SingleRule).targetDate;
    }
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

  Future<void> _updateRuleForCadence(Cadence newCadence) async {
    final tokens = context.tokens;
    if (widget.quest != null && widget.quest!.rule.cadence != newCadence) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: tokens.bg,
          title: Text(
            'RESET STREAK WARNING',
            style: tokens.headline(fontSize: 18, color: tokens.textPrimary),
          ),
          content: Text(
            'Changing cadence resets this quest\'s active streak history. Do you wish to continue?',
            style: tokens.body(fontSize: 14, color: tokens.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('CANCEL', style: tokens.monoText(color: tokens.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('CONFIRM', style: tokens.monoText(color: tokens.accent)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _cadence = newCadence;
      switch (newCadence) {
        case Cadence.daily:
          _rule = const DailyEveryDayRule();
          break;
        case Cadence.weekly:
          _timesPerPeriod = (_timesPerPeriod > 7 || _timesPerPeriod < 1) ? 3 : _timesPerPeriod;
          _rule = WeeklyTimesRule(times: _timesPerPeriod);
          break;
        case Cadence.monthly:
          _timesPerPeriod = _timesPerPeriod.clamp(1, 31);
          _rule = MonthlyTimesRule(times: _timesPerPeriod);
          break;
        case Cadence.yearly:
          _timesPerPeriod = _timesPerPeriod.clamp(1, 365);
          _rule = YearlyTimesRule(times: _timesPerPeriod);
          break;
        case Cadence.single:
          _rule = SingleRule(targetDate: _singleTargetDate);
          break;
      }
    });
  }

  void _toggleEssential() {
    if (!_essential) {
      final activeQuests = ref.read(activeQuestsStreamProvider).value ?? [];
      final essentialCount =
          activeQuests.where((q) => q.essential && q.id != widget.quest?.id).length;

      if (essentialCount >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '6th essential added. High daily load may dilute your focus — start this Monday instead?',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() => _essential = !_essential);
  }

  Future<void> _saveQuest() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final actions = ref.read(questActionsProvider);
    final now = DateTime.now();
    final today = ref.read(effectiveLocalDateProvider);
    final weekStart = ref.read(weekStartProvider);

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
        today: today,
        weekStart: weekStart,
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
        today: today,
        weekStart: weekStart,
        now: now,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.quest == null ? 'NEW QUEST' : 'EDIT QUEST',
                  style: tokens.monoText(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
                if (widget.quest == null)
                  GestureDetector(
                    onTap: () async {
                      final template = await TemplatePickerSheet.show(context);
                      if (template != null && mounted) {
                        setState(() {
                          _titleController.text = template.title;
                          _cadence = template.rule.cadence;
                          _rule = template.rule;
                          _targetType = template.targetType;
                          _targetValue = template.targetValue;
                          _unitController.text = template.unit ?? '';
                          _difficulty = template.difficulty;
                          _essential = template.essential;
                          _selectedDomain = template.domain;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.auto_stories, size: 14, color: tokens.accent),
                        const SizedBox(width: 4),
                        Text(
                          'FROM TEMPLATE',
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tokens.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
                SegmentItem(value: Cadence.single, label: 'Single'),
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
                  SegmentItem(value: 2, label: 'Every N Days'),
                ],
                selectedValue: _rule is DailyEveryDayRule
                    ? 0
                    : (_rule is DailyWeekdaysRule ? 1 : 2),
                onSelected: (val) {
                  setState(() {
                    if (val == 0) {
                      _rule = const DailyEveryDayRule();
                    } else if (val == 1) {
                      _rule = DailyWeekdaysRule(days: _selectedDays.toList());
                    } else {
                      final today = ref.read(effectiveLocalDateProvider);
                      _rule = DailyIntervalRule(count: _intervalDays, anchor: today);
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
              ] else if (_rule is DailyIntervalRule) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REPEAT INTERVAL',
                      style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.remove),
                          onPressed: _intervalDays > 2
                              ? () {
                                  setState(() {
                                    _intervalDays--;
                                    final today = ref.read(effectiveLocalDateProvider);
                                    _rule = DailyIntervalRule(count: _intervalDays, anchor: today);
                                  });
                                }
                              : null,
                        ),
                        Text(
                          'Every $_intervalDays days',
                          style: tokens.monoText(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(Symbols.add),
                          onPressed: _intervalDays < 365
                              ? () {
                                  setState(() {
                                    _intervalDays++;
                                    final today = ref.read(effectiveLocalDateProvider);
                                    _rule = DailyIntervalRule(count: _intervalDays, anchor: today);
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
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
                        icon: const Icon(Symbols.remove),
                        onPressed: _timesPerPeriod > 1
                            ? () {
                                setState(() {
                                  _timesPerPeriod--;
                                  _rule = WeeklyTimesRule(
                                    times: _timesPerPeriod,
                                    allowedDays: _isWeeklyConstrained ? _weeklyAllowedDays.toList() : null,
                                  );
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$_timesPerPeriod×',
                        style: tokens.monoText(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.add),
                        onPressed: _timesPerPeriod < 7
                            ? () {
                                setState(() {
                                  _timesPerPeriod++;
                                  _rule = WeeklyTimesRule(
                                    times: _timesPerPeriod,
                                    allowedDays: _isWeeklyConstrained ? _weeklyAllowedDays.toList() : null,
                                  );
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONSTRAIN TO SPECIFIC DAYS',
                    style: tokens.monoText(fontSize: 11, color: tokens.textSecondary),
                  ),
                  Switch.adaptive(
                    value: _isWeeklyConstrained,
                    activeColor: tokens.accent,
                    onChanged: (val) {
                      setState(() {
                        _isWeeklyConstrained = val;
                        _rule = WeeklyTimesRule(
                          times: _timesPerPeriod,
                          allowedDays: val ? _weeklyAllowedDays.toList() : null,
                        );
                      });
                    },
                  ),
                ],
              ),
              if (_isWeeklyConstrained) ...[
                const SizedBox(height: 8),
                WeekdayToggles(
                  selectedDays: _weeklyAllowedDays,
                  onChanged: (days) {
                    setState(() {
                      _weeklyAllowedDays = days.isEmpty ? {1} : days;
                      _rule = WeeklyTimesRule(
                        times: _timesPerPeriod,
                        allowedDays: _weeklyAllowedDays.toList(),
                      );
                    });
                  },
                ),
              ],
            ] else if (_cadence == Cadence.monthly && _targetType == TargetType.checkbox) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIMES PER MONTH',
                    style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.remove),
                        onPressed: _timesPerPeriod > 1
                            ? () {
                                setState(() {
                                  _timesPerPeriod--;
                                  _rule = MonthlyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$_timesPerPeriod×',
                        style: tokens.monoText(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.add),
                        onPressed: _timesPerPeriod < 31
                            ? () {
                                setState(() {
                                  _timesPerPeriod++;
                                  _rule = MonthlyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_cadence == Cadence.yearly && _targetType == TargetType.checkbox) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIMES PER YEAR',
                    style: tokens.monoText(fontSize: 12, color: tokens.textPrimary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Symbols.remove),
                        onPressed: _timesPerPeriod > 1
                            ? () {
                                setState(() {
                                  _timesPerPeriod--;
                                  _rule = YearlyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$_timesPerPeriod×',
                        style: tokens.monoText(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.add),
                        onPressed: _timesPerPeriod < 365
                            ? () {
                                setState(() {
                                  _timesPerPeriod++;
                                  _rule = YearlyTimesRule(times: _timesPerPeriod);
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ] else if (_cadence == Cadence.single) ...[
              Text(
                'DUE DATE',
                style: tokens.monoText(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final today = ref.read(effectiveLocalDateProvider);
                  final tomorrow = today.addDays(1);
                  final isToday = _singleTargetDate == today;
                  final isTomorrow = _singleTargetDate == tomorrow;
                  final isNone = _singleTargetDate == null;
                  final isCustom = _singleTargetDate != null && !isToday && !isTomorrow;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Today
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _singleTargetDate = today;
                            _rule = SingleRule(targetDate: today);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isToday ? tokens.tonal : Colors.transparent,
                            border: Border.all(
                              color: isToday ? tokens.accent : tokens.lineRule,
                              width: isToday ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            'TODAY',
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isToday ? tokens.accent : tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      // Tomorrow
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _singleTargetDate = tomorrow;
                            _rule = SingleRule(targetDate: tomorrow);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isTomorrow ? tokens.tonal : Colors.transparent,
                            border: Border.all(
                              color: isTomorrow ? tokens.accent : tokens.lineRule,
                              width: isTomorrow ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            'TOMORROW',
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isTomorrow ? tokens.accent : tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      // Custom Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: (_singleTargetDate ?? today).toDateTime(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2099),
                          );
                          if (picked != null && mounted) {
                            final customDate = LocalDate.fromDateTime(picked);
                            setState(() {
                              _singleTargetDate = customDate;
                              _rule = SingleRule(targetDate: customDate);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCustom ? tokens.tonal : Colors.transparent,
                            border: Border.all(
                              color: isCustom ? tokens.accent : tokens.lineRule,
                              width: isCustom ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            isCustom ? _singleTargetDate!.formatted : 'PICK DATE',
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCustom ? tokens.accent : tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      // No Due Date
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _singleTargetDate = null;
                            _rule = const SingleRule();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isNone ? tokens.tonal : Colors.transparent,
                            border: Border.all(
                              color: isNone ? tokens.accent : tokens.lineRule,
                              width: isNone ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            'NO DUE DATE',
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isNone ? tokens.accent : tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 20),

            // Target Section
            Text(
              'TARGET & METRICS',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedControl<TargetType>(
              items: const [
                SegmentItem(value: TargetType.checkbox, label: '✓ Checkbox'),
                SegmentItem(value: TargetType.counter, label: '⊕ Counter'),
              ],
              selectedValue: _targetType,
              onSelected: (t) => setState(() => _targetType = t),
            ),
            if (_targetType == TargetType.counter) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TARGET (N)',
                          style: tokens.monoText(fontSize: 11, color: tokens.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Symbols.remove),
                              onPressed: _targetValue > 1
                                  ? () => setState(() => _targetValue--)
                                  : null,
                            ),
                            Text(
                              '$_targetValue',
                              style: tokens.monoText(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Symbols.add),
                              onPressed: _targetValue < 99
                                  ? () => setState(() => _targetValue++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UNIT (OPTIONAL)',
                          style: tokens.monoText(fontSize: 11, color: tokens.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        AppInput(
                          controller: _unitController,
                          hintText: 'glasses, pages, km',
                        ),
                      ],
                    ),
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
                        color: isSelected ? tokens.accent : tokens.lineRule,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SigilWidget(
                          domain: domain,
                          size: 16,
                          color: isSelected ? tokens.accent : tokens.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          domain.name.toUpperCase(),
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? tokens.accent : tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Linked Goal ──────────────────────────────────────────────────
            const SizedBox(height: 20),
            Text(
              'LINKED GOAL (OPTIONAL)',
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
              children: [
                // NONE chip
                GestureDetector(
                  onTap: () => setState(() => _selectedGoalId = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedGoalId == null ? tokens.tonal : Colors.transparent,
                      border: Border.all(
                        color: _selectedGoalId == null ? tokens.accent : tokens.lineRule,
                        width: _selectedGoalId == null ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      'NONE',
                      style: tokens.monoText(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _selectedGoalId == null ? tokens.accent : tokens.textSecondary,
                      ),
                    ),
                  ),
                ),
                // Existing goals
                ...goals.map((g) {
                  final isSelected = _selectedGoalId == g.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGoalId = g.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.tonal : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? tokens.accent : tokens.lineRule,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        '${g.emoji} ${g.title.toUpperCase()}',
                        style: tokens.monoText(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? tokens.accent : tokens.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
                // + NEW GOAL chip
                GestureDetector(
                  onTap: () async {
                    final newId = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const GoalEditorSheet(),
                    );
                    if (newId != null) {
                      setState(() => _selectedGoalId = newId);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: tokens.lineRule, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.add, size: 13, color: tokens.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'NEW GOAL',
                          style: tokens.monoText(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),



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
                      onTap: _toggleEssential,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _essential ? tokens.accent.withOpacity(0.15) : tokens.tonal,
                          border: Border.all(
                            color: _essential ? tokens.accent : tokens.lineRule,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _essential ? Symbols.star : Symbols.star_border,
                              size: 18,
                              color: _essential ? tokens.accent : tokens.textSecondary,
                              fill: _essential ? 1.0 : 0.0,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _essential ? 'YES' : 'NO',
                              style: tokens.monoText(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _essential ? tokens.accent : tokens.textSecondary,
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
