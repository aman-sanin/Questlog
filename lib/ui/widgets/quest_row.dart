import 'package:flutter/material.dart';
import '../../domain/engine/quest_state.dart';
import '../../domain/model/models.dart';
import '../theme/tokens.dart';
import 'checkbox_ring.dart';
import 'chips.dart';
import 'progress_bar.dart';
import 'stepper_widget.dart';

class QuestRow extends StatelessWidget {
  final QuestEvaluation evaluation;
  final VoidCallback? onComplete;
  final VoidCallback? onLongPressCheckbox;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QuestRow({
    super.key,
    required this.evaluation,
    this.onComplete,
    this.onLongPressCheckbox,
    this.onIncrement,
    this.onDecrement,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDone = evaluation.isCompleted;
    final isMissed = evaluation.visualState == QuestVisual.missedEssential;
    final isAtRisk = evaluation.visualState == QuestVisual.atRisk;
    final isPaused = evaluation.visualState == QuestVisual.paused;

    // Card border: turns Ember on completion, resting lineRest otherwise
    final Color borderColor = isDone ? tokens.hero : tokens.lineRest;
    // Opacity: completed rows dim to 55%, paused to 50%
    final double cardOpacity = isDone ? 0.55 : (isPaused ? 0.50 : 1.0);

    Widget leadingControl;
    if (evaluation.targetType == TargetType.counter) {
      leadingControl = StepperWidget(
        current: evaluation.completedValue,
        target: evaluation.target,
        unit: evaluation.unit,
        onIncrement: onIncrement,
        onDecrement: onDecrement,
      );
    } else {
      leadingControl = CheckboxRing(
        isCompleted: isDone,
        isAtRisk: isAtRisk,
        isMissed: isMissed,
        onTap: onComplete,
        onLongPress: onLongPressCheckbox,
      );
    }

    return Opacity(
      opacity: cardOpacity,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            color: tokens.bg,
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading control
                    leadingControl,
                    const SizedBox(width: 14),
                    // Title and metadata stack
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evaluation.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.title(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            evaluation.metaDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.monoText(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isMissed ? tokens.miss : tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Trailing essential star
                    if (evaluation.essential)
                      EssentialStar(
                        isEssential: true,
                      ),
                  ],
                ),
              ),
              // Bottom progress track
              if (evaluation.targetType == TargetType.counter || evaluation.rule.isWindowScheduled)
                ProgressBar(
                  progress: evaluation.progress,
                  height: 3.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
