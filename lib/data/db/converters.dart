import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/engine/schedule_rule.dart';

class ScheduleRuleConverter extends TypeConverter<ScheduleRule, String> {
  const ScheduleRuleConverter();

  @override
  ScheduleRule fromSql(String fromDb) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(fromDb) as Map<String, dynamic>;
      return ScheduleRule.fromJson(decoded);
    } catch (e) {
      return UnsupportedRule({'raw': fromDb, 'error': e.toString()});
    }
  }

  @override
  String toSql(ScheduleRule value) {
    return jsonEncode(value.toJson());
  }
}
