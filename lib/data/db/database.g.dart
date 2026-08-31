// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callingMeta = const VerificationMeta(
    'calling',
  );
  @override
  late final GeneratedColumn<int> calling = GeneratedColumn<int>(
    'calling',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _callingChosenAtMeta = const VerificationMeta(
    'callingChosenAt',
  );
  @override
  late final GeneratedColumn<DateTime> callingChosenAt =
      GeneratedColumn<DateTime>(
        'calling_chosen_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _resetMinuteMeta = const VerificationMeta(
    'resetMinute',
  );
  @override
  late final GeneratedColumn<int> resetMinute = GeneratedColumn<int>(
    'reset_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<int> weekStart = GeneratedColumn<int>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<int> themeMode = GeneratedColumn<int>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accentMeta = const VerificationMeta('accent');
  @override
  late final GeneratedColumn<String> accent = GeneratedColumn<String>(
    'accent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('frost'),
  );
  static const VerificationMeta _digestEnabledMeta = const VerificationMeta(
    'digestEnabled',
  );
  @override
  late final GeneratedColumn<bool> digestEnabled = GeneratedColumn<bool>(
    'digest_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("digest_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _digestMinuteMeta = const VerificationMeta(
    'digestMinute',
  );
  @override
  late final GeneratedColumn<int> digestMinute = GeneratedColumn<int>(
    'digest_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(540),
  );
  static const VerificationMeta _settledThroughMeta = const VerificationMeta(
    'settledThrough',
  );
  @override
  late final GeneratedColumn<String> settledThrough = GeneratedColumn<String>(
    'settled_through',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    calling,
    callingChosenAt,
    resetMinute,
    weekStart,
    themeMode,
    accent,
    digestEnabled,
    digestMinute,
    settledThrough,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('calling')) {
      context.handle(
        _callingMeta,
        calling.isAcceptableOrUnknown(data['calling']!, _callingMeta),
      );
    }
    if (data.containsKey('calling_chosen_at')) {
      context.handle(
        _callingChosenAtMeta,
        callingChosenAt.isAcceptableOrUnknown(
          data['calling_chosen_at']!,
          _callingChosenAtMeta,
        ),
      );
    }
    if (data.containsKey('reset_minute')) {
      context.handle(
        _resetMinuteMeta,
        resetMinute.isAcceptableOrUnknown(
          data['reset_minute']!,
          _resetMinuteMeta,
        ),
      );
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('accent')) {
      context.handle(
        _accentMeta,
        accent.isAcceptableOrUnknown(data['accent']!, _accentMeta),
      );
    }
    if (data.containsKey('digest_enabled')) {
      context.handle(
        _digestEnabledMeta,
        digestEnabled.isAcceptableOrUnknown(
          data['digest_enabled']!,
          _digestEnabledMeta,
        ),
      );
    }
    if (data.containsKey('digest_minute')) {
      context.handle(
        _digestMinuteMeta,
        digestMinute.isAcceptableOrUnknown(
          data['digest_minute']!,
          _digestMinuteMeta,
        ),
      );
    }
    if (data.containsKey('settled_through')) {
      context.handle(
        _settledThroughMeta,
        settledThrough.isAcceptableOrUnknown(
          data['settled_through']!,
          _settledThroughMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      calling: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calling'],
      ),
      callingChosenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calling_chosen_at'],
      ),
      resetMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reset_minute'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theme_mode'],
      )!,
      accent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent'],
      )!,
      digestEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}digest_enabled'],
      )!,
      digestMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}digest_minute'],
      )!,
      settledThrough: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settled_through'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String? name;
  final int? calling;
  final DateTime? callingChosenAt;
  final int resetMinute;
  final int weekStart;
  final int themeMode;
  final String accent;
  final bool digestEnabled;
  final int digestMinute;
  final String? settledThrough;
  const ProfileData({
    required this.id,
    this.name,
    this.calling,
    this.callingChosenAt,
    required this.resetMinute,
    required this.weekStart,
    required this.themeMode,
    required this.accent,
    required this.digestEnabled,
    required this.digestMinute,
    this.settledThrough,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || calling != null) {
      map['calling'] = Variable<int>(calling);
    }
    if (!nullToAbsent || callingChosenAt != null) {
      map['calling_chosen_at'] = Variable<DateTime>(callingChosenAt);
    }
    map['reset_minute'] = Variable<int>(resetMinute);
    map['week_start'] = Variable<int>(weekStart);
    map['theme_mode'] = Variable<int>(themeMode);
    map['accent'] = Variable<String>(accent);
    map['digest_enabled'] = Variable<bool>(digestEnabled);
    map['digest_minute'] = Variable<int>(digestMinute);
    if (!nullToAbsent || settledThrough != null) {
      map['settled_through'] = Variable<String>(settledThrough);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      calling: calling == null && nullToAbsent
          ? const Value.absent()
          : Value(calling),
      callingChosenAt: callingChosenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(callingChosenAt),
      resetMinute: Value(resetMinute),
      weekStart: Value(weekStart),
      themeMode: Value(themeMode),
      accent: Value(accent),
      digestEnabled: Value(digestEnabled),
      digestMinute: Value(digestMinute),
      settledThrough: settledThrough == null && nullToAbsent
          ? const Value.absent()
          : Value(settledThrough),
    );
  }

  factory ProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      calling: serializer.fromJson<int?>(json['calling']),
      callingChosenAt: serializer.fromJson<DateTime?>(json['callingChosenAt']),
      resetMinute: serializer.fromJson<int>(json['resetMinute']),
      weekStart: serializer.fromJson<int>(json['weekStart']),
      themeMode: serializer.fromJson<int>(json['themeMode']),
      accent: serializer.fromJson<String>(json['accent']),
      digestEnabled: serializer.fromJson<bool>(json['digestEnabled']),
      digestMinute: serializer.fromJson<int>(json['digestMinute']),
      settledThrough: serializer.fromJson<String?>(json['settledThrough']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'calling': serializer.toJson<int?>(calling),
      'callingChosenAt': serializer.toJson<DateTime?>(callingChosenAt),
      'resetMinute': serializer.toJson<int>(resetMinute),
      'weekStart': serializer.toJson<int>(weekStart),
      'themeMode': serializer.toJson<int>(themeMode),
      'accent': serializer.toJson<String>(accent),
      'digestEnabled': serializer.toJson<bool>(digestEnabled),
      'digestMinute': serializer.toJson<int>(digestMinute),
      'settledThrough': serializer.toJson<String?>(settledThrough),
    };
  }

  ProfileData copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    Value<int?> calling = const Value.absent(),
    Value<DateTime?> callingChosenAt = const Value.absent(),
    int? resetMinute,
    int? weekStart,
    int? themeMode,
    String? accent,
    bool? digestEnabled,
    int? digestMinute,
    Value<String?> settledThrough = const Value.absent(),
  }) => ProfileData(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    calling: calling.present ? calling.value : this.calling,
    callingChosenAt: callingChosenAt.present
        ? callingChosenAt.value
        : this.callingChosenAt,
    resetMinute: resetMinute ?? this.resetMinute,
    weekStart: weekStart ?? this.weekStart,
    themeMode: themeMode ?? this.themeMode,
    accent: accent ?? this.accent,
    digestEnabled: digestEnabled ?? this.digestEnabled,
    digestMinute: digestMinute ?? this.digestMinute,
    settledThrough: settledThrough.present
        ? settledThrough.value
        : this.settledThrough,
  );
  ProfileData copyWithCompanion(ProfilesCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      calling: data.calling.present ? data.calling.value : this.calling,
      callingChosenAt: data.callingChosenAt.present
          ? data.callingChosenAt.value
          : this.callingChosenAt,
      resetMinute: data.resetMinute.present
          ? data.resetMinute.value
          : this.resetMinute,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      accent: data.accent.present ? data.accent.value : this.accent,
      digestEnabled: data.digestEnabled.present
          ? data.digestEnabled.value
          : this.digestEnabled,
      digestMinute: data.digestMinute.present
          ? data.digestMinute.value
          : this.digestMinute,
      settledThrough: data.settledThrough.present
          ? data.settledThrough.value
          : this.settledThrough,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calling: $calling, ')
          ..write('callingChosenAt: $callingChosenAt, ')
          ..write('resetMinute: $resetMinute, ')
          ..write('weekStart: $weekStart, ')
          ..write('themeMode: $themeMode, ')
          ..write('accent: $accent, ')
          ..write('digestEnabled: $digestEnabled, ')
          ..write('digestMinute: $digestMinute, ')
          ..write('settledThrough: $settledThrough')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    calling,
    callingChosenAt,
    resetMinute,
    weekStart,
    themeMode,
    accent,
    digestEnabled,
    digestMinute,
    settledThrough,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.calling == this.calling &&
          other.callingChosenAt == this.callingChosenAt &&
          other.resetMinute == this.resetMinute &&
          other.weekStart == this.weekStart &&
          other.themeMode == this.themeMode &&
          other.accent == this.accent &&
          other.digestEnabled == this.digestEnabled &&
          other.digestMinute == this.digestMinute &&
          other.settledThrough == this.settledThrough);
}

class ProfilesCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String?> name;
  final Value<int?> calling;
  final Value<DateTime?> callingChosenAt;
  final Value<int> resetMinute;
  final Value<int> weekStart;
  final Value<int> themeMode;
  final Value<String> accent;
  final Value<bool> digestEnabled;
  final Value<int> digestMinute;
  final Value<String?> settledThrough;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calling = const Value.absent(),
    this.callingChosenAt = const Value.absent(),
    this.resetMinute = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accent = const Value.absent(),
    this.digestEnabled = const Value.absent(),
    this.digestMinute = const Value.absent(),
    this.settledThrough = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.calling = const Value.absent(),
    this.callingChosenAt = const Value.absent(),
    this.resetMinute = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accent = const Value.absent(),
    this.digestEnabled = const Value.absent(),
    this.digestMinute = const Value.absent(),
    this.settledThrough = const Value.absent(),
  });
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? calling,
    Expression<DateTime>? callingChosenAt,
    Expression<int>? resetMinute,
    Expression<int>? weekStart,
    Expression<int>? themeMode,
    Expression<String>? accent,
    Expression<bool>? digestEnabled,
    Expression<int>? digestMinute,
    Expression<String>? settledThrough,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (calling != null) 'calling': calling,
      if (callingChosenAt != null) 'calling_chosen_at': callingChosenAt,
      if (resetMinute != null) 'reset_minute': resetMinute,
      if (weekStart != null) 'week_start': weekStart,
      if (themeMode != null) 'theme_mode': themeMode,
      if (accent != null) 'accent': accent,
      if (digestEnabled != null) 'digest_enabled': digestEnabled,
      if (digestMinute != null) 'digest_minute': digestMinute,
      if (settledThrough != null) 'settled_through': settledThrough,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<int?>? calling,
    Value<DateTime?>? callingChosenAt,
    Value<int>? resetMinute,
    Value<int>? weekStart,
    Value<int>? themeMode,
    Value<String>? accent,
    Value<bool>? digestEnabled,
    Value<int>? digestMinute,
    Value<String?>? settledThrough,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      calling: calling ?? this.calling,
      callingChosenAt: callingChosenAt ?? this.callingChosenAt,
      resetMinute: resetMinute ?? this.resetMinute,
      weekStart: weekStart ?? this.weekStart,
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      digestEnabled: digestEnabled ?? this.digestEnabled,
      digestMinute: digestMinute ?? this.digestMinute,
      settledThrough: settledThrough ?? this.settledThrough,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calling.present) {
      map['calling'] = Variable<int>(calling.value);
    }
    if (callingChosenAt.present) {
      map['calling_chosen_at'] = Variable<DateTime>(callingChosenAt.value);
    }
    if (resetMinute.present) {
      map['reset_minute'] = Variable<int>(resetMinute.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<int>(weekStart.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<int>(themeMode.value);
    }
    if (accent.present) {
      map['accent'] = Variable<String>(accent.value);
    }
    if (digestEnabled.present) {
      map['digest_enabled'] = Variable<bool>(digestEnabled.value);
    }
    if (digestMinute.present) {
      map['digest_minute'] = Variable<int>(digestMinute.value);
    }
    if (settledThrough.present) {
      map['settled_through'] = Variable<String>(settledThrough.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('calling: $calling, ')
          ..write('callingChosenAt: $callingChosenAt, ')
          ..write('resetMinute: $resetMinute, ')
          ..write('weekStart: $weekStart, ')
          ..write('themeMode: $themeMode, ')
          ..write('accent: $accent, ')
          ..write('digestEnabled: $digestEnabled, ')
          ..write('digestMinute: $digestMinute, ')
          ..write('settledThrough: $settledThrough')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    emoji,
    note,
    createdAt,
    archivedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalData extends DataClass implements Insertable<GoalData> {
  final String id;
  final String title;
  final String emoji;
  final String? note;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final DateTime? completedAt;
  const GoalData({
    required this.id,
    required this.title,
    required this.emoji,
    this.note,
    required this.createdAt,
    this.archivedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['emoji'] = Variable<String>(emoji);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      emoji: Value(emoji),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory GoalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      emoji: serializer.fromJson<String>(json['emoji']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'emoji': serializer.toJson<String>(emoji),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  GoalData copyWith({
    String? id,
    String? title,
    String? emoji,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => GoalData(
    id: id ?? this.id,
    title: title ?? this.title,
    emoji: emoji ?? this.emoji,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  GoalData copyWithCompanion(GoalsCompanion data) {
    return GoalData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, emoji, note, createdAt, archivedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalData &&
          other.id == this.id &&
          other.title == this.title &&
          other.emoji == this.emoji &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt &&
          other.completedAt == this.completedAt);
}

class GoalsCompanion extends UpdateCompanion<GoalData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> emoji;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.emoji = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String title,
    required String emoji,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       emoji = Value(emoji),
       createdAt = Value(createdAt);
  static Insertable<GoalData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? emoji,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (emoji != null) 'emoji': emoji,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? emoji,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, QuestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleRule, String> rule =
      GeneratedColumn<String>(
        'rule',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ScheduleRule>($QuestsTable.$converterrule);
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<int> targetType = GeneratedColumn<int>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _essentialMeta = const VerificationMeta(
    'essential',
  );
  @override
  late final GeneratedColumn<bool> essential = GeneratedColumn<bool>(
    'essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("essential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id)',
    ),
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<int> domain = GeneratedColumn<int>(
    'domain',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedUntilMeta = const VerificationMeta(
    'pausedUntil',
  );
  @override
  late final GeneratedColumn<String> pausedUntil = GeneratedColumn<String>(
    'paused_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledThroughMeta = const VerificationMeta(
    'settledThrough',
  );
  @override
  late final GeneratedColumn<String> settledThrough = GeneratedColumn<String>(
    'settled_through',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    note,
    rule,
    targetType,
    targetValue,
    unit,
    difficulty,
    essential,
    goalId,
    domain,
    reminderMinute,
    pausedUntil,
    settledThrough,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('essential')) {
      context.handle(
        _essentialMeta,
        essential.isAcceptableOrUnknown(data['essential']!, _essentialMeta),
      );
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('paused_until')) {
      context.handle(
        _pausedUntilMeta,
        pausedUntil.isAcceptableOrUnknown(
          data['paused_until']!,
          _pausedUntilMeta,
        ),
      );
    }
    if (data.containsKey('settled_through')) {
      context.handle(
        _settledThroughMeta,
        settledThrough.isAcceptableOrUnknown(
          data['settled_through']!,
          _settledThroughMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      rule: $QuestsTable.$converterrule.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rule'],
        )!,
      ),
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      essential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}essential'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      ),
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}domain'],
      ),
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      ),
      pausedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paused_until'],
      ),
      settledThrough: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settled_through'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }

  static TypeConverter<ScheduleRule, String> $converterrule =
      const ScheduleRuleConverter();
}

class QuestData extends DataClass implements Insertable<QuestData> {
  final String id;
  final String title;
  final String? note;
  final ScheduleRule rule;
  final int targetType;
  final int targetValue;
  final String? unit;
  final int difficulty;
  final bool essential;
  final String? goalId;
  final int? domain;
  final int? reminderMinute;
  final String? pausedUntil;
  final String? settledThrough;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const QuestData({
    required this.id,
    required this.title,
    this.note,
    required this.rule,
    required this.targetType,
    required this.targetValue,
    this.unit,
    required this.difficulty,
    required this.essential,
    this.goalId,
    this.domain,
    this.reminderMinute,
    this.pausedUntil,
    this.settledThrough,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['rule'] = Variable<String>($QuestsTable.$converterrule.toSql(rule));
    }
    map['target_type'] = Variable<int>(targetType);
    map['target_value'] = Variable<int>(targetValue);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['difficulty'] = Variable<int>(difficulty);
    map['essential'] = Variable<bool>(essential);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<String>(goalId);
    }
    if (!nullToAbsent || domain != null) {
      map['domain'] = Variable<int>(domain);
    }
    if (!nullToAbsent || reminderMinute != null) {
      map['reminder_minute'] = Variable<int>(reminderMinute);
    }
    if (!nullToAbsent || pausedUntil != null) {
      map['paused_until'] = Variable<String>(pausedUntil);
    }
    if (!nullToAbsent || settledThrough != null) {
      map['settled_through'] = Variable<String>(settledThrough);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      rule: Value(rule),
      targetType: Value(targetType),
      targetValue: Value(targetValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      difficulty: Value(difficulty),
      essential: Value(essential),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      domain: domain == null && nullToAbsent
          ? const Value.absent()
          : Value(domain),
      reminderMinute: reminderMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinute),
      pausedUntil: pausedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedUntil),
      settledThrough: settledThrough == null && nullToAbsent
          ? const Value.absent()
          : Value(settledThrough),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory QuestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      rule: serializer.fromJson<ScheduleRule>(json['rule']),
      targetType: serializer.fromJson<int>(json['targetType']),
      targetValue: serializer.fromJson<int>(json['targetValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      essential: serializer.fromJson<bool>(json['essential']),
      goalId: serializer.fromJson<String?>(json['goalId']),
      domain: serializer.fromJson<int?>(json['domain']),
      reminderMinute: serializer.fromJson<int?>(json['reminderMinute']),
      pausedUntil: serializer.fromJson<String?>(json['pausedUntil']),
      settledThrough: serializer.fromJson<String?>(json['settledThrough']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'rule': serializer.toJson<ScheduleRule>(rule),
      'targetType': serializer.toJson<int>(targetType),
      'targetValue': serializer.toJson<int>(targetValue),
      'unit': serializer.toJson<String?>(unit),
      'difficulty': serializer.toJson<int>(difficulty),
      'essential': serializer.toJson<bool>(essential),
      'goalId': serializer.toJson<String?>(goalId),
      'domain': serializer.toJson<int?>(domain),
      'reminderMinute': serializer.toJson<int?>(reminderMinute),
      'pausedUntil': serializer.toJson<String?>(pausedUntil),
      'settledThrough': serializer.toJson<String?>(settledThrough),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  QuestData copyWith({
    String? id,
    String? title,
    Value<String?> note = const Value.absent(),
    ScheduleRule? rule,
    int? targetType,
    int? targetValue,
    Value<String?> unit = const Value.absent(),
    int? difficulty,
    bool? essential,
    Value<String?> goalId = const Value.absent(),
    Value<int?> domain = const Value.absent(),
    Value<int?> reminderMinute = const Value.absent(),
    Value<String?> pausedUntil = const Value.absent(),
    Value<String?> settledThrough = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => QuestData(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    rule: rule ?? this.rule,
    targetType: targetType ?? this.targetType,
    targetValue: targetValue ?? this.targetValue,
    unit: unit.present ? unit.value : this.unit,
    difficulty: difficulty ?? this.difficulty,
    essential: essential ?? this.essential,
    goalId: goalId.present ? goalId.value : this.goalId,
    domain: domain.present ? domain.value : this.domain,
    reminderMinute: reminderMinute.present
        ? reminderMinute.value
        : this.reminderMinute,
    pausedUntil: pausedUntil.present ? pausedUntil.value : this.pausedUntil,
    settledThrough: settledThrough.present
        ? settledThrough.value
        : this.settledThrough,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  QuestData copyWithCompanion(QuestsCompanion data) {
    return QuestData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      rule: data.rule.present ? data.rule.value : this.rule,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      essential: data.essential.present ? data.essential.value : this.essential,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      domain: data.domain.present ? data.domain.value : this.domain,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      pausedUntil: data.pausedUntil.present
          ? data.pausedUntil.value
          : this.pausedUntil,
      settledThrough: data.settledThrough.present
          ? data.settledThrough.value
          : this.settledThrough,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('rule: $rule, ')
          ..write('targetType: $targetType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('difficulty: $difficulty, ')
          ..write('essential: $essential, ')
          ..write('goalId: $goalId, ')
          ..write('domain: $domain, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('settledThrough: $settledThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    note,
    rule,
    targetType,
    targetValue,
    unit,
    difficulty,
    essential,
    goalId,
    domain,
    reminderMinute,
    pausedUntil,
    settledThrough,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestData &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.rule == this.rule &&
          other.targetType == this.targetType &&
          other.targetValue == this.targetValue &&
          other.unit == this.unit &&
          other.difficulty == this.difficulty &&
          other.essential == this.essential &&
          other.goalId == this.goalId &&
          other.domain == this.domain &&
          other.reminderMinute == this.reminderMinute &&
          other.pausedUntil == this.pausedUntil &&
          other.settledThrough == this.settledThrough &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class QuestsCompanion extends UpdateCompanion<QuestData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> note;
  final Value<ScheduleRule> rule;
  final Value<int> targetType;
  final Value<int> targetValue;
  final Value<String?> unit;
  final Value<int> difficulty;
  final Value<bool> essential;
  final Value<String?> goalId;
  final Value<int?> domain;
  final Value<int?> reminderMinute;
  final Value<String?> pausedUntil;
  final Value<String?> settledThrough;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.rule = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.essential = const Value.absent(),
    this.goalId = const Value.absent(),
    this.domain = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.pausedUntil = const Value.absent(),
    this.settledThrough = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestsCompanion.insert({
    required String id,
    required String title,
    this.note = const Value.absent(),
    required ScheduleRule rule,
    this.targetType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.essential = const Value.absent(),
    this.goalId = const Value.absent(),
    this.domain = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.pausedUntil = const Value.absent(),
    this.settledThrough = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       rule = Value(rule),
       createdAt = Value(createdAt);
  static Insertable<QuestData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? rule,
    Expression<int>? targetType,
    Expression<int>? targetValue,
    Expression<String>? unit,
    Expression<int>? difficulty,
    Expression<bool>? essential,
    Expression<String>? goalId,
    Expression<int>? domain,
    Expression<int>? reminderMinute,
    Expression<String>? pausedUntil,
    Expression<String>? settledThrough,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (rule != null) 'rule': rule,
      if (targetType != null) 'target_type': targetType,
      if (targetValue != null) 'target_value': targetValue,
      if (unit != null) 'unit': unit,
      if (difficulty != null) 'difficulty': difficulty,
      if (essential != null) 'essential': essential,
      if (goalId != null) 'goal_id': goalId,
      if (domain != null) 'domain': domain,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (pausedUntil != null) 'paused_until': pausedUntil,
      if (settledThrough != null) 'settled_through': settledThrough,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? note,
    Value<ScheduleRule>? rule,
    Value<int>? targetType,
    Value<int>? targetValue,
    Value<String?>? unit,
    Value<int>? difficulty,
    Value<bool>? essential,
    Value<String?>? goalId,
    Value<int?>? domain,
    Value<int?>? reminderMinute,
    Value<String?>? pausedUntil,
    Value<String?>? settledThrough,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      rule: rule ?? this.rule,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      difficulty: difficulty ?? this.difficulty,
      essential: essential ?? this.essential,
      goalId: goalId ?? this.goalId,
      domain: domain ?? this.domain,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      settledThrough: settledThrough ?? this.settledThrough,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rule.present) {
      map['rule'] = Variable<String>(
        $QuestsTable.$converterrule.toSql(rule.value),
      );
    }
    if (targetType.present) {
      map['target_type'] = Variable<int>(targetType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (essential.present) {
      map['essential'] = Variable<bool>(essential.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<int>(domain.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (pausedUntil.present) {
      map['paused_until'] = Variable<String>(pausedUntil.value);
    }
    if (settledThrough.present) {
      map['settled_through'] = Variable<String>(settledThrough.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('rule: $rule, ')
          ..write('targetType: $targetType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('difficulty: $difficulty, ')
          ..write('essential: $essential, ')
          ..write('goalId: $goalId, ')
          ..write('domain: $domain, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('pausedUntil: $pausedUntil, ')
          ..write('settledThrough: $settledThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, CompletionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quests (id)',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questId,
    localDate,
    value,
    note,
    timezone,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class CompletionData extends DataClass implements Insertable<CompletionData> {
  final String id;
  final String questId;
  final String localDate;
  final int value;
  final String? note;
  final String timezone;
  final DateTime createdAt;
  const CompletionData({
    required this.id,
    required this.questId,
    required this.localDate,
    required this.value,
    this.note,
    required this.timezone,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quest_id'] = Variable<String>(questId);
    map['local_date'] = Variable<String>(localDate);
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['timezone'] = Variable<String>(timezone);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      questId: Value(questId),
      localDate: Value(localDate),
      value: Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      timezone: Value(timezone),
      createdAt: Value(createdAt),
    );
  }

  factory CompletionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionData(
      id: serializer.fromJson<String>(json['id']),
      questId: serializer.fromJson<String>(json['questId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      value: serializer.fromJson<int>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questId': serializer.toJson<String>(questId),
      'localDate': serializer.toJson<String>(localDate),
      'value': serializer.toJson<int>(value),
      'note': serializer.toJson<String?>(note),
      'timezone': serializer.toJson<String>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CompletionData copyWith({
    String? id,
    String? questId,
    String? localDate,
    int? value,
    Value<String?> note = const Value.absent(),
    String? timezone,
    DateTime? createdAt,
  }) => CompletionData(
    id: id ?? this.id,
    questId: questId ?? this.questId,
    localDate: localDate ?? this.localDate,
    value: value ?? this.value,
    note: note.present ? note.value : this.note,
    timezone: timezone ?? this.timezone,
    createdAt: createdAt ?? this.createdAt,
  );
  CompletionData copyWithCompanion(CompletionsCompanion data) {
    return CompletionData(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionData(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('localDate: $localDate, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, questId, localDate, value, note, timezone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionData &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.localDate == this.localDate &&
          other.value == this.value &&
          other.note == this.note &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt);
}

class CompletionsCompanion extends UpdateCompanion<CompletionData> {
  final Value<String> id;
  final Value<String> questId;
  final Value<String> localDate;
  final Value<int> value;
  final Value<String?> note;
  final Value<String> timezone;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    required String questId,
    required String localDate,
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    required String timezone,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questId = Value(questId),
       localDate = Value(localDate),
       timezone = Value(timezone),
       createdAt = Value(createdAt);
  static Insertable<CompletionData> custom({
    Expression<String>? id,
    Expression<String>? questId,
    Expression<String>? localDate,
    Expression<int>? value,
    Expression<String>? note,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (localDate != null) 'local_date': localDate,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questId,
    Value<String>? localDate,
    Value<int>? value,
    Value<String?>? note,
    Value<String>? timezone,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      localDate: localDate ?? this.localDate,
      value: value ?? this.value,
      note: note ?? this.note,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('localDate: $localDate, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $XpEventsTable extends XpEvents
    with TableInfo<$XpEventsTable, XpEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodRefMeta = const VerificationMeta(
    'periodRef',
  );
  @override
  late final GeneratedColumn<String> periodRef = GeneratedColumn<String>(
    'period_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    ref,
    periodRef,
    amount,
    localDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<XpEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('period_ref')) {
      context.handle(
        _periodRefMeta,
        periodRef.isAcceptableOrUnknown(data['period_ref']!, _periodRefMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, ref},
  ];
  @override
  XpEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEventData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      periodRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_ref'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $XpEventsTable createAlias(String alias) {
    return $XpEventsTable(attachedDatabase, alias);
  }
}

class XpEventData extends DataClass implements Insertable<XpEventData> {
  final String id;
  final int type;
  final String ref;
  final String? periodRef;
  final int amount;
  final String localDate;
  final DateTime createdAt;
  const XpEventData({
    required this.id,
    required this.type,
    required this.ref,
    this.periodRef,
    required this.amount,
    required this.localDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    map['ref'] = Variable<String>(ref);
    if (!nullToAbsent || periodRef != null) {
      map['period_ref'] = Variable<String>(periodRef);
    }
    map['amount'] = Variable<int>(amount);
    map['local_date'] = Variable<String>(localDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  XpEventsCompanion toCompanion(bool nullToAbsent) {
    return XpEventsCompanion(
      id: Value(id),
      type: Value(type),
      ref: Value(ref),
      periodRef: periodRef == null && nullToAbsent
          ? const Value.absent()
          : Value(periodRef),
      amount: Value(amount),
      localDate: Value(localDate),
      createdAt: Value(createdAt),
    );
  }

  factory XpEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEventData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      ref: serializer.fromJson<String>(json['ref']),
      periodRef: serializer.fromJson<String?>(json['periodRef']),
      amount: serializer.fromJson<int>(json['amount']),
      localDate: serializer.fromJson<String>(json['localDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'ref': serializer.toJson<String>(ref),
      'periodRef': serializer.toJson<String?>(periodRef),
      'amount': serializer.toJson<int>(amount),
      'localDate': serializer.toJson<String>(localDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  XpEventData copyWith({
    String? id,
    int? type,
    String? ref,
    Value<String?> periodRef = const Value.absent(),
    int? amount,
    String? localDate,
    DateTime? createdAt,
  }) => XpEventData(
    id: id ?? this.id,
    type: type ?? this.type,
    ref: ref ?? this.ref,
    periodRef: periodRef.present ? periodRef.value : this.periodRef,
    amount: amount ?? this.amount,
    localDate: localDate ?? this.localDate,
    createdAt: createdAt ?? this.createdAt,
  );
  XpEventData copyWithCompanion(XpEventsCompanion data) {
    return XpEventData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      ref: data.ref.present ? data.ref.value : this.ref,
      periodRef: data.periodRef.present ? data.periodRef.value : this.periodRef,
      amount: data.amount.present ? data.amount.value : this.amount,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEventData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('ref: $ref, ')
          ..write('periodRef: $periodRef, ')
          ..write('amount: $amount, ')
          ..write('localDate: $localDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, ref, periodRef, amount, localDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEventData &&
          other.id == this.id &&
          other.type == this.type &&
          other.ref == this.ref &&
          other.periodRef == this.periodRef &&
          other.amount == this.amount &&
          other.localDate == this.localDate &&
          other.createdAt == this.createdAt);
}

class XpEventsCompanion extends UpdateCompanion<XpEventData> {
  final Value<String> id;
  final Value<int> type;
  final Value<String> ref;
  final Value<String?> periodRef;
  final Value<int> amount;
  final Value<String> localDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const XpEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.ref = const Value.absent(),
    this.periodRef = const Value.absent(),
    this.amount = const Value.absent(),
    this.localDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  XpEventsCompanion.insert({
    required String id,
    required int type,
    required String ref,
    this.periodRef = const Value.absent(),
    required int amount,
    required String localDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       ref = Value(ref),
       amount = Value(amount),
       localDate = Value(localDate),
       createdAt = Value(createdAt);
  static Insertable<XpEventData> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<String>? ref,
    Expression<String>? periodRef,
    Expression<int>? amount,
    Expression<String>? localDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (ref != null) 'ref': ref,
      if (periodRef != null) 'period_ref': periodRef,
      if (amount != null) 'amount': amount,
      if (localDate != null) 'local_date': localDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  XpEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<String>? ref,
    Value<String?>? periodRef,
    Value<int>? amount,
    Value<String>? localDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return XpEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      ref: ref ?? this.ref,
      periodRef: periodRef ?? this.periodRef,
      amount: amount ?? this.amount,
      localDate: localDate ?? this.localDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (periodRef.present) {
      map['period_ref'] = Variable<String>(periodRef.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('ref: $ref, ')
          ..write('periodRef: $periodRef, ')
          ..write('amount: $amount, ')
          ..write('localDate: $localDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakRepairsTable extends StreakRepairs
    with TableInfo<$StreakRepairsTable, StreakRepairData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakRepairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quests (id)',
    ),
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, questId, periodKey, appliedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_repairs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakRepairData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {questId, periodKey},
  ];
  @override
  StreakRepairData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakRepairData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
    );
  }

  @override
  $StreakRepairsTable createAlias(String alias) {
    return $StreakRepairsTable(attachedDatabase, alias);
  }
}

class StreakRepairData extends DataClass
    implements Insertable<StreakRepairData> {
  final String id;
  final String questId;
  final String periodKey;
  final DateTime appliedAt;
  const StreakRepairData({
    required this.id,
    required this.questId,
    required this.periodKey,
    required this.appliedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quest_id'] = Variable<String>(questId);
    map['period_key'] = Variable<String>(periodKey);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    return map;
  }

  StreakRepairsCompanion toCompanion(bool nullToAbsent) {
    return StreakRepairsCompanion(
      id: Value(id),
      questId: Value(questId),
      periodKey: Value(periodKey),
      appliedAt: Value(appliedAt),
    );
  }

  factory StreakRepairData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakRepairData(
      id: serializer.fromJson<String>(json['id']),
      questId: serializer.fromJson<String>(json['questId']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questId': serializer.toJson<String>(questId),
      'periodKey': serializer.toJson<String>(periodKey),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
    };
  }

  StreakRepairData copyWith({
    String? id,
    String? questId,
    String? periodKey,
    DateTime? appliedAt,
  }) => StreakRepairData(
    id: id ?? this.id,
    questId: questId ?? this.questId,
    periodKey: periodKey ?? this.periodKey,
    appliedAt: appliedAt ?? this.appliedAt,
  );
  StreakRepairData copyWithCompanion(StreakRepairsCompanion data) {
    return StreakRepairData(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakRepairData(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('periodKey: $periodKey, ')
          ..write('appliedAt: $appliedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questId, periodKey, appliedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakRepairData &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.periodKey == this.periodKey &&
          other.appliedAt == this.appliedAt);
}

class StreakRepairsCompanion extends UpdateCompanion<StreakRepairData> {
  final Value<String> id;
  final Value<String> questId;
  final Value<String> periodKey;
  final Value<DateTime> appliedAt;
  final Value<int> rowid;
  const StreakRepairsCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreakRepairsCompanion.insert({
    required String id,
    required String questId,
    required String periodKey,
    required DateTime appliedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questId = Value(questId),
       periodKey = Value(periodKey),
       appliedAt = Value(appliedAt);
  static Insertable<StreakRepairData> custom({
    Expression<String>? id,
    Expression<String>? questId,
    Expression<String>? periodKey,
    Expression<DateTime>? appliedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (periodKey != null) 'period_key': periodKey,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreakRepairsCompanion copyWith({
    Value<String>? id,
    Value<String>? questId,
    Value<String>? periodKey,
    Value<DateTime>? appliedAt,
    Value<int>? rowid,
  }) {
    return StreakRepairsCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      periodKey: periodKey ?? this.periodKey,
      appliedAt: appliedAt ?? this.appliedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakRepairsCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('periodKey: $periodKey, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeenMomentsTable extends SeenMoments
    with TableInfo<$SeenMomentsTable, SeenMomentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeenMomentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<DateTime> seenAt = GeneratedColumn<DateTime>(
    'seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, seenAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seen_moments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeenMomentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(
        _seenAtMeta,
        seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_seenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SeenMomentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeenMomentData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_at'],
      )!,
    );
  }

  @override
  $SeenMomentsTable createAlias(String alias) {
    return $SeenMomentsTable(attachedDatabase, alias);
  }
}

class SeenMomentData extends DataClass implements Insertable<SeenMomentData> {
  final String key;
  final DateTime seenAt;
  const SeenMomentData({required this.key, required this.seenAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['seen_at'] = Variable<DateTime>(seenAt);
    return map;
  }

  SeenMomentsCompanion toCompanion(bool nullToAbsent) {
    return SeenMomentsCompanion(key: Value(key), seenAt: Value(seenAt));
  }

  factory SeenMomentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeenMomentData(
      key: serializer.fromJson<String>(json['key']),
      seenAt: serializer.fromJson<DateTime>(json['seenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'seenAt': serializer.toJson<DateTime>(seenAt),
    };
  }

  SeenMomentData copyWith({String? key, DateTime? seenAt}) =>
      SeenMomentData(key: key ?? this.key, seenAt: seenAt ?? this.seenAt);
  SeenMomentData copyWithCompanion(SeenMomentsCompanion data) {
    return SeenMomentData(
      key: data.key.present ? data.key.value : this.key,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeenMomentData(')
          ..write('key: $key, ')
          ..write('seenAt: $seenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, seenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeenMomentData &&
          other.key == this.key &&
          other.seenAt == this.seenAt);
}

class SeenMomentsCompanion extends UpdateCompanion<SeenMomentData> {
  final Value<String> key;
  final Value<DateTime> seenAt;
  final Value<int> rowid;
  const SeenMomentsCompanion({
    this.key = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeenMomentsCompanion.insert({
    required String key,
    required DateTime seenAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       seenAt = Value(seenAt);
  static Insertable<SeenMomentData> custom({
    Expression<String>? key,
    Expression<DateTime>? seenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (seenAt != null) 'seen_at': seenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeenMomentsCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? seenAt,
    Value<int>? rowid,
  }) {
    return SeenMomentsCompanion(
      key: key ?? this.key,
      seenAt: seenAt ?? this.seenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<DateTime>(seenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeenMomentsCompanion(')
          ..write('key: $key, ')
          ..write('seenAt: $seenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvsTable extends Kvs with TableInfo<$KvsTable, KvData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kvs';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvsTable createAlias(String alias) {
    return $KvsTable(attachedDatabase, alias);
  }
}

class KvData extends DataClass implements Insertable<KvData> {
  final String key;
  final String value;
  const KvData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvsCompanion toCompanion(bool nullToAbsent) {
    return KvsCompanion(key: Value(key), value: Value(value));
  }

  factory KvData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvData copyWith({String? key, String? value}) =>
      KvData(key: key ?? this.key, value: value ?? this.value);
  KvData copyWithCompanion(KvsCompanion data) {
    return KvData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvData && other.key == this.key && other.value == this.value);
}

class KvsCompanion extends UpdateCompanion<KvData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $XpEventsTable xpEvents = $XpEventsTable(this);
  late final $StreakRepairsTable streakRepairs = $StreakRepairsTable(this);
  late final $SeenMomentsTable seenMoments = $SeenMomentsTable(this);
  late final $KvsTable kvs = $KvsTable(this);
  late final QuestsDao questsDao = QuestsDao(this as AppDatabase);
  late final CompletionsDao completionsDao = CompletionsDao(
    this as AppDatabase,
  );
  late final GoalsDao goalsDao = GoalsDao(this as AppDatabase);
  late final LedgerDao ledgerDao = LedgerDao(this as AppDatabase);
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    goals,
    quests,
    completions,
    xpEvents,
    streakRepairs,
    seenMoments,
    kvs,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<int?> calling,
      Value<DateTime?> callingChosenAt,
      Value<int> resetMinute,
      Value<int> weekStart,
      Value<int> themeMode,
      Value<String> accent,
      Value<bool> digestEnabled,
      Value<int> digestMinute,
      Value<String?> settledThrough,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<int?> calling,
      Value<DateTime?> callingChosenAt,
      Value<int> resetMinute,
      Value<int> weekStart,
      Value<int> themeMode,
      Value<String> accent,
      Value<bool> digestEnabled,
      Value<int> digestMinute,
      Value<String?> settledThrough,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calling => $composableBuilder(
    column: $table.calling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get callingChosenAt => $composableBuilder(
    column: $table.callingChosenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resetMinute => $composableBuilder(
    column: $table.resetMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get digestEnabled => $composableBuilder(
    column: $table.digestEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digestMinute => $composableBuilder(
    column: $table.digestMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calling => $composableBuilder(
    column: $table.calling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get callingChosenAt => $composableBuilder(
    column: $table.callingChosenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resetMinute => $composableBuilder(
    column: $table.resetMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accent => $composableBuilder(
    column: $table.accent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get digestEnabled => $composableBuilder(
    column: $table.digestEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digestMinute => $composableBuilder(
    column: $table.digestMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get calling =>
      $composableBuilder(column: $table.calling, builder: (column) => column);

  GeneratedColumn<DateTime> get callingChosenAt => $composableBuilder(
    column: $table.callingChosenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resetMinute => $composableBuilder(
    column: $table.resetMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get accent =>
      $composableBuilder(column: $table.accent, builder: (column) => column);

  GeneratedColumn<bool> get digestEnabled => $composableBuilder(
    column: $table.digestEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get digestMinute => $composableBuilder(
    column: $table.digestMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileData,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileData,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileData>,
          ),
          ProfileData,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> calling = const Value.absent(),
                Value<DateTime?> callingChosenAt = const Value.absent(),
                Value<int> resetMinute = const Value.absent(),
                Value<int> weekStart = const Value.absent(),
                Value<int> themeMode = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<bool> digestEnabled = const Value.absent(),
                Value<int> digestMinute = const Value.absent(),
                Value<String?> settledThrough = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                calling: calling,
                callingChosenAt: callingChosenAt,
                resetMinute: resetMinute,
                weekStart: weekStart,
                themeMode: themeMode,
                accent: accent,
                digestEnabled: digestEnabled,
                digestMinute: digestMinute,
                settledThrough: settledThrough,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> calling = const Value.absent(),
                Value<DateTime?> callingChosenAt = const Value.absent(),
                Value<int> resetMinute = const Value.absent(),
                Value<int> weekStart = const Value.absent(),
                Value<int> themeMode = const Value.absent(),
                Value<String> accent = const Value.absent(),
                Value<bool> digestEnabled = const Value.absent(),
                Value<int> digestMinute = const Value.absent(),
                Value<String?> settledThrough = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                calling: calling,
                callingChosenAt: callingChosenAt,
                resetMinute: resetMinute,
                weekStart: weekStart,
                themeMode: themeMode,
                accent: accent,
                digestEnabled: digestEnabled,
                digestMinute: digestMinute,
                settledThrough: settledThrough,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileData,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileData, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileData>),
      ProfileData,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String title,
      required String emoji,
      Value<String?> note,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> emoji,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, GoalData> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestsTable, List<QuestData>> _questsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: $_aliasNameGenerator(db.goals.id, db.quests.goalId),
  );

  $$QuestsTableProcessedTableManager get questsRefs {
    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questsRefs(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> questsRefs<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalData,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalData, $$GoalsTableReferences),
          GoalData,
          PrefetchHooks Function({bool questsRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                emoji: emoji,
                note: note,
                createdAt: createdAt,
                archivedAt: archivedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String emoji,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                emoji: emoji,
                note: note,
                createdAt: createdAt,
                archivedAt: archivedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({questsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (questsRefs) db.quests],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questsRefs)
                    await $_getPrefetchedData<GoalData, $GoalsTable, QuestData>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._questsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GoalsTableReferences(db, table, p0).questsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalData,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalData, $$GoalsTableReferences),
      GoalData,
      PrefetchHooks Function({bool questsRefs})
    >;
typedef $$QuestsTableCreateCompanionBuilder =
    QuestsCompanion Function({
      required String id,
      required String title,
      Value<String?> note,
      required ScheduleRule rule,
      Value<int> targetType,
      Value<int> targetValue,
      Value<String?> unit,
      Value<int> difficulty,
      Value<bool> essential,
      Value<String?> goalId,
      Value<int?> domain,
      Value<int?> reminderMinute,
      Value<String?> pausedUntil,
      Value<String?> settledThrough,
      required DateTime createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$QuestsTableUpdateCompanionBuilder =
    QuestsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> note,
      Value<ScheduleRule> rule,
      Value<int> targetType,
      Value<int> targetValue,
      Value<String?> unit,
      Value<int> difficulty,
      Value<bool> essential,
      Value<String?> goalId,
      Value<int?> domain,
      Value<int?> reminderMinute,
      Value<String?> pausedUntil,
      Value<String?> settledThrough,
      Value<DateTime> createdAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$QuestsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestsTable, QuestData> {
  $$QuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias($_aliasNameGenerator(db.quests.goalId, db.goals.id));

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<String>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CompletionsTable, List<CompletionData>>
  _completionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.completions,
    aliasName: $_aliasNameGenerator(db.quests.id, db.completions.questId),
  );

  $$CompletionsTableProcessedTableManager get completionsRefs {
    final manager = $$CompletionsTableTableManager(
      $_db,
      $_db.completions,
    ).filter((f) => f.questId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_completionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StreakRepairsTable, List<StreakRepairData>>
  _streakRepairsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.streakRepairs,
    aliasName: $_aliasNameGenerator(db.quests.id, db.streakRepairs.questId),
  );

  $$StreakRepairsTableProcessedTableManager get streakRepairsRefs {
    final manager = $$StreakRepairsTableTableManager(
      $_db,
      $_db.streakRepairs,
    ).filter((f) => f.questId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_streakRepairsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleRule, ScheduleRule, String> get rule =>
      $composableBuilder(
        column: $table.rule,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get essential => $composableBuilder(
    column: $table.essential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> completionsRefs(
    Expression<bool> Function($$CompletionsTableFilterComposer f) f,
  ) {
    final $$CompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableFilterComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> streakRepairsRefs(
    Expression<bool> Function($$StreakRepairsTableFilterComposer f) f,
  ) {
    final $$StreakRepairsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.streakRepairs,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StreakRepairsTableFilterComposer(
            $db: $db,
            $table: $db.streakRepairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get essential => $composableBuilder(
    column: $table.essential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleRule, String> get rule =>
      $composableBuilder(column: $table.rule, builder: (column) => column);

  GeneratedColumn<int> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get essential =>
      $composableBuilder(column: $table.essential, builder: (column) => column);

  GeneratedColumn<int> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pausedUntil => $composableBuilder(
    column: $table.pausedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settledThrough => $composableBuilder(
    column: $table.settledThrough,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> completionsRefs<T extends Object>(
    Expression<T> Function($$CompletionsTableAnnotationComposer a) f,
  ) {
    final $$CompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> streakRepairsRefs<T extends Object>(
    Expression<T> Function($$StreakRepairsTableAnnotationComposer a) f,
  ) {
    final $$StreakRepairsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.streakRepairs,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StreakRepairsTableAnnotationComposer(
            $db: $db,
            $table: $db.streakRepairs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestsTable,
          QuestData,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (QuestData, $$QuestsTableReferences),
          QuestData,
          PrefetchHooks Function({
            bool goalId,
            bool completionsRefs,
            bool streakRepairsRefs,
          })
        > {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<ScheduleRule> rule = const Value.absent(),
                Value<int> targetType = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<bool> essential = const Value.absent(),
                Value<String?> goalId = const Value.absent(),
                Value<int?> domain = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<String?> pausedUntil = const Value.absent(),
                Value<String?> settledThrough = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                title: title,
                note: note,
                rule: rule,
                targetType: targetType,
                targetValue: targetValue,
                unit: unit,
                difficulty: difficulty,
                essential: essential,
                goalId: goalId,
                domain: domain,
                reminderMinute: reminderMinute,
                pausedUntil: pausedUntil,
                settledThrough: settledThrough,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> note = const Value.absent(),
                required ScheduleRule rule,
                Value<int> targetType = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<bool> essential = const Value.absent(),
                Value<String?> goalId = const Value.absent(),
                Value<int?> domain = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<String?> pausedUntil = const Value.absent(),
                Value<String?> settledThrough = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                title: title,
                note: note,
                rule: rule,
                targetType: targetType,
                targetValue: targetValue,
                unit: unit,
                difficulty: difficulty,
                essential: essential,
                goalId: goalId,
                domain: domain,
                reminderMinute: reminderMinute,
                pausedUntil: pausedUntil,
                settledThrough: settledThrough,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuestsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                goalId = false,
                completionsRefs = false,
                streakRepairsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (completionsRefs) db.completions,
                    if (streakRepairsRefs) db.streakRepairs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (goalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.goalId,
                                    referencedTable: $$QuestsTableReferences
                                        ._goalIdTable(db),
                                    referencedColumn: $$QuestsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (completionsRefs)
                        await $_getPrefetchedData<
                          QuestData,
                          $QuestsTable,
                          CompletionData
                        >(
                          currentTable: table,
                          referencedTable: $$QuestsTableReferences
                              ._completionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestsTableReferences(
                                db,
                                table,
                                p0,
                              ).completionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (streakRepairsRefs)
                        await $_getPrefetchedData<
                          QuestData,
                          $QuestsTable,
                          StreakRepairData
                        >(
                          currentTable: table,
                          referencedTable: $$QuestsTableReferences
                              ._streakRepairsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestsTableReferences(
                                db,
                                table,
                                p0,
                              ).streakRepairsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestsTable,
      QuestData,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (QuestData, $$QuestsTableReferences),
      QuestData,
      PrefetchHooks Function({
        bool goalId,
        bool completionsRefs,
        bool streakRepairsRefs,
      })
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String id,
      required String questId,
      required String localDate,
      Value<int> value,
      Value<String?> note,
      required String timezone,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> id,
      Value<String> questId,
      Value<String> localDate,
      Value<int> value,
      Value<String?> note,
      Value<String> timezone,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CompletionsTableReferences
    extends BaseReferences<_$AppDatabase, $CompletionsTable, CompletionData> {
  $$CompletionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestsTable _questIdTable(_$AppDatabase db) => db.quests.createAlias(
    $_aliasNameGenerator(db.completions.questId, db.quests.id),
  );

  $$QuestsTableProcessedTableManager get questId {
    final $_column = $_itemColumn<String>('quest_id')!;

    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableOrderingComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$QuestsTableAnnotationComposer get questId {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionsTable,
          CompletionData,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (CompletionData, $$CompletionsTableReferences),
          CompletionData,
          PrefetchHooks Function({bool questId})
        > {
  $$CompletionsTableTableManager(_$AppDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                questId: questId,
                localDate: localDate,
                value: value,
                note: note,
                timezone: timezone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questId,
                required String localDate,
                Value<int> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String timezone,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                questId: questId,
                localDate: localDate,
                value: value,
                note: note,
                timezone: timezone,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questId,
                                referencedTable: $$CompletionsTableReferences
                                    ._questIdTable(db),
                                referencedColumn: $$CompletionsTableReferences
                                    ._questIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionsTable,
      CompletionData,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (CompletionData, $$CompletionsTableReferences),
      CompletionData,
      PrefetchHooks Function({bool questId})
    >;
typedef $$XpEventsTableCreateCompanionBuilder =
    XpEventsCompanion Function({
      required String id,
      required int type,
      required String ref,
      Value<String?> periodRef,
      required int amount,
      required String localDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$XpEventsTableUpdateCompanionBuilder =
    XpEventsCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<String> ref,
      Value<String?> periodRef,
      Value<int> amount,
      Value<String> localDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$XpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodRef => $composableBuilder(
    column: $table.periodRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodRef => $composableBuilder(
    column: $table.periodRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get periodRef =>
      $composableBuilder(column: $table.periodRef, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$XpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XpEventsTable,
          XpEventData,
          $$XpEventsTableFilterComposer,
          $$XpEventsTableOrderingComposer,
          $$XpEventsTableAnnotationComposer,
          $$XpEventsTableCreateCompanionBuilder,
          $$XpEventsTableUpdateCompanionBuilder,
          (
            XpEventData,
            BaseReferences<_$AppDatabase, $XpEventsTable, XpEventData>,
          ),
          XpEventData,
          PrefetchHooks Function()
        > {
  $$XpEventsTableTableManager(_$AppDatabase db, $XpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String?> periodRef = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => XpEventsCompanion(
                id: id,
                type: type,
                ref: ref,
                periodRef: periodRef,
                amount: amount,
                localDate: localDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int type,
                required String ref,
                Value<String?> periodRef = const Value.absent(),
                required int amount,
                required String localDate,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => XpEventsCompanion.insert(
                id: id,
                type: type,
                ref: ref,
                periodRef: periodRef,
                amount: amount,
                localDate: localDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XpEventsTable,
      XpEventData,
      $$XpEventsTableFilterComposer,
      $$XpEventsTableOrderingComposer,
      $$XpEventsTableAnnotationComposer,
      $$XpEventsTableCreateCompanionBuilder,
      $$XpEventsTableUpdateCompanionBuilder,
      (XpEventData, BaseReferences<_$AppDatabase, $XpEventsTable, XpEventData>),
      XpEventData,
      PrefetchHooks Function()
    >;
typedef $$StreakRepairsTableCreateCompanionBuilder =
    StreakRepairsCompanion Function({
      required String id,
      required String questId,
      required String periodKey,
      required DateTime appliedAt,
      Value<int> rowid,
    });
typedef $$StreakRepairsTableUpdateCompanionBuilder =
    StreakRepairsCompanion Function({
      Value<String> id,
      Value<String> questId,
      Value<String> periodKey,
      Value<DateTime> appliedAt,
      Value<int> rowid,
    });

final class $$StreakRepairsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StreakRepairsTable, StreakRepairData> {
  $$StreakRepairsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestsTable _questIdTable(_$AppDatabase db) => db.quests.createAlias(
    $_aliasNameGenerator(db.streakRepairs.questId, db.quests.id),
  );

  $$QuestsTableProcessedTableManager get questId {
    final $_column = $_itemColumn<String>('quest_id')!;

    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StreakRepairsTableFilterComposer
    extends Composer<_$AppDatabase, $StreakRepairsTable> {
  $$StreakRepairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreakRepairsTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakRepairsTable> {
  $$StreakRepairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableOrderingComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreakRepairsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakRepairsTable> {
  $$StreakRepairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  $$QuestsTableAnnotationComposer get questId {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreakRepairsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakRepairsTable,
          StreakRepairData,
          $$StreakRepairsTableFilterComposer,
          $$StreakRepairsTableOrderingComposer,
          $$StreakRepairsTableAnnotationComposer,
          $$StreakRepairsTableCreateCompanionBuilder,
          $$StreakRepairsTableUpdateCompanionBuilder,
          (StreakRepairData, $$StreakRepairsTableReferences),
          StreakRepairData,
          PrefetchHooks Function({bool questId})
        > {
  $$StreakRepairsTableTableManager(_$AppDatabase db, $StreakRepairsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakRepairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakRepairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakRepairsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questId = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreakRepairsCompanion(
                id: id,
                questId: questId,
                periodKey: periodKey,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questId,
                required String periodKey,
                required DateTime appliedAt,
                Value<int> rowid = const Value.absent(),
              }) => StreakRepairsCompanion.insert(
                id: id,
                questId: questId,
                periodKey: periodKey,
                appliedAt: appliedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StreakRepairsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questId,
                                referencedTable: $$StreakRepairsTableReferences
                                    ._questIdTable(db),
                                referencedColumn: $$StreakRepairsTableReferences
                                    ._questIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StreakRepairsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakRepairsTable,
      StreakRepairData,
      $$StreakRepairsTableFilterComposer,
      $$StreakRepairsTableOrderingComposer,
      $$StreakRepairsTableAnnotationComposer,
      $$StreakRepairsTableCreateCompanionBuilder,
      $$StreakRepairsTableUpdateCompanionBuilder,
      (StreakRepairData, $$StreakRepairsTableReferences),
      StreakRepairData,
      PrefetchHooks Function({bool questId})
    >;
typedef $$SeenMomentsTableCreateCompanionBuilder =
    SeenMomentsCompanion Function({
      required String key,
      required DateTime seenAt,
      Value<int> rowid,
    });
typedef $$SeenMomentsTableUpdateCompanionBuilder =
    SeenMomentsCompanion Function({
      Value<String> key,
      Value<DateTime> seenAt,
      Value<int> rowid,
    });

class $$SeenMomentsTableFilterComposer
    extends Composer<_$AppDatabase, $SeenMomentsTable> {
  $$SeenMomentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeenMomentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeenMomentsTable> {
  $$SeenMomentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeenMomentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeenMomentsTable> {
  $$SeenMomentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);
}

class $$SeenMomentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeenMomentsTable,
          SeenMomentData,
          $$SeenMomentsTableFilterComposer,
          $$SeenMomentsTableOrderingComposer,
          $$SeenMomentsTableAnnotationComposer,
          $$SeenMomentsTableCreateCompanionBuilder,
          $$SeenMomentsTableUpdateCompanionBuilder,
          (
            SeenMomentData,
            BaseReferences<_$AppDatabase, $SeenMomentsTable, SeenMomentData>,
          ),
          SeenMomentData,
          PrefetchHooks Function()
        > {
  $$SeenMomentsTableTableManager(_$AppDatabase db, $SeenMomentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeenMomentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeenMomentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeenMomentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime> seenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SeenMomentsCompanion(key: key, seenAt: seenAt, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required DateTime seenAt,
                Value<int> rowid = const Value.absent(),
              }) => SeenMomentsCompanion.insert(
                key: key,
                seenAt: seenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeenMomentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeenMomentsTable,
      SeenMomentData,
      $$SeenMomentsTableFilterComposer,
      $$SeenMomentsTableOrderingComposer,
      $$SeenMomentsTableAnnotationComposer,
      $$SeenMomentsTableCreateCompanionBuilder,
      $$SeenMomentsTableUpdateCompanionBuilder,
      (
        SeenMomentData,
        BaseReferences<_$AppDatabase, $SeenMomentsTable, SeenMomentData>,
      ),
      SeenMomentData,
      PrefetchHooks Function()
    >;
typedef $$KvsTableCreateCompanionBuilder =
    KvsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KvsTableUpdateCompanionBuilder =
    KvsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KvsTableFilterComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvsTableOrderingComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvsTableAnnotationComposer extends Composer<_$AppDatabase, $KvsTable> {
  $$KvsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KvsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvsTable,
          KvData,
          $$KvsTableFilterComposer,
          $$KvsTableOrderingComposer,
          $$KvsTableAnnotationComposer,
          $$KvsTableCreateCompanionBuilder,
          $$KvsTableUpdateCompanionBuilder,
          (KvData, BaseReferences<_$AppDatabase, $KvsTable, KvData>),
          KvData,
          PrefetchHooks Function()
        > {
  $$KvsTableTableManager(_$AppDatabase db, $KvsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KvsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvsTable,
      KvData,
      $$KvsTableFilterComposer,
      $$KvsTableOrderingComposer,
      $$KvsTableAnnotationComposer,
      $$KvsTableCreateCompanionBuilder,
      $$KvsTableUpdateCompanionBuilder,
      (KvData, BaseReferences<_$AppDatabase, $KvsTable, KvData>),
      KvData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$XpEventsTableTableManager get xpEvents =>
      $$XpEventsTableTableManager(_db, _db.xpEvents);
  $$StreakRepairsTableTableManager get streakRepairs =>
      $$StreakRepairsTableTableManager(_db, _db.streakRepairs);
  $$SeenMomentsTableTableManager get seenMoments =>
      $$SeenMomentsTableTableManager(_db, _db.seenMoments);
  $$KvsTableTableManager get kvs => $$KvsTableTableManager(_db, _db.kvs);
}
