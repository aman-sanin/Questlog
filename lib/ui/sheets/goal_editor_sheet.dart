import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/database_provider.dart';
import '../../data/db/database.dart';
import '../theme/tokens.dart';
import '../widgets/action_button.dart';
import '../widgets/app_input.dart';

class GoalEditorSheet extends ConsumerStatefulWidget {
  final GoalData? goal;

  const GoalEditorSheet({super.key, this.goal});

  static Future<void> show(BuildContext context, {GoalData? goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GoalEditorSheet(goal: goal),
    );
  }

  @override
  ConsumerState<GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends ConsumerState<GoalEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late String _selectedEmoji;

  static const List<String> _emojis = [
    '🎯', '🏔️', '⚔️', '📜', '🧘', '🔥', '🛡️', '⚡', '🌌', '🚀', '🏹', '💎'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _noteController = TextEditingController(text: widget.goal?.note ?? '');
    _selectedEmoji = widget.goal?.emoji ?? '🎯';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final actions = ref.read(goalActionsProvider);
    final now = DateTime.now();

    if (widget.goal == null) {
      final newId = await actions.createGoal(
        title: title,
        emoji: _selectedEmoji,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        now: now,
      );
      if (mounted) Navigator.of(context).pop(newId); // return new goal id to caller
    } else {
      await actions.updateGoal(
        id: widget.goal!.id,
        title: title,
        emoji: _selectedEmoji,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: widget.goal!.createdAt,
        archivedAt: widget.goal!.archivedAt,
        completedAt: widget.goal!.completedAt,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
            Center(
              child: Container(
                width: 36,
                height: 4,
                color: tokens.lineRule,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.goal == null ? 'NEW GOAL' : 'EDIT GOAL',
              style: tokens.monoText(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            AppInput(
              controller: _titleController,
              hintText: 'Overarching Goal Title',
              autofocus: widget.goal == null,
            ),
            const SizedBox(height: 20),
            Text(
              'EMOJI CREST',
              style: tokens.monoText(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.tonal : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? tokens.accent : tokens.lineRule,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: widget.goal == null ? 'CREATE GOAL' : 'SAVE GOAL',
              onPressed: _saveGoal,
            ),
          ],
        ),
      ),
    );
  }
}
