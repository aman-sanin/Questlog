import 'package:home_widget/home_widget.dart';
import '../../domain/engine/quest_state.dart';

class WidgetService {
  static const String appWidgetProvider = 'QuestLogWidgetProvider';

  Future<void> updateSnapshot({
    required List<QuestEvaluation> evaluations,
    required int streak,
    required String accentHex,
  }) async {
    try {
      final essentialQuests = evaluations.where((e) => e.essential && e.isDueToday).toList();
      final totalDue = evaluations.where((e) => e.isDueToday).length;
      final completedDue = evaluations.where((e) => e.isDueToday && e.isCompleted).length;

      final titles = essentialQuests.take(3).map((e) => e.title).join('\n');

      await HomeWidget.saveWidgetData<int>('total_due', totalDue);
      await HomeWidget.saveWidgetData<int>('completed_due', completedDue);
      await HomeWidget.saveWidgetData<int>('streak', streak);
      await HomeWidget.saveWidgetData<String>('essentials', titles);
      await HomeWidget.saveWidgetData<String>('accent', accentHex);

      await HomeWidget.updateWidget(
        name: appWidgetProvider,
        androidName: appWidgetProvider,
      );
    } catch (_) {
      // Graceful fallback on unsupported platforms / dev runtimes
    }
  }
}
