import 'package:drift/drift.dart';
import '../../domain/engine/schedule_rule.dart';
import 'converters.dart';

@DataClassName('ProfileData')
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  IntColumn get calling => integer().nullable()();
  DateTimeColumn get callingChosenAt => dateTime().nullable()();
  IntColumn get resetMinute => integer().withDefault(const Constant(0))();
  IntColumn get weekStart => integer().withDefault(const Constant(1))();
  IntColumn get themeMode => integer().withDefault(const Constant(0))(); // 0 = system, 1 = dark, 2 = light
  TextColumn get accent => text().withDefault(const Constant('frost'))();
  BoolColumn get digestEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get digestMinute => integer().withDefault(const Constant(540))();
  TextColumn get settledThrough => text().nullable()();
}

@DataClassName('GoalData')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get emoji => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('QuestData')
class Quests extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get rule => text().map(const ScheduleRuleConverter())(); // ScheduleRule JSON string
  IntColumn get targetType => integer().withDefault(const Constant(0))(); // 0 = checkbox, 1 = counter
  IntColumn get targetValue => integer().withDefault(const Constant(1))();
  TextColumn get unit => text().nullable()();
  IntColumn get difficulty => integer().withDefault(const Constant(0))(); // 0 = easy, 1 = medium, 2 = hard
  BoolColumn get essential => boolean().withDefault(const Constant(false))();
  TextColumn get goalId => text().nullable().references(Goals, #id)();
  IntColumn get domain => integer().nullable()(); // CallingDomain
  IntColumn get reminderMinute => integer().nullable()();
  TextColumn get pausedUntil => text().nullable()();
  TextColumn get settledThrough => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompletionData')
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  TextColumn get localDate => text()(); // 'YYYY-MM-DD'
  IntColumn get value => integer().withDefault(const Constant(1))();
  TextColumn get note => text().nullable()();
  TextColumn get timezone => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('XpEventData')
class XpEvents extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()(); // XPEventType (0=quest, 1=perfect_day, 2=perfect_week, 3=milestone, 4=goal)
  TextColumn get ref => text()(); // e.g. completionId, date, range, goalId
  TextColumn get periodRef => text().nullable()(); // e.g. questId|periodKey
  IntColumn get amount => integer()();
  TextColumn get localDate => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {type, ref}
      ];
}

@DataClassName('StreakRepairData')
class StreakRepairs extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  TextColumn get periodKey => text()();
  DateTimeColumn get appliedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {questId, periodKey}
      ];
}

@DataClassName('SeenMomentData')
class SeenMoments extends Table {
  TextColumn get key => text()();
  DateTimeColumn get seenAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('KvData')
class Kvs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()(); // JSON string

  @override
  Set<Column> get primaryKey => {key};
}
