// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama =
      GeneratedColumn<String>('nama', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _apiKeyHashMeta =
      const VerificationMeta('apiKeyHash');
  @override
  late final GeneratedColumn<String> apiKeyHash = GeneratedColumn<String>(
      'api_key_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        nama,
        email,
        apiKeyHash
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user';
  @override
  VerificationContext validateIntegrity(Insertable<UserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('api_key_hash')) {
      context.handle(
          _apiKeyHashMeta,
          apiKeyHash.isAcceptableOrUnknown(
              data['api_key_hash']!, _apiKeyHashMeta));
    } else if (isInserting) {
      context.missing(_apiKeyHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      apiKeyHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}api_key_hash'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String nama;
  final String? email;
  final String apiKeyHash;
  const UserRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      required this.nama,
      this.email,
      required this.apiKeyHash});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['api_key_hash'] = Variable<String>(apiKeyHash);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      nama: Value(nama),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      apiKeyHash: Value(apiKeyHash),
    );
  }

  factory UserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      nama: serializer.fromJson<String>(json['nama']),
      email: serializer.fromJson<String?>(json['email']),
      apiKeyHash: serializer.fromJson<String>(json['apiKeyHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'nama': serializer.toJson<String>(nama),
      'email': serializer.toJson<String?>(email),
      'apiKeyHash': serializer.toJson<String>(apiKeyHash),
    };
  }

  UserRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          String? nama,
          Value<String?> email = const Value.absent(),
          String? apiKeyHash}) =>
      UserRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        nama: nama ?? this.nama,
        email: email.present ? email.value : this.email,
        apiKeyHash: apiKeyHash ?? this.apiKeyHash,
      );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      nama: data.nama.present ? data.nama.value : this.nama,
      email: data.email.present ? data.email.value : this.email,
      apiKeyHash:
          data.apiKeyHash.present ? data.apiKeyHash.value : this.apiKeyHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('nama: $nama, ')
          ..write('email: $email, ')
          ..write('apiKeyHash: $apiKeyHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, isDeleted,
      deletedAt, serverRevision, nama, email, apiKeyHash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.nama == this.nama &&
          other.email == this.email &&
          other.apiKeyHash == this.apiKeyHash);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String> nama;
  final Value<String?> email;
  final Value<String> apiKeyHash;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.nama = const Value.absent(),
    this.email = const Value.absent(),
    this.apiKeyHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    required String nama,
    this.email = const Value.absent(),
    required String apiKeyHash,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        nama = Value(nama),
        apiKeyHash = Value(apiKeyHash);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? nama,
    Expression<String>? email,
    Expression<String>? apiKeyHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (nama != null) 'nama': nama,
      if (email != null) 'email': email,
      if (apiKeyHash != null) 'api_key_hash': apiKeyHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String>? nama,
      Value<String?>? email,
      Value<String>? apiKeyHash,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      apiKeyHash: apiKeyHash ?? this.apiKeyHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (apiKeyHash.present) {
      map['api_key_hash'] = Variable<String>(apiKeyHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('nama: $nama, ')
          ..write('email: $email, ')
          ..write('apiKeyHash: $apiKeyHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  @override
  late final GeneratedColumnWithTypeConverter<Language, String> language =
      GeneratedColumn<String>('language', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('id'))
          .withConverter<Language>($UserSettingsTable.$converterlanguage);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Asia/Jakarta'));
  static const VerificationMeta _pomodoroFocusMinutesMeta =
      const VerificationMeta('pomodoroFocusMinutes');
  @override
  late final GeneratedColumn<int> pomodoroFocusMinutes = GeneratedColumn<int>(
      'pomodoro_focus_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _pomodoroShortBreakMinutesMeta =
      const VerificationMeta('pomodoroShortBreakMinutes');
  @override
  late final GeneratedColumn<int> pomodoroShortBreakMinutes =
      GeneratedColumn<int>('pomodoro_short_break_minutes', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(5));
  static const VerificationMeta _pomodoroLongBreakMinutesMeta =
      const VerificationMeta('pomodoroLongBreakMinutes');
  @override
  late final GeneratedColumn<int> pomodoroLongBreakMinutes =
      GeneratedColumn<int>('pomodoro_long_break_minutes', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(15));
  static const VerificationMeta _pomodoroLongBreakIntervalMeta =
      const VerificationMeta('pomodoroLongBreakInterval');
  @override
  late final GeneratedColumn<int> pomodoroLongBreakInterval =
      GeneratedColumn<int>('pomodoro_long_break_interval', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(4));
  @override
  late final GeneratedColumnWithTypeConverter<AlarmMode, String> alarmMode =
      GeneratedColumn<String>('alarm_mode', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('sound'))
          .withConverter<AlarmMode>($UserSettingsTable.$converteralarmMode);
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _weeklyReviewTimeMeta =
      const VerificationMeta('weeklyReviewTime');
  @override
  late final GeneratedColumn<String> weeklyReviewTime = GeneratedColumn<String>(
      'weekly_review_time', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('09:00:00'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        language,
        timezone,
        pomodoroFocusMinutes,
        pomodoroShortBreakMinutes,
        pomodoroLongBreakMinutes,
        pomodoroLongBreakInterval,
        alarmMode,
        notificationsEnabled,
        weeklyReviewTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('pomodoro_focus_minutes')) {
      context.handle(
          _pomodoroFocusMinutesMeta,
          pomodoroFocusMinutes.isAcceptableOrUnknown(
              data['pomodoro_focus_minutes']!, _pomodoroFocusMinutesMeta));
    }
    if (data.containsKey('pomodoro_short_break_minutes')) {
      context.handle(
          _pomodoroShortBreakMinutesMeta,
          pomodoroShortBreakMinutes.isAcceptableOrUnknown(
              data['pomodoro_short_break_minutes']!,
              _pomodoroShortBreakMinutesMeta));
    }
    if (data.containsKey('pomodoro_long_break_minutes')) {
      context.handle(
          _pomodoroLongBreakMinutesMeta,
          pomodoroLongBreakMinutes.isAcceptableOrUnknown(
              data['pomodoro_long_break_minutes']!,
              _pomodoroLongBreakMinutesMeta));
    }
    if (data.containsKey('pomodoro_long_break_interval')) {
      context.handle(
          _pomodoroLongBreakIntervalMeta,
          pomodoroLongBreakInterval.isAcceptableOrUnknown(
              data['pomodoro_long_break_interval']!,
              _pomodoroLongBreakIntervalMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('weekly_review_time')) {
      context.handle(
          _weeklyReviewTimeMeta,
          weeklyReviewTime.isAcceptableOrUnknown(
              data['weekly_review_time']!, _weeklyReviewTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      language: $UserSettingsTable.$converterlanguage.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!),
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      pomodoroFocusMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}pomodoro_focus_minutes'])!,
      pomodoroShortBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}pomodoro_short_break_minutes'])!,
      pomodoroLongBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}pomodoro_long_break_minutes'])!,
      pomodoroLongBreakInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}pomodoro_long_break_interval'])!,
      alarmMode: $UserSettingsTable.$converteralarmMode.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alarm_mode'])!),
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      weeklyReviewTime: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}weekly_review_time'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Language, String, String> $converterlanguage =
      const EnumNameConverter<Language>(Language.values);
  static JsonTypeConverter2<AlarmMode, String, String> $converteralarmMode =
      const EnumNameConverter<AlarmMode>(AlarmMode.values);
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final Language language;
  final String timezone;
  final int pomodoroFocusMinutes;
  final int pomodoroShortBreakMinutes;
  final int pomodoroLongBreakMinutes;
  final int pomodoroLongBreakInterval;
  final AlarmMode alarmMode;
  final bool notificationsEnabled;
  final String weeklyReviewTime;
  const UserSettingsRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      required this.language,
      required this.timezone,
      required this.pomodoroFocusMinutes,
      required this.pomodoroShortBreakMinutes,
      required this.pomodoroLongBreakMinutes,
      required this.pomodoroLongBreakInterval,
      required this.alarmMode,
      required this.notificationsEnabled,
      required this.weeklyReviewTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    {
      map['language'] = Variable<String>(
          $UserSettingsTable.$converterlanguage.toSql(language));
    }
    map['timezone'] = Variable<String>(timezone);
    map['pomodoro_focus_minutes'] = Variable<int>(pomodoroFocusMinutes);
    map['pomodoro_short_break_minutes'] =
        Variable<int>(pomodoroShortBreakMinutes);
    map['pomodoro_long_break_minutes'] =
        Variable<int>(pomodoroLongBreakMinutes);
    map['pomodoro_long_break_interval'] =
        Variable<int>(pomodoroLongBreakInterval);
    {
      map['alarm_mode'] = Variable<String>(
          $UserSettingsTable.$converteralarmMode.toSql(alarmMode));
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['weekly_review_time'] = Variable<String>(weeklyReviewTime);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      language: Value(language),
      timezone: Value(timezone),
      pomodoroFocusMinutes: Value(pomodoroFocusMinutes),
      pomodoroShortBreakMinutes: Value(pomodoroShortBreakMinutes),
      pomodoroLongBreakMinutes: Value(pomodoroLongBreakMinutes),
      pomodoroLongBreakInterval: Value(pomodoroLongBreakInterval),
      alarmMode: Value(alarmMode),
      notificationsEnabled: Value(notificationsEnabled),
      weeklyReviewTime: Value(weeklyReviewTime),
    );
  }

  factory UserSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      language: $UserSettingsTable.$converterlanguage
          .fromJson(serializer.fromJson<String>(json['language'])),
      timezone: serializer.fromJson<String>(json['timezone']),
      pomodoroFocusMinutes:
          serializer.fromJson<int>(json['pomodoroFocusMinutes']),
      pomodoroShortBreakMinutes:
          serializer.fromJson<int>(json['pomodoroShortBreakMinutes']),
      pomodoroLongBreakMinutes:
          serializer.fromJson<int>(json['pomodoroLongBreakMinutes']),
      pomodoroLongBreakInterval:
          serializer.fromJson<int>(json['pomodoroLongBreakInterval']),
      alarmMode: $UserSettingsTable.$converteralarmMode
          .fromJson(serializer.fromJson<String>(json['alarmMode'])),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      weeklyReviewTime: serializer.fromJson<String>(json['weeklyReviewTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'language': serializer.toJson<String>(
          $UserSettingsTable.$converterlanguage.toJson(language)),
      'timezone': serializer.toJson<String>(timezone),
      'pomodoroFocusMinutes': serializer.toJson<int>(pomodoroFocusMinutes),
      'pomodoroShortBreakMinutes':
          serializer.toJson<int>(pomodoroShortBreakMinutes),
      'pomodoroLongBreakMinutes':
          serializer.toJson<int>(pomodoroLongBreakMinutes),
      'pomodoroLongBreakInterval':
          serializer.toJson<int>(pomodoroLongBreakInterval),
      'alarmMode': serializer.toJson<String>(
          $UserSettingsTable.$converteralarmMode.toJson(alarmMode)),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'weeklyReviewTime': serializer.toJson<String>(weeklyReviewTime),
    };
  }

  UserSettingsRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          Language? language,
          String? timezone,
          int? pomodoroFocusMinutes,
          int? pomodoroShortBreakMinutes,
          int? pomodoroLongBreakMinutes,
          int? pomodoroLongBreakInterval,
          AlarmMode? alarmMode,
          bool? notificationsEnabled,
          String? weeklyReviewTime}) =>
      UserSettingsRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        language: language ?? this.language,
        timezone: timezone ?? this.timezone,
        pomodoroFocusMinutes: pomodoroFocusMinutes ?? this.pomodoroFocusMinutes,
        pomodoroShortBreakMinutes:
            pomodoroShortBreakMinutes ?? this.pomodoroShortBreakMinutes,
        pomodoroLongBreakMinutes:
            pomodoroLongBreakMinutes ?? this.pomodoroLongBreakMinutes,
        pomodoroLongBreakInterval:
            pomodoroLongBreakInterval ?? this.pomodoroLongBreakInterval,
        alarmMode: alarmMode ?? this.alarmMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        weeklyReviewTime: weeklyReviewTime ?? this.weeklyReviewTime,
      );
  UserSettingsRow copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      language: data.language.present ? data.language.value : this.language,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      pomodoroFocusMinutes: data.pomodoroFocusMinutes.present
          ? data.pomodoroFocusMinutes.value
          : this.pomodoroFocusMinutes,
      pomodoroShortBreakMinutes: data.pomodoroShortBreakMinutes.present
          ? data.pomodoroShortBreakMinutes.value
          : this.pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes: data.pomodoroLongBreakMinutes.present
          ? data.pomodoroLongBreakMinutes.value
          : this.pomodoroLongBreakMinutes,
      pomodoroLongBreakInterval: data.pomodoroLongBreakInterval.present
          ? data.pomodoroLongBreakInterval.value
          : this.pomodoroLongBreakInterval,
      alarmMode: data.alarmMode.present ? data.alarmMode.value : this.alarmMode,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      weeklyReviewTime: data.weeklyReviewTime.present
          ? data.weeklyReviewTime.value
          : this.weeklyReviewTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('language: $language, ')
          ..write('timezone: $timezone, ')
          ..write('pomodoroFocusMinutes: $pomodoroFocusMinutes, ')
          ..write('pomodoroShortBreakMinutes: $pomodoroShortBreakMinutes, ')
          ..write('pomodoroLongBreakMinutes: $pomodoroLongBreakMinutes, ')
          ..write('pomodoroLongBreakInterval: $pomodoroLongBreakInterval, ')
          ..write('alarmMode: $alarmMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('weeklyReviewTime: $weeklyReviewTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      language,
      timezone,
      pomodoroFocusMinutes,
      pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes,
      pomodoroLongBreakInterval,
      alarmMode,
      notificationsEnabled,
      weeklyReviewTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.language == this.language &&
          other.timezone == this.timezone &&
          other.pomodoroFocusMinutes == this.pomodoroFocusMinutes &&
          other.pomodoroShortBreakMinutes == this.pomodoroShortBreakMinutes &&
          other.pomodoroLongBreakMinutes == this.pomodoroLongBreakMinutes &&
          other.pomodoroLongBreakInterval == this.pomodoroLongBreakInterval &&
          other.alarmMode == this.alarmMode &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.weeklyReviewTime == this.weeklyReviewTime);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<Language> language;
  final Value<String> timezone;
  final Value<int> pomodoroFocusMinutes;
  final Value<int> pomodoroShortBreakMinutes;
  final Value<int> pomodoroLongBreakMinutes;
  final Value<int> pomodoroLongBreakInterval;
  final Value<AlarmMode> alarmMode;
  final Value<bool> notificationsEnabled;
  final Value<String> weeklyReviewTime;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.language = const Value.absent(),
    this.timezone = const Value.absent(),
    this.pomodoroFocusMinutes = const Value.absent(),
    this.pomodoroShortBreakMinutes = const Value.absent(),
    this.pomodoroLongBreakMinutes = const Value.absent(),
    this.pomodoroLongBreakInterval = const Value.absent(),
    this.alarmMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.weeklyReviewTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    this.language = const Value.absent(),
    this.timezone = const Value.absent(),
    this.pomodoroFocusMinutes = const Value.absent(),
    this.pomodoroShortBreakMinutes = const Value.absent(),
    this.pomodoroLongBreakMinutes = const Value.absent(),
    this.pomodoroLongBreakInterval = const Value.absent(),
    this.alarmMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.weeklyReviewTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId);
  static Insertable<UserSettingsRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? language,
    Expression<String>? timezone,
    Expression<int>? pomodoroFocusMinutes,
    Expression<int>? pomodoroShortBreakMinutes,
    Expression<int>? pomodoroLongBreakMinutes,
    Expression<int>? pomodoroLongBreakInterval,
    Expression<String>? alarmMode,
    Expression<bool>? notificationsEnabled,
    Expression<String>? weeklyReviewTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (language != null) 'language': language,
      if (timezone != null) 'timezone': timezone,
      if (pomodoroFocusMinutes != null)
        'pomodoro_focus_minutes': pomodoroFocusMinutes,
      if (pomodoroShortBreakMinutes != null)
        'pomodoro_short_break_minutes': pomodoroShortBreakMinutes,
      if (pomodoroLongBreakMinutes != null)
        'pomodoro_long_break_minutes': pomodoroLongBreakMinutes,
      if (pomodoroLongBreakInterval != null)
        'pomodoro_long_break_interval': pomodoroLongBreakInterval,
      if (alarmMode != null) 'alarm_mode': alarmMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (weeklyReviewTime != null) 'weekly_review_time': weeklyReviewTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<Language>? language,
      Value<String>? timezone,
      Value<int>? pomodoroFocusMinutes,
      Value<int>? pomodoroShortBreakMinutes,
      Value<int>? pomodoroLongBreakMinutes,
      Value<int>? pomodoroLongBreakInterval,
      Value<AlarmMode>? alarmMode,
      Value<bool>? notificationsEnabled,
      Value<String>? weeklyReviewTime,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      pomodoroFocusMinutes: pomodoroFocusMinutes ?? this.pomodoroFocusMinutes,
      pomodoroShortBreakMinutes:
          pomodoroShortBreakMinutes ?? this.pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes:
          pomodoroLongBreakMinutes ?? this.pomodoroLongBreakMinutes,
      pomodoroLongBreakInterval:
          pomodoroLongBreakInterval ?? this.pomodoroLongBreakInterval,
      alarmMode: alarmMode ?? this.alarmMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weeklyReviewTime: weeklyReviewTime ?? this.weeklyReviewTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(
          $UserSettingsTable.$converterlanguage.toSql(language.value));
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (pomodoroFocusMinutes.present) {
      map['pomodoro_focus_minutes'] = Variable<int>(pomodoroFocusMinutes.value);
    }
    if (pomodoroShortBreakMinutes.present) {
      map['pomodoro_short_break_minutes'] =
          Variable<int>(pomodoroShortBreakMinutes.value);
    }
    if (pomodoroLongBreakMinutes.present) {
      map['pomodoro_long_break_minutes'] =
          Variable<int>(pomodoroLongBreakMinutes.value);
    }
    if (pomodoroLongBreakInterval.present) {
      map['pomodoro_long_break_interval'] =
          Variable<int>(pomodoroLongBreakInterval.value);
    }
    if (alarmMode.present) {
      map['alarm_mode'] = Variable<String>(
          $UserSettingsTable.$converteralarmMode.toSql(alarmMode.value));
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (weeklyReviewTime.present) {
      map['weekly_review_time'] = Variable<String>(weeklyReviewTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('language: $language, ')
          ..write('timezone: $timezone, ')
          ..write('pomodoroFocusMinutes: $pomodoroFocusMinutes, ')
          ..write('pomodoroShortBreakMinutes: $pomodoroShortBreakMinutes, ')
          ..write('pomodoroLongBreakMinutes: $pomodoroLongBreakMinutes, ')
          ..write('pomodoroLongBreakInterval: $pomodoroLongBreakInterval, ')
          ..write('alarmMode: $alarmMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('weeklyReviewTime: $weeklyReviewTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceSettingsTable extends DeviceSettings
    with TableInfo<$DeviceSettingsTable, DeviceSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationPermission, String>
      notificationPermission = GeneratedColumn<String>(
              'notification_permission', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('unknown'))
          .withConverter<NotificationPermission>(
              $DeviceSettingsTable.$converternotificationPermission);
  static const VerificationMeta _alarmVolumePercentMeta =
      const VerificationMeta('alarmVolumePercent');
  @override
  late final GeneratedColumn<int> alarmVolumePercent = GeneratedColumn<int>(
      'alarm_volume_percent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  @override
  late final GeneratedColumnWithTypeConverter<ThemePreference, String> theme =
      GeneratedColumn<String>('theme', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('system'))
          .withConverter<ThemePreference>($DeviceSettingsTable.$convertertheme);
  static const VerificationMeta _activeTimerNotificationIdMeta =
      const VerificationMeta('activeTimerNotificationId');
  @override
  late final GeneratedColumn<int> activeTimerNotificationId =
      GeneratedColumn<int>('active_timer_notification_id', aliasedName, true,
          type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastPullCursorMeta =
      const VerificationMeta('lastPullCursor');
  @override
  late final GeneratedColumn<String> lastPullCursor = GeneratedColumn<String>(
      'last_pull_cursor', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncGenerationMeta =
      const VerificationMeta('syncGeneration');
  @override
  late final GeneratedColumn<String> syncGeneration = GeneratedColumn<String>(
      'sync_generation', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _syncEpochMeta =
      const VerificationMeta('syncEpoch');
  @override
  late final GeneratedColumn<int> syncEpoch = GeneratedColumn<int>(
      'sync_epoch', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<LastSyncStatus, String>
      lastSyncStatus = GeneratedColumn<String>(
              'last_sync_status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('idle'))
          .withConverter<LastSyncStatus>(
              $DeviceSettingsTable.$converterlastSyncStatus);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<DateTime> onboardingCompletedAt =
      GeneratedColumn<DateTime>('onboarding_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        deviceId,
        notificationPermission,
        alarmVolumePercent,
        theme,
        activeTimerNotificationId,
        lastPullCursor,
        syncGeneration,
        syncEpoch,
        lastSyncStatus,
        lastSyncAt,
        onboardingCompletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_settings';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('alarm_volume_percent')) {
      context.handle(
          _alarmVolumePercentMeta,
          alarmVolumePercent.isAcceptableOrUnknown(
              data['alarm_volume_percent']!, _alarmVolumePercentMeta));
    }
    if (data.containsKey('active_timer_notification_id')) {
      context.handle(
          _activeTimerNotificationIdMeta,
          activeTimerNotificationId.isAcceptableOrUnknown(
              data['active_timer_notification_id']!,
              _activeTimerNotificationIdMeta));
    }
    if (data.containsKey('last_pull_cursor')) {
      context.handle(
          _lastPullCursorMeta,
          lastPullCursor.isAcceptableOrUnknown(
              data['last_pull_cursor']!, _lastPullCursorMeta));
    }
    if (data.containsKey('sync_generation')) {
      context.handle(
          _syncGenerationMeta,
          syncGeneration.isAcceptableOrUnknown(
              data['sync_generation']!, _syncGenerationMeta));
    }
    if (data.containsKey('sync_epoch')) {
      context.handle(_syncEpochMeta,
          syncEpoch.isAcceptableOrUnknown(data['sync_epoch']!, _syncEpochMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
          _onboardingCompletedAtMeta,
          onboardingCompletedAt.isAcceptableOrUnknown(
              data['onboarding_completed_at']!, _onboardingCompletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  DeviceSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceSettingsRow(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      notificationPermission: $DeviceSettingsTable
          .$converternotificationPermission
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}notification_permission'])!),
      alarmVolumePercent: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}alarm_volume_percent'])!,
      theme: $DeviceSettingsTable.$convertertheme.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme'])!),
      activeTimerNotificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}active_timer_notification_id']),
      lastPullCursor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_pull_cursor']),
      syncGeneration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_generation']),
      syncEpoch: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_epoch']),
      lastSyncStatus: $DeviceSettingsTable.$converterlastSyncStatus.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}last_sync_status'])!),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}onboarding_completed_at']),
    );
  }

  @override
  $DeviceSettingsTable createAlias(String alias) {
    return $DeviceSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotificationPermission, String, String>
      $converternotificationPermission =
      const EnumNameConverter<NotificationPermission>(
          NotificationPermission.values);
  static JsonTypeConverter2<ThemePreference, String, String> $convertertheme =
      const EnumNameConverter<ThemePreference>(ThemePreference.values);
  static JsonTypeConverter2<LastSyncStatus, String, String>
      $converterlastSyncStatus =
      const EnumNameConverter<LastSyncStatus>(LastSyncStatus.values);
}

class DeviceSettingsRow extends DataClass
    implements Insertable<DeviceSettingsRow> {
  final String deviceId;
  final NotificationPermission notificationPermission;
  final int alarmVolumePercent;
  final ThemePreference theme;
  final int? activeTimerNotificationId;
  final String? lastPullCursor;
  final String? syncGeneration;
  final int? syncEpoch;
  final LastSyncStatus lastSyncStatus;
  final DateTime? lastSyncAt;
  final DateTime? onboardingCompletedAt;
  const DeviceSettingsRow(
      {required this.deviceId,
      required this.notificationPermission,
      required this.alarmVolumePercent,
      required this.theme,
      this.activeTimerNotificationId,
      this.lastPullCursor,
      this.syncGeneration,
      this.syncEpoch,
      required this.lastSyncStatus,
      this.lastSyncAt,
      this.onboardingCompletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    {
      map['notification_permission'] = Variable<String>($DeviceSettingsTable
          .$converternotificationPermission
          .toSql(notificationPermission));
    }
    map['alarm_volume_percent'] = Variable<int>(alarmVolumePercent);
    {
      map['theme'] =
          Variable<String>($DeviceSettingsTable.$convertertheme.toSql(theme));
    }
    if (!nullToAbsent || activeTimerNotificationId != null) {
      map['active_timer_notification_id'] =
          Variable<int>(activeTimerNotificationId);
    }
    if (!nullToAbsent || lastPullCursor != null) {
      map['last_pull_cursor'] = Variable<String>(lastPullCursor);
    }
    if (!nullToAbsent || syncGeneration != null) {
      map['sync_generation'] = Variable<String>(syncGeneration);
    }
    if (!nullToAbsent || syncEpoch != null) {
      map['sync_epoch'] = Variable<int>(syncEpoch);
    }
    {
      map['last_sync_status'] = Variable<String>(
          $DeviceSettingsTable.$converterlastSyncStatus.toSql(lastSyncStatus));
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] =
          Variable<DateTime>(onboardingCompletedAt);
    }
    return map;
  }

  DeviceSettingsCompanion toCompanion(bool nullToAbsent) {
    return DeviceSettingsCompanion(
      deviceId: Value(deviceId),
      notificationPermission: Value(notificationPermission),
      alarmVolumePercent: Value(alarmVolumePercent),
      theme: Value(theme),
      activeTimerNotificationId:
          activeTimerNotificationId == null && nullToAbsent
              ? const Value.absent()
              : Value(activeTimerNotificationId),
      lastPullCursor: lastPullCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullCursor),
      syncGeneration: syncGeneration == null && nullToAbsent
          ? const Value.absent()
          : Value(syncGeneration),
      syncEpoch: syncEpoch == null && nullToAbsent
          ? const Value.absent()
          : Value(syncEpoch),
      lastSyncStatus: Value(lastSyncStatus),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
    );
  }

  factory DeviceSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceSettingsRow(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      notificationPermission:
          $DeviceSettingsTable.$converternotificationPermission.fromJson(
              serializer.fromJson<String>(json['notificationPermission'])),
      alarmVolumePercent: serializer.fromJson<int>(json['alarmVolumePercent']),
      theme: $DeviceSettingsTable.$convertertheme
          .fromJson(serializer.fromJson<String>(json['theme'])),
      activeTimerNotificationId:
          serializer.fromJson<int?>(json['activeTimerNotificationId']),
      lastPullCursor: serializer.fromJson<String?>(json['lastPullCursor']),
      syncGeneration: serializer.fromJson<String?>(json['syncGeneration']),
      syncEpoch: serializer.fromJson<int?>(json['syncEpoch']),
      lastSyncStatus: $DeviceSettingsTable.$converterlastSyncStatus
          .fromJson(serializer.fromJson<String>(json['lastSyncStatus'])),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      onboardingCompletedAt:
          serializer.fromJson<DateTime?>(json['onboardingCompletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'notificationPermission': serializer.toJson<String>($DeviceSettingsTable
          .$converternotificationPermission
          .toJson(notificationPermission)),
      'alarmVolumePercent': serializer.toJson<int>(alarmVolumePercent),
      'theme': serializer
          .toJson<String>($DeviceSettingsTable.$convertertheme.toJson(theme)),
      'activeTimerNotificationId':
          serializer.toJson<int?>(activeTimerNotificationId),
      'lastPullCursor': serializer.toJson<String?>(lastPullCursor),
      'syncGeneration': serializer.toJson<String?>(syncGeneration),
      'syncEpoch': serializer.toJson<int?>(syncEpoch),
      'lastSyncStatus': serializer.toJson<String>(
          $DeviceSettingsTable.$converterlastSyncStatus.toJson(lastSyncStatus)),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'onboardingCompletedAt':
          serializer.toJson<DateTime?>(onboardingCompletedAt),
    };
  }

  DeviceSettingsRow copyWith(
          {String? deviceId,
          NotificationPermission? notificationPermission,
          int? alarmVolumePercent,
          ThemePreference? theme,
          Value<int?> activeTimerNotificationId = const Value.absent(),
          Value<String?> lastPullCursor = const Value.absent(),
          Value<String?> syncGeneration = const Value.absent(),
          Value<int?> syncEpoch = const Value.absent(),
          LastSyncStatus? lastSyncStatus,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          Value<DateTime?> onboardingCompletedAt = const Value.absent()}) =>
      DeviceSettingsRow(
        deviceId: deviceId ?? this.deviceId,
        notificationPermission:
            notificationPermission ?? this.notificationPermission,
        alarmVolumePercent: alarmVolumePercent ?? this.alarmVolumePercent,
        theme: theme ?? this.theme,
        activeTimerNotificationId: activeTimerNotificationId.present
            ? activeTimerNotificationId.value
            : this.activeTimerNotificationId,
        lastPullCursor:
            lastPullCursor.present ? lastPullCursor.value : this.lastPullCursor,
        syncGeneration:
            syncGeneration.present ? syncGeneration.value : this.syncGeneration,
        syncEpoch: syncEpoch.present ? syncEpoch.value : this.syncEpoch,
        lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        onboardingCompletedAt: onboardingCompletedAt.present
            ? onboardingCompletedAt.value
            : this.onboardingCompletedAt,
      );
  DeviceSettingsRow copyWithCompanion(DeviceSettingsCompanion data) {
    return DeviceSettingsRow(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      notificationPermission: data.notificationPermission.present
          ? data.notificationPermission.value
          : this.notificationPermission,
      alarmVolumePercent: data.alarmVolumePercent.present
          ? data.alarmVolumePercent.value
          : this.alarmVolumePercent,
      theme: data.theme.present ? data.theme.value : this.theme,
      activeTimerNotificationId: data.activeTimerNotificationId.present
          ? data.activeTimerNotificationId.value
          : this.activeTimerNotificationId,
      lastPullCursor: data.lastPullCursor.present
          ? data.lastPullCursor.value
          : this.lastPullCursor,
      syncGeneration: data.syncGeneration.present
          ? data.syncGeneration.value
          : this.syncGeneration,
      syncEpoch: data.syncEpoch.present ? data.syncEpoch.value : this.syncEpoch,
      lastSyncStatus: data.lastSyncStatus.present
          ? data.lastSyncStatus.value
          : this.lastSyncStatus,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingsRow(')
          ..write('deviceId: $deviceId, ')
          ..write('notificationPermission: $notificationPermission, ')
          ..write('alarmVolumePercent: $alarmVolumePercent, ')
          ..write('theme: $theme, ')
          ..write('activeTimerNotificationId: $activeTimerNotificationId, ')
          ..write('lastPullCursor: $lastPullCursor, ')
          ..write('syncGeneration: $syncGeneration, ')
          ..write('syncEpoch: $syncEpoch, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      deviceId,
      notificationPermission,
      alarmVolumePercent,
      theme,
      activeTimerNotificationId,
      lastPullCursor,
      syncGeneration,
      syncEpoch,
      lastSyncStatus,
      lastSyncAt,
      onboardingCompletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceSettingsRow &&
          other.deviceId == this.deviceId &&
          other.notificationPermission == this.notificationPermission &&
          other.alarmVolumePercent == this.alarmVolumePercent &&
          other.theme == this.theme &&
          other.activeTimerNotificationId == this.activeTimerNotificationId &&
          other.lastPullCursor == this.lastPullCursor &&
          other.syncGeneration == this.syncGeneration &&
          other.syncEpoch == this.syncEpoch &&
          other.lastSyncStatus == this.lastSyncStatus &&
          other.lastSyncAt == this.lastSyncAt &&
          other.onboardingCompletedAt == this.onboardingCompletedAt);
}

class DeviceSettingsCompanion extends UpdateCompanion<DeviceSettingsRow> {
  final Value<String> deviceId;
  final Value<NotificationPermission> notificationPermission;
  final Value<int> alarmVolumePercent;
  final Value<ThemePreference> theme;
  final Value<int?> activeTimerNotificationId;
  final Value<String?> lastPullCursor;
  final Value<String?> syncGeneration;
  final Value<int?> syncEpoch;
  final Value<LastSyncStatus> lastSyncStatus;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<int> rowid;
  const DeviceSettingsCompanion({
    this.deviceId = const Value.absent(),
    this.notificationPermission = const Value.absent(),
    this.alarmVolumePercent = const Value.absent(),
    this.theme = const Value.absent(),
    this.activeTimerNotificationId = const Value.absent(),
    this.lastPullCursor = const Value.absent(),
    this.syncGeneration = const Value.absent(),
    this.syncEpoch = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceSettingsCompanion.insert({
    required String deviceId,
    this.notificationPermission = const Value.absent(),
    this.alarmVolumePercent = const Value.absent(),
    this.theme = const Value.absent(),
    this.activeTimerNotificationId = const Value.absent(),
    this.lastPullCursor = const Value.absent(),
    this.syncGeneration = const Value.absent(),
    this.syncEpoch = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<DeviceSettingsRow> custom({
    Expression<String>? deviceId,
    Expression<String>? notificationPermission,
    Expression<int>? alarmVolumePercent,
    Expression<String>? theme,
    Expression<int>? activeTimerNotificationId,
    Expression<String>? lastPullCursor,
    Expression<String>? syncGeneration,
    Expression<int>? syncEpoch,
    Expression<String>? lastSyncStatus,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? onboardingCompletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (notificationPermission != null)
        'notification_permission': notificationPermission,
      if (alarmVolumePercent != null)
        'alarm_volume_percent': alarmVolumePercent,
      if (theme != null) 'theme': theme,
      if (activeTimerNotificationId != null)
        'active_timer_notification_id': activeTimerNotificationId,
      if (lastPullCursor != null) 'last_pull_cursor': lastPullCursor,
      if (syncGeneration != null) 'sync_generation': syncGeneration,
      if (syncEpoch != null) 'sync_epoch': syncEpoch,
      if (lastSyncStatus != null) 'last_sync_status': lastSyncStatus,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceSettingsCompanion copyWith(
      {Value<String>? deviceId,
      Value<NotificationPermission>? notificationPermission,
      Value<int>? alarmVolumePercent,
      Value<ThemePreference>? theme,
      Value<int?>? activeTimerNotificationId,
      Value<String?>? lastPullCursor,
      Value<String?>? syncGeneration,
      Value<int?>? syncEpoch,
      Value<LastSyncStatus>? lastSyncStatus,
      Value<DateTime?>? lastSyncAt,
      Value<DateTime?>? onboardingCompletedAt,
      Value<int>? rowid}) {
    return DeviceSettingsCompanion(
      deviceId: deviceId ?? this.deviceId,
      notificationPermission:
          notificationPermission ?? this.notificationPermission,
      alarmVolumePercent: alarmVolumePercent ?? this.alarmVolumePercent,
      theme: theme ?? this.theme,
      activeTimerNotificationId:
          activeTimerNotificationId ?? this.activeTimerNotificationId,
      lastPullCursor: lastPullCursor ?? this.lastPullCursor,
      syncGeneration: syncGeneration ?? this.syncGeneration,
      syncEpoch: syncEpoch ?? this.syncEpoch,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (notificationPermission.present) {
      map['notification_permission'] = Variable<String>($DeviceSettingsTable
          .$converternotificationPermission
          .toSql(notificationPermission.value));
    }
    if (alarmVolumePercent.present) {
      map['alarm_volume_percent'] = Variable<int>(alarmVolumePercent.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(
          $DeviceSettingsTable.$convertertheme.toSql(theme.value));
    }
    if (activeTimerNotificationId.present) {
      map['active_timer_notification_id'] =
          Variable<int>(activeTimerNotificationId.value);
    }
    if (lastPullCursor.present) {
      map['last_pull_cursor'] = Variable<String>(lastPullCursor.value);
    }
    if (syncGeneration.present) {
      map['sync_generation'] = Variable<String>(syncGeneration.value);
    }
    if (syncEpoch.present) {
      map['sync_epoch'] = Variable<int>(syncEpoch.value);
    }
    if (lastSyncStatus.present) {
      map['last_sync_status'] = Variable<String>($DeviceSettingsTable
          .$converterlastSyncStatus
          .toSql(lastSyncStatus.value));
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] =
          Variable<DateTime>(onboardingCompletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('notificationPermission: $notificationPermission, ')
          ..write('alarmVolumePercent: $alarmVolumePercent, ')
          ..write('theme: $theme, ')
          ..write('activeTimerNotificationId: $activeTimerNotificationId, ')
          ..write('lastPullCursor: $lastPullCursor, ')
          ..write('syncGeneration: $syncGeneration, ')
          ..write('syncEpoch: $syncEpoch, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MataKuliahTable extends MataKuliah
    with TableInfo<$MataKuliahTable, MataKuliahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MataKuliahTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama =
      GeneratedColumn<String>('nama', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _dosenMeta = const VerificationMeta('dosen');
  @override
  late final GeneratedColumn<String> dosen = GeneratedColumn<String>(
      'dosen', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sksMeta = const VerificationMeta('sks');
  @override
  late final GeneratedColumn<int> sks = GeneratedColumn<int>(
      'sks', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _semesterMeta =
      const VerificationMeta('semester');
  @override
  late final GeneratedColumn<String> semester = GeneratedColumn<String>(
      'semester', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _warnaMeta = const VerificationMeta('warna');
  @override
  late final GeneratedColumn<String> warna = GeneratedColumn<String>(
      'warna', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        nama,
        dosen,
        sks,
        semester,
        warna
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mata_kuliah';
  @override
  VerificationContext validateIntegrity(Insertable<MataKuliahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('dosen')) {
      context.handle(
          _dosenMeta, dosen.isAcceptableOrUnknown(data['dosen']!, _dosenMeta));
    }
    if (data.containsKey('sks')) {
      context.handle(
          _sksMeta, sks.isAcceptableOrUnknown(data['sks']!, _sksMeta));
    }
    if (data.containsKey('semester')) {
      context.handle(_semesterMeta,
          semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta));
    }
    if (data.containsKey('warna')) {
      context.handle(
          _warnaMeta, warna.isAcceptableOrUnknown(data['warna']!, _warnaMeta));
    } else if (isInserting) {
      context.missing(_warnaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MataKuliahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MataKuliahRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
      dosen: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosen']),
      sks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sks']),
      semester: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}semester']),
      warna: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warna'])!,
    );
  }

  @override
  $MataKuliahTable createAlias(String alias) {
    return $MataKuliahTable(attachedDatabase, alias);
  }
}

class MataKuliahRow extends DataClass implements Insertable<MataKuliahRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final String nama;
  final String? dosen;
  final int? sks;
  final String? semester;
  final String warna;
  const MataKuliahRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      required this.nama,
      this.dosen,
      this.sks,
      this.semester,
      required this.warna});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || dosen != null) {
      map['dosen'] = Variable<String>(dosen);
    }
    if (!nullToAbsent || sks != null) {
      map['sks'] = Variable<int>(sks);
    }
    if (!nullToAbsent || semester != null) {
      map['semester'] = Variable<String>(semester);
    }
    map['warna'] = Variable<String>(warna);
    return map;
  }

  MataKuliahCompanion toCompanion(bool nullToAbsent) {
    return MataKuliahCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      nama: Value(nama),
      dosen:
          dosen == null && nullToAbsent ? const Value.absent() : Value(dosen),
      sks: sks == null && nullToAbsent ? const Value.absent() : Value(sks),
      semester: semester == null && nullToAbsent
          ? const Value.absent()
          : Value(semester),
      warna: Value(warna),
    );
  }

  factory MataKuliahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MataKuliahRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      nama: serializer.fromJson<String>(json['nama']),
      dosen: serializer.fromJson<String?>(json['dosen']),
      sks: serializer.fromJson<int?>(json['sks']),
      semester: serializer.fromJson<String?>(json['semester']),
      warna: serializer.fromJson<String>(json['warna']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'nama': serializer.toJson<String>(nama),
      'dosen': serializer.toJson<String?>(dosen),
      'sks': serializer.toJson<int?>(sks),
      'semester': serializer.toJson<String?>(semester),
      'warna': serializer.toJson<String>(warna),
    };
  }

  MataKuliahRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          String? nama,
          Value<String?> dosen = const Value.absent(),
          Value<int?> sks = const Value.absent(),
          Value<String?> semester = const Value.absent(),
          String? warna}) =>
      MataKuliahRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        nama: nama ?? this.nama,
        dosen: dosen.present ? dosen.value : this.dosen,
        sks: sks.present ? sks.value : this.sks,
        semester: semester.present ? semester.value : this.semester,
        warna: warna ?? this.warna,
      );
  MataKuliahRow copyWithCompanion(MataKuliahCompanion data) {
    return MataKuliahRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      nama: data.nama.present ? data.nama.value : this.nama,
      dosen: data.dosen.present ? data.dosen.value : this.dosen,
      sks: data.sks.present ? data.sks.value : this.sks,
      semester: data.semester.present ? data.semester.value : this.semester,
      warna: data.warna.present ? data.warna.value : this.warna,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MataKuliahRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('nama: $nama, ')
          ..write('dosen: $dosen, ')
          ..write('sks: $sks, ')
          ..write('semester: $semester, ')
          ..write('warna: $warna')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      nama,
      dosen,
      sks,
      semester,
      warna);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MataKuliahRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.nama == this.nama &&
          other.dosen == this.dosen &&
          other.sks == this.sks &&
          other.semester == this.semester &&
          other.warna == this.warna);
}

class MataKuliahCompanion extends UpdateCompanion<MataKuliahRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<String> nama;
  final Value<String?> dosen;
  final Value<int?> sks;
  final Value<String?> semester;
  final Value<String> warna;
  final Value<int> rowid;
  const MataKuliahCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.nama = const Value.absent(),
    this.dosen = const Value.absent(),
    this.sks = const Value.absent(),
    this.semester = const Value.absent(),
    this.warna = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MataKuliahCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    required String nama,
    this.dosen = const Value.absent(),
    this.sks = const Value.absent(),
    this.semester = const Value.absent(),
    required String warna,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId),
        nama = Value(nama),
        warna = Value(warna);
  static Insertable<MataKuliahRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? nama,
    Expression<String>? dosen,
    Expression<int>? sks,
    Expression<String>? semester,
    Expression<String>? warna,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (nama != null) 'nama': nama,
      if (dosen != null) 'dosen': dosen,
      if (sks != null) 'sks': sks,
      if (semester != null) 'semester': semester,
      if (warna != null) 'warna': warna,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MataKuliahCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<String>? nama,
      Value<String?>? dosen,
      Value<int?>? sks,
      Value<String?>? semester,
      Value<String>? warna,
      Value<int>? rowid}) {
    return MataKuliahCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      dosen: dosen ?? this.dosen,
      sks: sks ?? this.sks,
      semester: semester ?? this.semester,
      warna: warna ?? this.warna,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (dosen.present) {
      map['dosen'] = Variable<String>(dosen.value);
    }
    if (sks.present) {
      map['sks'] = Variable<int>(sks.value);
    }
    if (semester.present) {
      map['semester'] = Variable<String>(semester.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MataKuliahCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('nama: $nama, ')
          ..write('dosen: $dosen, ')
          ..write('sks: $sks, ')
          ..write('semester: $semester, ')
          ..write('warna: $warna, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseNoteTable extends CourseNote
    with TableInfo<$CourseNoteTable, CourseNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseNoteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _mataKuliahIdMeta =
      const VerificationMeta('mataKuliahId');
  @override
  late final GeneratedColumn<String> mataKuliahId = GeneratedColumn<String>(
      'mata_kuliah_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mata_kuliah (id)'));
  static const VerificationMeta _tanggalMeta =
      const VerificationMeta('tanggal');
  @override
  late final GeneratedColumn<String> tanggal = GeneratedColumn<String>(
      'tanggal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isiMeta = const VerificationMeta('isi');
  @override
  late final GeneratedColumn<String> isi =
      GeneratedColumn<String>('isi', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        mataKuliahId,
        tanggal,
        isi
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_note';
  @override
  VerificationContext validateIntegrity(Insertable<CourseNoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('mata_kuliah_id')) {
      context.handle(
          _mataKuliahIdMeta,
          mataKuliahId.isAcceptableOrUnknown(
              data['mata_kuliah_id']!, _mataKuliahIdMeta));
    } else if (isInserting) {
      context.missing(_mataKuliahIdMeta);
    }
    if (data.containsKey('tanggal')) {
      context.handle(_tanggalMeta,
          tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta));
    } else if (isInserting) {
      context.missing(_tanggalMeta);
    }
    if (data.containsKey('isi')) {
      context.handle(
          _isiMeta, isi.isAcceptableOrUnknown(data['isi']!, _isiMeta));
    } else if (isInserting) {
      context.missing(_isiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseNoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      mataKuliahId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mata_kuliah_id'])!,
      tanggal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tanggal'])!,
      isi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}isi'])!,
    );
  }

  @override
  $CourseNoteTable createAlias(String alias) {
    return $CourseNoteTable(attachedDatabase, alias);
  }
}

class CourseNoteRow extends DataClass implements Insertable<CourseNoteRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String mataKuliahId;
  final String tanggal;
  final String isi;
  const CourseNoteRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.mataKuliahId,
      required this.tanggal,
      required this.isi});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['mata_kuliah_id'] = Variable<String>(mataKuliahId);
    map['tanggal'] = Variable<String>(tanggal);
    map['isi'] = Variable<String>(isi);
    return map;
  }

  CourseNoteCompanion toCompanion(bool nullToAbsent) {
    return CourseNoteCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      mataKuliahId: Value(mataKuliahId),
      tanggal: Value(tanggal),
      isi: Value(isi),
    );
  }

  factory CourseNoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseNoteRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      mataKuliahId: serializer.fromJson<String>(json['mataKuliahId']),
      tanggal: serializer.fromJson<String>(json['tanggal']),
      isi: serializer.fromJson<String>(json['isi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'mataKuliahId': serializer.toJson<String>(mataKuliahId),
      'tanggal': serializer.toJson<String>(tanggal),
      'isi': serializer.toJson<String>(isi),
    };
  }

  CourseNoteRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? mataKuliahId,
          String? tanggal,
          String? isi}) =>
      CourseNoteRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        mataKuliahId: mataKuliahId ?? this.mataKuliahId,
        tanggal: tanggal ?? this.tanggal,
        isi: isi ?? this.isi,
      );
  CourseNoteRow copyWithCompanion(CourseNoteCompanion data) {
    return CourseNoteRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      mataKuliahId: data.mataKuliahId.present
          ? data.mataKuliahId.value
          : this.mataKuliahId,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
      isi: data.isi.present ? data.isi.value : this.isi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseNoteRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('tanggal: $tanggal, ')
          ..write('isi: $isi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, isDeleted,
      deletedAt, serverRevision, originDeviceId, mataKuliahId, tanggal, isi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseNoteRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.mataKuliahId == this.mataKuliahId &&
          other.tanggal == this.tanggal &&
          other.isi == this.isi);
}

class CourseNoteCompanion extends UpdateCompanion<CourseNoteRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> mataKuliahId;
  final Value<String> tanggal;
  final Value<String> isi;
  final Value<int> rowid;
  const CourseNoteCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.mataKuliahId = const Value.absent(),
    this.tanggal = const Value.absent(),
    this.isi = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseNoteCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String mataKuliahId,
    required String tanggal,
    required String isi,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        mataKuliahId = Value(mataKuliahId),
        tanggal = Value(tanggal),
        isi = Value(isi);
  static Insertable<CourseNoteRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? mataKuliahId,
    Expression<String>? tanggal,
    Expression<String>? isi,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (mataKuliahId != null) 'mata_kuliah_id': mataKuliahId,
      if (tanggal != null) 'tanggal': tanggal,
      if (isi != null) 'isi': isi,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseNoteCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? mataKuliahId,
      Value<String>? tanggal,
      Value<String>? isi,
      Value<int>? rowid}) {
    return CourseNoteCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      tanggal: tanggal ?? this.tanggal,
      isi: isi ?? this.isi,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (mataKuliahId.present) {
      map['mata_kuliah_id'] = Variable<String>(mataKuliahId.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<String>(tanggal.value);
    }
    if (isi.present) {
      map['isi'] = Variable<String>(isi.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseNoteCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('tanggal: $tanggal, ')
          ..write('isi: $isi, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TugasTable extends Tugas with TableInfo<$TugasTable, TugasRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TugasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  static const VerificationMeta _mataKuliahIdMeta =
      const VerificationMeta('mataKuliahId');
  @override
  late final GeneratedColumn<String> mataKuliahId = GeneratedColumn<String>(
      'mata_kuliah_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mata_kuliah (id)'));
  static const VerificationMeta _judulMeta = const VerificationMeta('judul');
  @override
  late final GeneratedColumn<String> judul =
      GeneratedColumn<String>('judul', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _deskripsiMeta =
      const VerificationMeta('deskripsi');
  @override
  late final GeneratedColumn<String> deskripsi = GeneratedColumn<String>(
      'deskripsi', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TugasPrioritas, String>
      prioritas = GeneratedColumn<String>('prioritas', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TugasPrioritas>($TugasTable.$converterprioritas);
  static const VerificationMeta _estimasiMenitMeta =
      const VerificationMeta('estimasiMenit');
  @override
  late final GeneratedColumn<int> estimasiMenit = GeneratedColumn<int>(
      'estimasi_menit', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<TugasStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TugasStatus>($TugasTable.$converterstatus);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<Map<String, Object?>>,
      String> reminders = GeneratedColumn<String>(
          'reminders', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<List<Map<String, Object?>>>(
          $TugasTable.$converterreminders);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        mataKuliahId,
        judul,
        deskripsi,
        deadline,
        prioritas,
        estimasiMenit,
        status,
        completedAt,
        archivedAt,
        reminders
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tugas';
  @override
  VerificationContext validateIntegrity(Insertable<TugasRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('mata_kuliah_id')) {
      context.handle(
          _mataKuliahIdMeta,
          mataKuliahId.isAcceptableOrUnknown(
              data['mata_kuliah_id']!, _mataKuliahIdMeta));
    }
    if (data.containsKey('judul')) {
      context.handle(
          _judulMeta, judul.isAcceptableOrUnknown(data['judul']!, _judulMeta));
    } else if (isInserting) {
      context.missing(_judulMeta);
    }
    if (data.containsKey('deskripsi')) {
      context.handle(_deskripsiMeta,
          deskripsi.isAcceptableOrUnknown(data['deskripsi']!, _deskripsiMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    if (data.containsKey('estimasi_menit')) {
      context.handle(
          _estimasiMenitMeta,
          estimasiMenit.isAcceptableOrUnknown(
              data['estimasi_menit']!, _estimasiMenitMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TugasRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TugasRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      mataKuliahId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mata_kuliah_id']),
      judul: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}judul'])!,
      deskripsi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deskripsi']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline'])!,
      prioritas: $TugasTable.$converterprioritas.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prioritas'])!),
      estimasiMenit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimasi_menit']),
      status: $TugasTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      reminders: $TugasTable.$converterreminders.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminders'])!),
    );
  }

  @override
  $TugasTable createAlias(String alias) {
    return $TugasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TugasPrioritas, String, String>
      $converterprioritas =
      const EnumNameConverter<TugasPrioritas>(TugasPrioritas.values);
  static JsonTypeConverter2<TugasStatus, String, String> $converterstatus =
      const EnumNameConverter<TugasStatus>(TugasStatus.values);
  static TypeConverter<List<Map<String, Object?>>, String> $converterreminders =
      const JsonMapListConverter();
}

class TugasRow extends DataClass implements Insertable<TugasRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final String? mataKuliahId;
  final String judul;
  final String? deskripsi;
  final DateTime deadline;
  final TugasPrioritas prioritas;
  final int? estimasiMenit;
  final TugasStatus status;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  final List<Map<String, Object?>> reminders;
  const TugasRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      this.mataKuliahId,
      required this.judul,
      this.deskripsi,
      required this.deadline,
      required this.prioritas,
      this.estimasiMenit,
      required this.status,
      this.completedAt,
      this.archivedAt,
      required this.reminders});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || mataKuliahId != null) {
      map['mata_kuliah_id'] = Variable<String>(mataKuliahId);
    }
    map['judul'] = Variable<String>(judul);
    if (!nullToAbsent || deskripsi != null) {
      map['deskripsi'] = Variable<String>(deskripsi);
    }
    map['deadline'] = Variable<DateTime>(deadline);
    {
      map['prioritas'] =
          Variable<String>($TugasTable.$converterprioritas.toSql(prioritas));
    }
    if (!nullToAbsent || estimasiMenit != null) {
      map['estimasi_menit'] = Variable<int>(estimasiMenit);
    }
    {
      map['status'] =
          Variable<String>($TugasTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    {
      map['reminders'] =
          Variable<String>($TugasTable.$converterreminders.toSql(reminders));
    }
    return map;
  }

  TugasCompanion toCompanion(bool nullToAbsent) {
    return TugasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      mataKuliahId: mataKuliahId == null && nullToAbsent
          ? const Value.absent()
          : Value(mataKuliahId),
      judul: Value(judul),
      deskripsi: deskripsi == null && nullToAbsent
          ? const Value.absent()
          : Value(deskripsi),
      deadline: Value(deadline),
      prioritas: Value(prioritas),
      estimasiMenit: estimasiMenit == null && nullToAbsent
          ? const Value.absent()
          : Value(estimasiMenit),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      reminders: Value(reminders),
    );
  }

  factory TugasRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TugasRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      mataKuliahId: serializer.fromJson<String?>(json['mataKuliahId']),
      judul: serializer.fromJson<String>(json['judul']),
      deskripsi: serializer.fromJson<String?>(json['deskripsi']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      prioritas: $TugasTable.$converterprioritas
          .fromJson(serializer.fromJson<String>(json['prioritas'])),
      estimasiMenit: serializer.fromJson<int?>(json['estimasiMenit']),
      status: $TugasTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      reminders:
          serializer.fromJson<List<Map<String, Object?>>>(json['reminders']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'mataKuliahId': serializer.toJson<String?>(mataKuliahId),
      'judul': serializer.toJson<String>(judul),
      'deskripsi': serializer.toJson<String?>(deskripsi),
      'deadline': serializer.toJson<DateTime>(deadline),
      'prioritas': serializer
          .toJson<String>($TugasTable.$converterprioritas.toJson(prioritas)),
      'estimasiMenit': serializer.toJson<int?>(estimasiMenit),
      'status': serializer
          .toJson<String>($TugasTable.$converterstatus.toJson(status)),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'reminders': serializer.toJson<List<Map<String, Object?>>>(reminders),
    };
  }

  TugasRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          Value<String?> mataKuliahId = const Value.absent(),
          String? judul,
          Value<String?> deskripsi = const Value.absent(),
          DateTime? deadline,
          TugasPrioritas? prioritas,
          Value<int?> estimasiMenit = const Value.absent(),
          TugasStatus? status,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> archivedAt = const Value.absent(),
          List<Map<String, Object?>>? reminders}) =>
      TugasRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        mataKuliahId:
            mataKuliahId.present ? mataKuliahId.value : this.mataKuliahId,
        judul: judul ?? this.judul,
        deskripsi: deskripsi.present ? deskripsi.value : this.deskripsi,
        deadline: deadline ?? this.deadline,
        prioritas: prioritas ?? this.prioritas,
        estimasiMenit:
            estimasiMenit.present ? estimasiMenit.value : this.estimasiMenit,
        status: status ?? this.status,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        reminders: reminders ?? this.reminders,
      );
  TugasRow copyWithCompanion(TugasCompanion data) {
    return TugasRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      mataKuliahId: data.mataKuliahId.present
          ? data.mataKuliahId.value
          : this.mataKuliahId,
      judul: data.judul.present ? data.judul.value : this.judul,
      deskripsi: data.deskripsi.present ? data.deskripsi.value : this.deskripsi,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      prioritas: data.prioritas.present ? data.prioritas.value : this.prioritas,
      estimasiMenit: data.estimasiMenit.present
          ? data.estimasiMenit.value
          : this.estimasiMenit,
      status: data.status.present ? data.status.value : this.status,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      reminders: data.reminders.present ? data.reminders.value : this.reminders,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TugasRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('judul: $judul, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('deadline: $deadline, ')
          ..write('prioritas: $prioritas, ')
          ..write('estimasiMenit: $estimasiMenit, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('reminders: $reminders')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      mataKuliahId,
      judul,
      deskripsi,
      deadline,
      prioritas,
      estimasiMenit,
      status,
      completedAt,
      archivedAt,
      reminders);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TugasRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.mataKuliahId == this.mataKuliahId &&
          other.judul == this.judul &&
          other.deskripsi == this.deskripsi &&
          other.deadline == this.deadline &&
          other.prioritas == this.prioritas &&
          other.estimasiMenit == this.estimasiMenit &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt &&
          other.reminders == this.reminders);
}

class TugasCompanion extends UpdateCompanion<TugasRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<String?> mataKuliahId;
  final Value<String> judul;
  final Value<String?> deskripsi;
  final Value<DateTime> deadline;
  final Value<TugasPrioritas> prioritas;
  final Value<int?> estimasiMenit;
  final Value<TugasStatus> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> archivedAt;
  final Value<List<Map<String, Object?>>> reminders;
  final Value<int> rowid;
  const TugasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.mataKuliahId = const Value.absent(),
    this.judul = const Value.absent(),
    this.deskripsi = const Value.absent(),
    this.deadline = const Value.absent(),
    this.prioritas = const Value.absent(),
    this.estimasiMenit = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.reminders = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TugasCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    this.mataKuliahId = const Value.absent(),
    required String judul,
    this.deskripsi = const Value.absent(),
    required DateTime deadline,
    required TugasPrioritas prioritas,
    this.estimasiMenit = const Value.absent(),
    required TugasStatus status,
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required List<Map<String, Object?>> reminders,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId),
        judul = Value(judul),
        deadline = Value(deadline),
        prioritas = Value(prioritas),
        status = Value(status),
        reminders = Value(reminders);
  static Insertable<TugasRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? mataKuliahId,
    Expression<String>? judul,
    Expression<String>? deskripsi,
    Expression<DateTime>? deadline,
    Expression<String>? prioritas,
    Expression<int>? estimasiMenit,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? reminders,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (mataKuliahId != null) 'mata_kuliah_id': mataKuliahId,
      if (judul != null) 'judul': judul,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (deadline != null) 'deadline': deadline,
      if (prioritas != null) 'prioritas': prioritas,
      if (estimasiMenit != null) 'estimasi_menit': estimasiMenit,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (reminders != null) 'reminders': reminders,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TugasCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<String?>? mataKuliahId,
      Value<String>? judul,
      Value<String?>? deskripsi,
      Value<DateTime>? deadline,
      Value<TugasPrioritas>? prioritas,
      Value<int?>? estimasiMenit,
      Value<TugasStatus>? status,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? archivedAt,
      Value<List<Map<String, Object?>>>? reminders,
      Value<int>? rowid}) {
    return TugasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      mataKuliahId: mataKuliahId ?? this.mataKuliahId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      deadline: deadline ?? this.deadline,
      prioritas: prioritas ?? this.prioritas,
      estimasiMenit: estimasiMenit ?? this.estimasiMenit,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      reminders: reminders ?? this.reminders,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (mataKuliahId.present) {
      map['mata_kuliah_id'] = Variable<String>(mataKuliahId.value);
    }
    if (judul.present) {
      map['judul'] = Variable<String>(judul.value);
    }
    if (deskripsi.present) {
      map['deskripsi'] = Variable<String>(deskripsi.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (prioritas.present) {
      map['prioritas'] = Variable<String>(
          $TugasTable.$converterprioritas.toSql(prioritas.value));
    }
    if (estimasiMenit.present) {
      map['estimasi_menit'] = Variable<int>(estimasiMenit.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($TugasTable.$converterstatus.toSql(status.value));
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<String>(
          $TugasTable.$converterreminders.toSql(reminders.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TugasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('mataKuliahId: $mataKuliahId, ')
          ..write('judul: $judul, ')
          ..write('deskripsi: $deskripsi, ')
          ..write('deadline: $deadline, ')
          ..write('prioritas: $prioritas, ')
          ..write('estimasiMenit: $estimasiMenit, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('reminders: $reminders, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TugasChecklistTable extends TugasChecklist
    with TableInfo<$TugasChecklistTable, TugasChecklistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TugasChecklistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _tugasIdMeta =
      const VerificationMeta('tugasId');
  @override
  late final GeneratedColumn<String> tugasId = GeneratedColumn<String>(
      'tugas_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tugas (id)'));
  static const VerificationMeta _judulMeta = const VerificationMeta('judul');
  @override
  late final GeneratedColumn<String> judul =
      GeneratedColumn<String>('judul', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _urutanMeta = const VerificationMeta('urutan');
  @override
  late final GeneratedColumn<int> urutan = GeneratedColumn<int>(
      'urutan', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        tugasId,
        judul,
        isDone,
        urutan
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tugas_checklist';
  @override
  VerificationContext validateIntegrity(Insertable<TugasChecklistRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('tugas_id')) {
      context.handle(_tugasIdMeta,
          tugasId.isAcceptableOrUnknown(data['tugas_id']!, _tugasIdMeta));
    } else if (isInserting) {
      context.missing(_tugasIdMeta);
    }
    if (data.containsKey('judul')) {
      context.handle(
          _judulMeta, judul.isAcceptableOrUnknown(data['judul']!, _judulMeta));
    } else if (isInserting) {
      context.missing(_judulMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('urutan')) {
      context.handle(_urutanMeta,
          urutan.isAcceptableOrUnknown(data['urutan']!, _urutanMeta));
    } else if (isInserting) {
      context.missing(_urutanMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TugasChecklistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TugasChecklistRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      tugasId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tugas_id'])!,
      judul: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}judul'])!,
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      urutan: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}urutan'])!,
    );
  }

  @override
  $TugasChecklistTable createAlias(String alias) {
    return $TugasChecklistTable(attachedDatabase, alias);
  }
}

class TugasChecklistRow extends DataClass
    implements Insertable<TugasChecklistRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String tugasId;
  final String judul;
  final bool isDone;
  final int urutan;
  const TugasChecklistRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.tugasId,
      required this.judul,
      required this.isDone,
      required this.urutan});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['tugas_id'] = Variable<String>(tugasId);
    map['judul'] = Variable<String>(judul);
    map['is_done'] = Variable<bool>(isDone);
    map['urutan'] = Variable<int>(urutan);
    return map;
  }

  TugasChecklistCompanion toCompanion(bool nullToAbsent) {
    return TugasChecklistCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      tugasId: Value(tugasId),
      judul: Value(judul),
      isDone: Value(isDone),
      urutan: Value(urutan),
    );
  }

  factory TugasChecklistRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TugasChecklistRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      tugasId: serializer.fromJson<String>(json['tugasId']),
      judul: serializer.fromJson<String>(json['judul']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      urutan: serializer.fromJson<int>(json['urutan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'tugasId': serializer.toJson<String>(tugasId),
      'judul': serializer.toJson<String>(judul),
      'isDone': serializer.toJson<bool>(isDone),
      'urutan': serializer.toJson<int>(urutan),
    };
  }

  TugasChecklistRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? tugasId,
          String? judul,
          bool? isDone,
          int? urutan}) =>
      TugasChecklistRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        tugasId: tugasId ?? this.tugasId,
        judul: judul ?? this.judul,
        isDone: isDone ?? this.isDone,
        urutan: urutan ?? this.urutan,
      );
  TugasChecklistRow copyWithCompanion(TugasChecklistCompanion data) {
    return TugasChecklistRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      tugasId: data.tugasId.present ? data.tugasId.value : this.tugasId,
      judul: data.judul.present ? data.judul.value : this.judul,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      urutan: data.urutan.present ? data.urutan.value : this.urutan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TugasChecklistRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('tugasId: $tugasId, ')
          ..write('judul: $judul, ')
          ..write('isDone: $isDone, ')
          ..write('urutan: $urutan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      tugasId,
      judul,
      isDone,
      urutan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TugasChecklistRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.tugasId == this.tugasId &&
          other.judul == this.judul &&
          other.isDone == this.isDone &&
          other.urutan == this.urutan);
}

class TugasChecklistCompanion extends UpdateCompanion<TugasChecklistRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> tugasId;
  final Value<String> judul;
  final Value<bool> isDone;
  final Value<int> urutan;
  final Value<int> rowid;
  const TugasChecklistCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.tugasId = const Value.absent(),
    this.judul = const Value.absent(),
    this.isDone = const Value.absent(),
    this.urutan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TugasChecklistCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String tugasId,
    required String judul,
    this.isDone = const Value.absent(),
    required int urutan,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        tugasId = Value(tugasId),
        judul = Value(judul),
        urutan = Value(urutan);
  static Insertable<TugasChecklistRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? tugasId,
    Expression<String>? judul,
    Expression<bool>? isDone,
    Expression<int>? urutan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (tugasId != null) 'tugas_id': tugasId,
      if (judul != null) 'judul': judul,
      if (isDone != null) 'is_done': isDone,
      if (urutan != null) 'urutan': urutan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TugasChecklistCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? tugasId,
      Value<String>? judul,
      Value<bool>? isDone,
      Value<int>? urutan,
      Value<int>? rowid}) {
    return TugasChecklistCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      tugasId: tugasId ?? this.tugasId,
      judul: judul ?? this.judul,
      isDone: isDone ?? this.isDone,
      urutan: urutan ?? this.urutan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (tugasId.present) {
      map['tugas_id'] = Variable<String>(tugasId.value);
    }
    if (judul.present) {
      map['judul'] = Variable<String>(judul.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (urutan.present) {
      map['urutan'] = Variable<int>(urutan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TugasChecklistCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('tugasId: $tugasId, ')
          ..write('judul: $judul, ')
          ..write('isDone: $isDone, ')
          ..write('urutan: $urutan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityCategoryTable extends ActivityCategory
    with TableInfo<$ActivityCategoryTable, ActivityCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityCategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama =
      GeneratedColumn<String>('nama', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _warnaMeta = const VerificationMeta('warna');
  @override
  late final GeneratedColumn<String> warna = GeneratedColumn<String>(
      'warna', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSystemMeta =
      const VerificationMeta('isSystem');
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
      'is_system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_system" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        nama,
        warna,
        icon,
        isSystem,
        isArchived
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_category';
  @override
  VerificationContext validateIntegrity(
      Insertable<ActivityCategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('warna')) {
      context.handle(
          _warnaMeta, warna.isAcceptableOrUnknown(data['warna']!, _warnaMeta));
    } else if (isInserting) {
      context.missing(_warnaMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_system')) {
      context.handle(_isSystemMeta,
          isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityCategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
      warna: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warna'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      isSystem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_system'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $ActivityCategoryTable createAlias(String alias) {
    return $ActivityCategoryTable(attachedDatabase, alias);
  }
}

class ActivityCategoryRow extends DataClass
    implements Insertable<ActivityCategoryRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final String nama;
  final String warna;
  final String? icon;
  final bool isSystem;
  final bool isArchived;
  const ActivityCategoryRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      required this.nama,
      required this.warna,
      this.icon,
      required this.isSystem,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    map['nama'] = Variable<String>(nama);
    map['warna'] = Variable<String>(warna);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  ActivityCategoryCompanion toCompanion(bool nullToAbsent) {
    return ActivityCategoryCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      nama: Value(nama),
      warna: Value(warna),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      isSystem: Value(isSystem),
      isArchived: Value(isArchived),
    );
  }

  factory ActivityCategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityCategoryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      nama: serializer.fromJson<String>(json['nama']),
      warna: serializer.fromJson<String>(json['warna']),
      icon: serializer.fromJson<String?>(json['icon']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'nama': serializer.toJson<String>(nama),
      'warna': serializer.toJson<String>(warna),
      'icon': serializer.toJson<String?>(icon),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  ActivityCategoryRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          String? nama,
          String? warna,
          Value<String?> icon = const Value.absent(),
          bool? isSystem,
          bool? isArchived}) =>
      ActivityCategoryRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        nama: nama ?? this.nama,
        warna: warna ?? this.warna,
        icon: icon.present ? icon.value : this.icon,
        isSystem: isSystem ?? this.isSystem,
        isArchived: isArchived ?? this.isArchived,
      );
  ActivityCategoryRow copyWithCompanion(ActivityCategoryCompanion data) {
    return ActivityCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      nama: data.nama.present ? data.nama.value : this.nama,
      warna: data.warna.present ? data.warna.value : this.warna,
      icon: data.icon.present ? data.icon.value : this.icon,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCategoryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('nama: $nama, ')
          ..write('warna: $warna, ')
          ..write('icon: $icon, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      nama,
      warna,
      icon,
      isSystem,
      isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityCategoryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.nama == this.nama &&
          other.warna == this.warna &&
          other.icon == this.icon &&
          other.isSystem == this.isSystem &&
          other.isArchived == this.isArchived);
}

class ActivityCategoryCompanion extends UpdateCompanion<ActivityCategoryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<String> nama;
  final Value<String> warna;
  final Value<String?> icon;
  final Value<bool> isSystem;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const ActivityCategoryCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.nama = const Value.absent(),
    this.warna = const Value.absent(),
    this.icon = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityCategoryCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    required String nama,
    required String warna,
    this.icon = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId),
        nama = Value(nama),
        warna = Value(warna);
  static Insertable<ActivityCategoryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? nama,
    Expression<String>? warna,
    Expression<String>? icon,
    Expression<bool>? isSystem,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (nama != null) 'nama': nama,
      if (warna != null) 'warna': warna,
      if (icon != null) 'icon': icon,
      if (isSystem != null) 'is_system': isSystem,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCategoryCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<String>? nama,
      Value<String>? warna,
      Value<String?>? icon,
      Value<bool>? isSystem,
      Value<bool>? isArchived,
      Value<int>? rowid}) {
    return ActivityCategoryCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      warna: warna ?? this.warna,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (warna.present) {
      map['warna'] = Variable<String>(warna.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCategoryCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('nama: $nama, ')
          ..write('warna: $warna, ')
          ..write('icon: $icon, ')
          ..write('isSystem: $isSystem, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityRecurrenceTable extends ActivityRecurrence
    with TableInfo<$ActivityRecurrenceTable, ActivityRecurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityRecurrenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  static const VerificationMeta _judulMeta = const VerificationMeta('judul');
  @override
  late final GeneratedColumn<String> judul =
      GeneratedColumn<String>('judul', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _activityCategoryIdMeta =
      const VerificationMeta('activityCategoryId');
  @override
  late final GeneratedColumn<String> activityCategoryId =
      GeneratedColumn<String>('activity_category_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 36, maxTextLength: 36),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES activity_category (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAllDayMeta =
      const VerificationMeta('isAllDay');
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
      'is_all_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_all_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> recurringDays =
      GeneratedColumn<String>('recurring_days', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<int>>(
              $ActivityRecurrenceTable.$converterrecurringDays);
  static const VerificationMeta _startsOnMeta =
      const VerificationMeta('startsOn');
  @override
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
      'starts_on', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
      'ends_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
      reminderOffsetsMinutes = GeneratedColumn<String>(
              'reminder_offsets_minutes', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<int>>(
              $ActivityRecurrenceTable.$converterreminderOffsetsMinutes);
  static const VerificationMeta _catatanMeta =
      const VerificationMeta('catatan');
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
      'catatan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materializedThroughDateMeta =
      const VerificationMeta('materializedThroughDate');
  @override
  late final GeneratedColumn<String> materializedThroughDate =
      GeneratedColumn<String>('materialized_through_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        judul,
        activityCategoryId,
        startTime,
        endTime,
        isAllDay,
        recurringDays,
        startsOn,
        endsOn,
        reminderOffsetsMinutes,
        catatan,
        materializedThroughDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_recurrence';
  @override
  VerificationContext validateIntegrity(
      Insertable<ActivityRecurrenceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('judul')) {
      context.handle(
          _judulMeta, judul.isAcceptableOrUnknown(data['judul']!, _judulMeta));
    } else if (isInserting) {
      context.missing(_judulMeta);
    }
    if (data.containsKey('activity_category_id')) {
      context.handle(
          _activityCategoryIdMeta,
          activityCategoryId.isAcceptableOrUnknown(
              data['activity_category_id']!, _activityCategoryIdMeta));
    } else if (isInserting) {
      context.missing(_activityCategoryIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('is_all_day')) {
      context.handle(_isAllDayMeta,
          isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta));
    }
    if (data.containsKey('starts_on')) {
      context.handle(_startsOnMeta,
          startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta));
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(_endsOnMeta,
          endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta));
    }
    if (data.containsKey('catatan')) {
      context.handle(_catatanMeta,
          catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta));
    }
    if (data.containsKey('materialized_through_date')) {
      context.handle(
          _materializedThroughDateMeta,
          materializedThroughDate.isAcceptableOrUnknown(
              data['materialized_through_date']!,
              _materializedThroughDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRecurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRecurrenceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      judul: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}judul'])!,
      activityCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}activity_category_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time']),
      isAllDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_all_day'])!,
      recurringDays: $ActivityRecurrenceTable.$converterrecurringDays.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}recurring_days'])!),
      startsOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}starts_on'])!,
      endsOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ends_on']),
      reminderOffsetsMinutes: $ActivityRecurrenceTable
          .$converterreminderOffsetsMinutes
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}reminder_offsets_minutes'])!),
      catatan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catatan']),
      materializedThroughDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}materialized_through_date']),
    );
  }

  @override
  $ActivityRecurrenceTable createAlias(String alias) {
    return $ActivityRecurrenceTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterrecurringDays =
      const IntListConverter();
  static TypeConverter<List<int>, String> $converterreminderOffsetsMinutes =
      const IntListConverter();
}

class ActivityRecurrenceRow extends DataClass
    implements Insertable<ActivityRecurrenceRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final String judul;
  final String activityCategoryId;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;
  final List<int> recurringDays;
  final String startsOn;
  final String? endsOn;
  final List<int> reminderOffsetsMinutes;
  final String? catatan;
  final String? materializedThroughDate;
  const ActivityRecurrenceRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      required this.judul,
      required this.activityCategoryId,
      this.startTime,
      this.endTime,
      required this.isAllDay,
      required this.recurringDays,
      required this.startsOn,
      this.endsOn,
      required this.reminderOffsetsMinutes,
      this.catatan,
      this.materializedThroughDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    map['judul'] = Variable<String>(judul);
    map['activity_category_id'] = Variable<String>(activityCategoryId);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    {
      map['recurring_days'] = Variable<String>($ActivityRecurrenceTable
          .$converterrecurringDays
          .toSql(recurringDays));
    }
    map['starts_on'] = Variable<String>(startsOn);
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<String>(endsOn);
    }
    {
      map['reminder_offsets_minutes'] = Variable<String>(
          $ActivityRecurrenceTable.$converterreminderOffsetsMinutes
              .toSql(reminderOffsetsMinutes));
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    if (!nullToAbsent || materializedThroughDate != null) {
      map['materialized_through_date'] =
          Variable<String>(materializedThroughDate);
    }
    return map;
  }

  ActivityRecurrenceCompanion toCompanion(bool nullToAbsent) {
    return ActivityRecurrenceCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      judul: Value(judul),
      activityCategoryId: Value(activityCategoryId),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      isAllDay: Value(isAllDay),
      recurringDays: Value(recurringDays),
      startsOn: Value(startsOn),
      endsOn:
          endsOn == null && nullToAbsent ? const Value.absent() : Value(endsOn),
      reminderOffsetsMinutes: Value(reminderOffsetsMinutes),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
      materializedThroughDate: materializedThroughDate == null && nullToAbsent
          ? const Value.absent()
          : Value(materializedThroughDate),
    );
  }

  factory ActivityRecurrenceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRecurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      judul: serializer.fromJson<String>(json['judul']),
      activityCategoryId:
          serializer.fromJson<String>(json['activityCategoryId']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      recurringDays: serializer.fromJson<List<int>>(json['recurringDays']),
      startsOn: serializer.fromJson<String>(json['startsOn']),
      endsOn: serializer.fromJson<String?>(json['endsOn']),
      reminderOffsetsMinutes:
          serializer.fromJson<List<int>>(json['reminderOffsetsMinutes']),
      catatan: serializer.fromJson<String?>(json['catatan']),
      materializedThroughDate:
          serializer.fromJson<String?>(json['materializedThroughDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'judul': serializer.toJson<String>(judul),
      'activityCategoryId': serializer.toJson<String>(activityCategoryId),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'recurringDays': serializer.toJson<List<int>>(recurringDays),
      'startsOn': serializer.toJson<String>(startsOn),
      'endsOn': serializer.toJson<String?>(endsOn),
      'reminderOffsetsMinutes':
          serializer.toJson<List<int>>(reminderOffsetsMinutes),
      'catatan': serializer.toJson<String?>(catatan),
      'materializedThroughDate':
          serializer.toJson<String?>(materializedThroughDate),
    };
  }

  ActivityRecurrenceRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          String? judul,
          String? activityCategoryId,
          Value<String?> startTime = const Value.absent(),
          Value<String?> endTime = const Value.absent(),
          bool? isAllDay,
          List<int>? recurringDays,
          String? startsOn,
          Value<String?> endsOn = const Value.absent(),
          List<int>? reminderOffsetsMinutes,
          Value<String?> catatan = const Value.absent(),
          Value<String?> materializedThroughDate = const Value.absent()}) =>
      ActivityRecurrenceRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        judul: judul ?? this.judul,
        activityCategoryId: activityCategoryId ?? this.activityCategoryId,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        isAllDay: isAllDay ?? this.isAllDay,
        recurringDays: recurringDays ?? this.recurringDays,
        startsOn: startsOn ?? this.startsOn,
        endsOn: endsOn.present ? endsOn.value : this.endsOn,
        reminderOffsetsMinutes:
            reminderOffsetsMinutes ?? this.reminderOffsetsMinutes,
        catatan: catatan.present ? catatan.value : this.catatan,
        materializedThroughDate: materializedThroughDate.present
            ? materializedThroughDate.value
            : this.materializedThroughDate,
      );
  ActivityRecurrenceRow copyWithCompanion(ActivityRecurrenceCompanion data) {
    return ActivityRecurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      judul: data.judul.present ? data.judul.value : this.judul,
      activityCategoryId: data.activityCategoryId.present
          ? data.activityCategoryId.value
          : this.activityCategoryId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      recurringDays: data.recurringDays.present
          ? data.recurringDays.value
          : this.recurringDays,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      reminderOffsetsMinutes: data.reminderOffsetsMinutes.present
          ? data.reminderOffsetsMinutes.value
          : this.reminderOffsetsMinutes,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
      materializedThroughDate: data.materializedThroughDate.present
          ? data.materializedThroughDate.value
          : this.materializedThroughDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecurrenceRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('judul: $judul, ')
          ..write('activityCategoryId: $activityCategoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('recurringDays: $recurringDays, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('reminderOffsetsMinutes: $reminderOffsetsMinutes, ')
          ..write('catatan: $catatan, ')
          ..write('materializedThroughDate: $materializedThroughDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      judul,
      activityCategoryId,
      startTime,
      endTime,
      isAllDay,
      recurringDays,
      startsOn,
      endsOn,
      reminderOffsetsMinutes,
      catatan,
      materializedThroughDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRecurrenceRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.judul == this.judul &&
          other.activityCategoryId == this.activityCategoryId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isAllDay == this.isAllDay &&
          other.recurringDays == this.recurringDays &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.reminderOffsetsMinutes == this.reminderOffsetsMinutes &&
          other.catatan == this.catatan &&
          other.materializedThroughDate == this.materializedThroughDate);
}

class ActivityRecurrenceCompanion
    extends UpdateCompanion<ActivityRecurrenceRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<String> judul;
  final Value<String> activityCategoryId;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<bool> isAllDay;
  final Value<List<int>> recurringDays;
  final Value<String> startsOn;
  final Value<String?> endsOn;
  final Value<List<int>> reminderOffsetsMinutes;
  final Value<String?> catatan;
  final Value<String?> materializedThroughDate;
  final Value<int> rowid;
  const ActivityRecurrenceCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.judul = const Value.absent(),
    this.activityCategoryId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.recurringDays = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.reminderOffsetsMinutes = const Value.absent(),
    this.catatan = const Value.absent(),
    this.materializedThroughDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityRecurrenceCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    required String judul,
    required String activityCategoryId,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isAllDay = const Value.absent(),
    required List<int> recurringDays,
    required String startsOn,
    this.endsOn = const Value.absent(),
    this.reminderOffsetsMinutes = const Value.absent(),
    this.catatan = const Value.absent(),
    this.materializedThroughDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId),
        judul = Value(judul),
        activityCategoryId = Value(activityCategoryId),
        recurringDays = Value(recurringDays),
        startsOn = Value(startsOn);
  static Insertable<ActivityRecurrenceRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? judul,
    Expression<String>? activityCategoryId,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<bool>? isAllDay,
    Expression<String>? recurringDays,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<String>? reminderOffsetsMinutes,
    Expression<String>? catatan,
    Expression<String>? materializedThroughDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (judul != null) 'judul': judul,
      if (activityCategoryId != null)
        'activity_category_id': activityCategoryId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (recurringDays != null) 'recurring_days': recurringDays,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (reminderOffsetsMinutes != null)
        'reminder_offsets_minutes': reminderOffsetsMinutes,
      if (catatan != null) 'catatan': catatan,
      if (materializedThroughDate != null)
        'materialized_through_date': materializedThroughDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityRecurrenceCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<String>? judul,
      Value<String>? activityCategoryId,
      Value<String?>? startTime,
      Value<String?>? endTime,
      Value<bool>? isAllDay,
      Value<List<int>>? recurringDays,
      Value<String>? startsOn,
      Value<String?>? endsOn,
      Value<List<int>>? reminderOffsetsMinutes,
      Value<String?>? catatan,
      Value<String?>? materializedThroughDate,
      Value<int>? rowid}) {
    return ActivityRecurrenceCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      judul: judul ?? this.judul,
      activityCategoryId: activityCategoryId ?? this.activityCategoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      recurringDays: recurringDays ?? this.recurringDays,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      reminderOffsetsMinutes:
          reminderOffsetsMinutes ?? this.reminderOffsetsMinutes,
      catatan: catatan ?? this.catatan,
      materializedThroughDate:
          materializedThroughDate ?? this.materializedThroughDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (judul.present) {
      map['judul'] = Variable<String>(judul.value);
    }
    if (activityCategoryId.present) {
      map['activity_category_id'] = Variable<String>(activityCategoryId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (recurringDays.present) {
      map['recurring_days'] = Variable<String>($ActivityRecurrenceTable
          .$converterrecurringDays
          .toSql(recurringDays.value));
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (reminderOffsetsMinutes.present) {
      map['reminder_offsets_minutes'] = Variable<String>(
          $ActivityRecurrenceTable.$converterreminderOffsetsMinutes
              .toSql(reminderOffsetsMinutes.value));
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (materializedThroughDate.present) {
      map['materialized_through_date'] =
          Variable<String>(materializedThroughDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecurrenceCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('judul: $judul, ')
          ..write('activityCategoryId: $activityCategoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('recurringDays: $recurringDays, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('reminderOffsetsMinutes: $reminderOffsetsMinutes, ')
          ..write('catatan: $catatan, ')
          ..write('materializedThroughDate: $materializedThroughDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityTable extends Activity
    with TableInfo<$ActivityTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverRevisionMeta =
      const VerificationMeta('serverRevision');
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
      'server_revision', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originDeviceIdMeta =
      const VerificationMeta('originDeviceId');
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
      'origin_device_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user (id)'));
  static const VerificationMeta _recurrenceIdMeta =
      const VerificationMeta('recurrenceId');
  @override
  late final GeneratedColumn<String> recurrenceId = GeneratedColumn<String>(
      'recurrence_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES activity_recurrence (id)'));
  static const VerificationMeta _occurrenceDateMeta =
      const VerificationMeta('occurrenceDate');
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
      'occurrence_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _judulMeta = const VerificationMeta('judul');
  @override
  late final GeneratedColumn<String> judul =
      GeneratedColumn<String>('judul', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _activityCategoryIdMeta =
      const VerificationMeta('activityCategoryId');
  @override
  late final GeneratedColumn<String> activityCategoryId =
      GeneratedColumn<String>('activity_category_id', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 36, maxTextLength: 36),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES activity_category (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isAllDayMeta =
      const VerificationMeta('isAllDay');
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
      'is_all_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_all_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<ActivityStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ActivityStatus>($ActivityTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<ActivitySource, String> source =
      GeneratedColumn<String>('source', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ActivitySource>($ActivityTable.$convertersource);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
      reminderOffsetsMinutes = GeneratedColumn<String>(
              'reminder_offsets_minutes', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('[]'))
          .withConverter<List<int>>(
              $ActivityTable.$converterreminderOffsetsMinutes);
  static const VerificationMeta _catatanMeta =
      const VerificationMeta('catatan');
  @override
  late final GeneratedColumn<String> catatan = GeneratedColumn<String>(
      'catatan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt,
        serverRevision,
        originDeviceId,
        userId,
        recurrenceId,
        occurrenceDate,
        judul,
        activityCategoryId,
        startTime,
        endTime,
        isAllDay,
        status,
        source,
        sourceId,
        reminderOffsetsMinutes,
        catatan
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('server_revision')) {
      context.handle(
          _serverRevisionMeta,
          serverRevision.isAcceptableOrUnknown(
              data['server_revision']!, _serverRevisionMeta));
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
          _originDeviceIdMeta,
          originDeviceId.isAcceptableOrUnknown(
              data['origin_device_id']!, _originDeviceIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('recurrence_id')) {
      context.handle(
          _recurrenceIdMeta,
          recurrenceId.isAcceptableOrUnknown(
              data['recurrence_id']!, _recurrenceIdMeta));
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
          _occurrenceDateMeta,
          occurrenceDate.isAcceptableOrUnknown(
              data['occurrence_date']!, _occurrenceDateMeta));
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('judul')) {
      context.handle(
          _judulMeta, judul.isAcceptableOrUnknown(data['judul']!, _judulMeta));
    } else if (isInserting) {
      context.missing(_judulMeta);
    }
    if (data.containsKey('activity_category_id')) {
      context.handle(
          _activityCategoryIdMeta,
          activityCategoryId.isAcceptableOrUnknown(
              data['activity_category_id']!, _activityCategoryIdMeta));
    } else if (isInserting) {
      context.missing(_activityCategoryIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('is_all_day')) {
      context.handle(_isAllDayMeta,
          isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('catatan')) {
      context.handle(_catatanMeta,
          catatan.isAcceptableOrUnknown(data['catatan']!, _catatanMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      serverRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_revision']),
      originDeviceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_device_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      recurrenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence_id']),
      occurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}occurrence_date'])!,
      judul: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}judul'])!,
      activityCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}activity_category_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      isAllDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_all_day'])!,
      status: $ActivityTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      source: $ActivityTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      reminderOffsetsMinutes: $ActivityTable.$converterreminderOffsetsMinutes
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}reminder_offsets_minutes'])!),
      catatan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catatan']),
    );
  }

  @override
  $ActivityTable createAlias(String alias) {
    return $ActivityTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityStatus, String, String> $converterstatus =
      const EnumNameConverter<ActivityStatus>(ActivityStatus.values);
  static JsonTypeConverter2<ActivitySource, String, String> $convertersource =
      const EnumNameConverter<ActivitySource>(ActivitySource.values);
  static TypeConverter<List<int>, String> $converterreminderOffsetsMinutes =
      const IntListConverter();
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  /// Primary key; client can mint the UUID while offline.
  final String id;

  /// Creation time from the origin device (Instant, UTC).
  final DateTime createdAt;

  /// Last mutation time from the origin device (Instant, UTC). Audit metadata,
  /// not a pull cursor.
  final DateTime updatedAt;

  /// Soft-delete flag; deletes use a tombstone.
  final bool isDeleted;

  /// Set when [isDeleted] is true; null while the row is active.
  final DateTime? deletedAt;

  /// Revision the server assigned after accepting a mutation. Client never mints
  /// this; null until first accepted.
  final int? serverRevision;
  final String? originDeviceId;
  final String userId;
  final String? recurrenceId;
  final String occurrenceDate;
  final String judul;
  final String activityCategoryId;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final ActivityStatus status;
  final ActivitySource source;
  final String? sourceId;
  final List<int> reminderOffsetsMinutes;
  final String? catatan;
  const ActivityRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt,
      this.serverRevision,
      this.originDeviceId,
      required this.userId,
      this.recurrenceId,
      required this.occurrenceDate,
      required this.judul,
      required this.activityCategoryId,
      this.startTime,
      this.endTime,
      required this.isAllDay,
      required this.status,
      required this.source,
      this.sourceId,
      required this.reminderOffsetsMinutes,
      this.catatan});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || recurrenceId != null) {
      map['recurrence_id'] = Variable<String>(recurrenceId);
    }
    map['occurrence_date'] = Variable<String>(occurrenceDate);
    map['judul'] = Variable<String>(judul);
    map['activity_category_id'] = Variable<String>(activityCategoryId);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    {
      map['status'] =
          Variable<String>($ActivityTable.$converterstatus.toSql(status));
    }
    {
      map['source'] =
          Variable<String>($ActivityTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    {
      map['reminder_offsets_minutes'] = Variable<String>($ActivityTable
          .$converterreminderOffsetsMinutes
          .toSql(reminderOffsetsMinutes));
    }
    if (!nullToAbsent || catatan != null) {
      map['catatan'] = Variable<String>(catatan);
    }
    return map;
  }

  ActivityCompanion toCompanion(bool nullToAbsent) {
    return ActivityCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
      userId: Value(userId),
      recurrenceId: recurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceId),
      occurrenceDate: Value(occurrenceDate),
      judul: Value(judul),
      activityCategoryId: Value(activityCategoryId),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      isAllDay: Value(isAllDay),
      status: Value(status),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      reminderOffsetsMinutes: Value(reminderOffsetsMinutes),
      catatan: catatan == null && nullToAbsent
          ? const Value.absent()
          : Value(catatan),
    );
  }

  factory ActivityRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
      userId: serializer.fromJson<String>(json['userId']),
      recurrenceId: serializer.fromJson<String?>(json['recurrenceId']),
      occurrenceDate: serializer.fromJson<String>(json['occurrenceDate']),
      judul: serializer.fromJson<String>(json['judul']),
      activityCategoryId:
          serializer.fromJson<String>(json['activityCategoryId']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      status: $ActivityTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      source: $ActivityTable.$convertersource
          .fromJson(serializer.fromJson<String>(json['source'])),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      reminderOffsetsMinutes:
          serializer.fromJson<List<int>>(json['reminderOffsetsMinutes']),
      catatan: serializer.fromJson<String?>(json['catatan']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
      'userId': serializer.toJson<String>(userId),
      'recurrenceId': serializer.toJson<String?>(recurrenceId),
      'occurrenceDate': serializer.toJson<String>(occurrenceDate),
      'judul': serializer.toJson<String>(judul),
      'activityCategoryId': serializer.toJson<String>(activityCategoryId),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'status': serializer
          .toJson<String>($ActivityTable.$converterstatus.toJson(status)),
      'source': serializer
          .toJson<String>($ActivityTable.$convertersource.toJson(source)),
      'sourceId': serializer.toJson<String?>(sourceId),
      'reminderOffsetsMinutes':
          serializer.toJson<List<int>>(reminderOffsetsMinutes),
      'catatan': serializer.toJson<String?>(catatan),
    };
  }

  ActivityRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<int?> serverRevision = const Value.absent(),
          Value<String?> originDeviceId = const Value.absent(),
          String? userId,
          Value<String?> recurrenceId = const Value.absent(),
          String? occurrenceDate,
          String? judul,
          String? activityCategoryId,
          Value<DateTime?> startTime = const Value.absent(),
          Value<DateTime?> endTime = const Value.absent(),
          bool? isAllDay,
          ActivityStatus? status,
          ActivitySource? source,
          Value<String?> sourceId = const Value.absent(),
          List<int>? reminderOffsetsMinutes,
          Value<String?> catatan = const Value.absent()}) =>
      ActivityRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        serverRevision:
            serverRevision.present ? serverRevision.value : this.serverRevision,
        originDeviceId:
            originDeviceId.present ? originDeviceId.value : this.originDeviceId,
        userId: userId ?? this.userId,
        recurrenceId:
            recurrenceId.present ? recurrenceId.value : this.recurrenceId,
        occurrenceDate: occurrenceDate ?? this.occurrenceDate,
        judul: judul ?? this.judul,
        activityCategoryId: activityCategoryId ?? this.activityCategoryId,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        isAllDay: isAllDay ?? this.isAllDay,
        status: status ?? this.status,
        source: source ?? this.source,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        reminderOffsetsMinutes:
            reminderOffsetsMinutes ?? this.reminderOffsetsMinutes,
        catatan: catatan.present ? catatan.value : this.catatan,
      );
  ActivityRow copyWithCompanion(ActivityCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      recurrenceId: data.recurrenceId.present
          ? data.recurrenceId.value
          : this.recurrenceId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      judul: data.judul.present ? data.judul.value : this.judul,
      activityCategoryId: data.activityCategoryId.present
          ? data.activityCategoryId.value
          : this.activityCategoryId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      reminderOffsetsMinutes: data.reminderOffsetsMinutes.present
          ? data.reminderOffsetsMinutes.value
          : this.reminderOffsetsMinutes,
      catatan: data.catatan.present ? data.catatan.value : this.catatan,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('judul: $judul, ')
          ..write('activityCategoryId: $activityCategoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('reminderOffsetsMinutes: $reminderOffsetsMinutes, ')
          ..write('catatan: $catatan')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      serverRevision,
      originDeviceId,
      userId,
      recurrenceId,
      occurrenceDate,
      judul,
      activityCategoryId,
      startTime,
      endTime,
      isAllDay,
      status,
      source,
      sourceId,
      reminderOffsetsMinutes,
      catatan);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt &&
          other.serverRevision == this.serverRevision &&
          other.originDeviceId == this.originDeviceId &&
          other.userId == this.userId &&
          other.recurrenceId == this.recurrenceId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.judul == this.judul &&
          other.activityCategoryId == this.activityCategoryId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isAllDay == this.isAllDay &&
          other.status == this.status &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.reminderOffsetsMinutes == this.reminderOffsetsMinutes &&
          other.catatan == this.catatan);
}

class ActivityCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverRevision;
  final Value<String?> originDeviceId;
  final Value<String> userId;
  final Value<String?> recurrenceId;
  final Value<String> occurrenceDate;
  final Value<String> judul;
  final Value<String> activityCategoryId;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<bool> isAllDay;
  final Value<ActivityStatus> status;
  final Value<ActivitySource> source;
  final Value<String?> sourceId;
  final Value<List<int>> reminderOffsetsMinutes;
  final Value<String?> catatan;
  final Value<int> rowid;
  const ActivityCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.recurrenceId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.judul = const Value.absent(),
    this.activityCategoryId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.reminderOffsetsMinutes = const Value.absent(),
    this.catatan = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    required String userId,
    this.recurrenceId = const Value.absent(),
    required String occurrenceDate,
    required String judul,
    required String activityCategoryId,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isAllDay = const Value.absent(),
    required ActivityStatus status,
    required ActivitySource source,
    this.sourceId = const Value.absent(),
    this.reminderOffsetsMinutes = const Value.absent(),
    this.catatan = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        userId = Value(userId),
        occurrenceDate = Value(occurrenceDate),
        judul = Value(judul),
        activityCategoryId = Value(activityCategoryId),
        status = Value(status),
        source = Value(source);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverRevision,
    Expression<String>? originDeviceId,
    Expression<String>? userId,
    Expression<String>? recurrenceId,
    Expression<String>? occurrenceDate,
    Expression<String>? judul,
    Expression<String>? activityCategoryId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<bool>? isAllDay,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? reminderOffsetsMinutes,
    Expression<String>? catatan,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (userId != null) 'user_id': userId,
      if (recurrenceId != null) 'recurrence_id': recurrenceId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (judul != null) 'judul': judul,
      if (activityCategoryId != null)
        'activity_category_id': activityCategoryId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (reminderOffsetsMinutes != null)
        'reminder_offsets_minutes': reminderOffsetsMinutes,
      if (catatan != null) 'catatan': catatan,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt,
      Value<int?>? serverRevision,
      Value<String?>? originDeviceId,
      Value<String>? userId,
      Value<String?>? recurrenceId,
      Value<String>? occurrenceDate,
      Value<String>? judul,
      Value<String>? activityCategoryId,
      Value<DateTime?>? startTime,
      Value<DateTime?>? endTime,
      Value<bool>? isAllDay,
      Value<ActivityStatus>? status,
      Value<ActivitySource>? source,
      Value<String?>? sourceId,
      Value<List<int>>? reminderOffsetsMinutes,
      Value<String?>? catatan,
      Value<int>? rowid}) {
    return ActivityCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      serverRevision: serverRevision ?? this.serverRevision,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      userId: userId ?? this.userId,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      judul: judul ?? this.judul,
      activityCategoryId: activityCategoryId ?? this.activityCategoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      status: status ?? this.status,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      reminderOffsetsMinutes:
          reminderOffsetsMinutes ?? this.reminderOffsetsMinutes,
      catatan: catatan ?? this.catatan,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (recurrenceId.present) {
      map['recurrence_id'] = Variable<String>(recurrenceId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (judul.present) {
      map['judul'] = Variable<String>(judul.value);
    }
    if (activityCategoryId.present) {
      map['activity_category_id'] = Variable<String>(activityCategoryId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (status.present) {
      map['status'] =
          Variable<String>($ActivityTable.$converterstatus.toSql(status.value));
    }
    if (source.present) {
      map['source'] =
          Variable<String>($ActivityTable.$convertersource.toSql(source.value));
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (reminderOffsetsMinutes.present) {
      map['reminder_offsets_minutes'] = Variable<String>($ActivityTable
          .$converterreminderOffsetsMinutes
          .toSql(reminderOffsetsMinutes.value));
    }
    if (catatan.present) {
      map['catatan'] = Variable<String>(catatan.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('userId: $userId, ')
          ..write('recurrenceId: $recurrenceId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('judul: $judul, ')
          ..write('activityCategoryId: $activityCategoryId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('reminderOffsetsMinutes: $reminderOffsetsMinutes, ')
          ..write('catatan: $catatan, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $DeviceSettingsTable deviceSettings = $DeviceSettingsTable(this);
  late final $MataKuliahTable mataKuliah = $MataKuliahTable(this);
  late final $CourseNoteTable courseNote = $CourseNoteTable(this);
  late final $TugasTable tugas = $TugasTable(this);
  late final $TugasChecklistTable tugasChecklist = $TugasChecklistTable(this);
  late final $ActivityCategoryTable activityCategory =
      $ActivityCategoryTable(this);
  late final $ActivityRecurrenceTable activityRecurrence =
      $ActivityRecurrenceTable(this);
  late final $ActivityTable activity = $ActivityTable(this);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final MataKuliahDao mataKuliahDao = MataKuliahDao(this as AppDatabase);
  late final TugasDao tugasDao = TugasDao(this as AppDatabase);
  late final ActivityDao activityDao = ActivityDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        userSettings,
        deviceSettings,
        mataKuliah,
        courseNote,
        tugas,
        tugasChecklist,
        activityCategory,
        activityRecurrence,
        activity
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  required String nama,
  Value<String?> email,
  required String apiKeyHash,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String> nama,
  Value<String?> email,
  Value<String> apiKeyHash,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, UserRow> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserSettingsTable, List<UserSettingsRow>>
      _userSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userSettings,
          aliasName: $_aliasNameGenerator(db.users.id, db.userSettings.userId));

  $$UserSettingsTableProcessedTableManager get userSettingsRefs {
    final manager = $$UserSettingsTableTableManager($_db, $_db.userSettings)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MataKuliahTable, List<MataKuliahRow>>
      _mataKuliahRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.mataKuliah,
          aliasName: $_aliasNameGenerator(db.users.id, db.mataKuliah.userId));

  $$MataKuliahTableProcessedTableManager get mataKuliahRefs {
    final manager = $$MataKuliahTableTableManager($_db, $_db.mataKuliah)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mataKuliahRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TugasTable, List<TugasRow>> _tugasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tugas,
          aliasName: $_aliasNameGenerator(db.users.id, db.tugas.userId));

  $$TugasTableProcessedTableManager get tugasRefs {
    final manager = $$TugasTableTableManager($_db, $_db.tugas)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tugasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActivityCategoryTable, List<ActivityCategoryRow>>
      _activityCategoryRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.activityCategory,
              aliasName: $_aliasNameGenerator(
                  db.users.id, db.activityCategory.userId));

  $$ActivityCategoryTableProcessedTableManager get activityCategoryRefs {
    final manager =
        $$ActivityCategoryTableTableManager($_db, $_db.activityCategory)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_activityCategoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActivityRecurrenceTable,
      List<ActivityRecurrenceRow>> _activityRecurrenceRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.activityRecurrence,
          aliasName:
              $_aliasNameGenerator(db.users.id, db.activityRecurrence.userId));

  $$ActivityRecurrenceTableProcessedTableManager get activityRecurrenceRefs {
    final manager =
        $$ActivityRecurrenceTableTableManager($_db, $_db.activityRecurrence)
            .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_activityRecurrenceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActivityTable, List<ActivityRow>>
      _activityRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.activity,
              aliasName: $_aliasNameGenerator(db.users.id, db.activity.userId));

  $$ActivityTableProcessedTableManager get activityRefs {
    final manager = $$ActivityTableTableManager($_db, $_db.activity)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apiKeyHash => $composableBuilder(
      column: $table.apiKeyHash, builder: (column) => ColumnFilters(column));

  Expression<bool> userSettingsRefs(
      Expression<bool> Function($$UserSettingsTableFilterComposer f) f) {
    final $$UserSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userSettings,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserSettingsTableFilterComposer(
              $db: $db,
              $table: $db.userSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mataKuliahRefs(
      Expression<bool> Function($$MataKuliahTableFilterComposer f) f) {
    final $$MataKuliahTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableFilterComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tugasRefs(
      Expression<bool> Function($$TugasTableFilterComposer f) f) {
    final $$TugasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableFilterComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activityCategoryRefs(
      Expression<bool> Function($$ActivityCategoryTableFilterComposer f) f) {
    final $$ActivityCategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableFilterComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activityRecurrenceRefs(
      Expression<bool> Function($$ActivityRecurrenceTableFilterComposer f) f) {
    final $$ActivityRecurrenceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityRecurrence,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityRecurrenceTableFilterComposer(
              $db: $db,
              $table: $db.activityRecurrence,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activityRefs(
      Expression<bool> Function($$ActivityTableFilterComposer f) f) {
    final $$ActivityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableFilterComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apiKeyHash => $composableBuilder(
      column: $table.apiKeyHash, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get apiKeyHash => $composableBuilder(
      column: $table.apiKeyHash, builder: (column) => column);

  Expression<T> userSettingsRefs<T extends Object>(
      Expression<T> Function($$UserSettingsTableAnnotationComposer a) f) {
    final $$UserSettingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userSettings,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserSettingsTableAnnotationComposer(
              $db: $db,
              $table: $db.userSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mataKuliahRefs<T extends Object>(
      Expression<T> Function($$MataKuliahTableAnnotationComposer a) f) {
    final $$MataKuliahTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableAnnotationComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tugasRefs<T extends Object>(
      Expression<T> Function($$TugasTableAnnotationComposer a) f) {
    final $$TugasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableAnnotationComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> activityCategoryRefs<T extends Object>(
      Expression<T> Function($$ActivityCategoryTableAnnotationComposer a) f) {
    final $$ActivityCategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> activityRecurrenceRefs<T extends Object>(
      Expression<T> Function($$ActivityRecurrenceTableAnnotationComposer a) f) {
    final $$ActivityRecurrenceTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.activityRecurrence,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ActivityRecurrenceTableAnnotationComposer(
                  $db: $db,
                  $table: $db.activityRecurrence,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> activityRefs<T extends Object>(
      Expression<T> Function($$ActivityTableAnnotationComposer a) f) {
    final $$ActivityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableAnnotationComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function(
        {bool userSettingsRefs,
        bool mataKuliahRefs,
        bool tugasRefs,
        bool activityCategoryRefs,
        bool activityRecurrenceRefs,
        bool activityRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String> nama = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> apiKeyHash = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            nama: nama,
            email: email,
            apiKeyHash: apiKeyHash,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            required String nama,
            Value<String?> email = const Value.absent(),
            required String apiKeyHash,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            nama: nama,
            email: email,
            apiKeyHash: apiKeyHash,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {userSettingsRefs = false,
              mataKuliahRefs = false,
              tugasRefs = false,
              activityCategoryRefs = false,
              activityRecurrenceRefs = false,
              activityRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userSettingsRefs) db.userSettings,
                if (mataKuliahRefs) db.mataKuliah,
                if (tugasRefs) db.tugas,
                if (activityCategoryRefs) db.activityCategory,
                if (activityRecurrenceRefs) db.activityRecurrence,
                if (activityRefs) db.activity
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userSettingsRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable,
                            UserSettingsRow>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._userSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .userSettingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (mataKuliahRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable,
                            MataKuliahRow>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._mataKuliahRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .mataKuliahRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (tugasRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable, TugasRow>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._tugasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).tugasRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (activityCategoryRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable,
                            ActivityCategoryRow>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._activityCategoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .activityCategoryRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (activityRecurrenceRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable,
                            ActivityRecurrenceRow>(
                        currentTable: table,
                        referencedTable: $$UsersTableReferences
                            ._activityRecurrenceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .activityRecurrenceRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (activityRefs)
                    await $_getPrefetchedData<UserRow, $UsersTable,
                            ActivityRow>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._activityRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).activityRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserRow,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserRow, $$UsersTableReferences),
    UserRow,
    PrefetchHooks Function(
        {bool userSettingsRefs,
        bool mataKuliahRefs,
        bool tugasRefs,
        bool activityCategoryRefs,
        bool activityRecurrenceRefs,
        bool activityRefs})>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  Value<Language> language,
  Value<String> timezone,
  Value<int> pomodoroFocusMinutes,
  Value<int> pomodoroShortBreakMinutes,
  Value<int> pomodoroLongBreakMinutes,
  Value<int> pomodoroLongBreakInterval,
  Value<AlarmMode> alarmMode,
  Value<bool> notificationsEnabled,
  Value<String> weeklyReviewTime,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<Language> language,
  Value<String> timezone,
  Value<int> pomodoroFocusMinutes,
  Value<int> pomodoroShortBreakMinutes,
  Value<int> pomodoroLongBreakMinutes,
  Value<int> pomodoroLongBreakInterval,
  Value<AlarmMode> alarmMode,
  Value<bool> notificationsEnabled,
  Value<String> weeklyReviewTime,
  Value<int> rowid,
});

final class $$UserSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsRow> {
  $$UserSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.userSettings.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Language, Language, String> get language =>
      $composableBuilder(
          column: $table.language,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pomodoroFocusMinutes => $composableBuilder(
      column: $table.pomodoroFocusMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pomodoroShortBreakMinutes => $composableBuilder(
      column: $table.pomodoroShortBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pomodoroLongBreakMinutes => $composableBuilder(
      column: $table.pomodoroLongBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pomodoroLongBreakInterval => $composableBuilder(
      column: $table.pomodoroLongBreakInterval,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AlarmMode, AlarmMode, String> get alarmMode =>
      $composableBuilder(
          column: $table.alarmMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weeklyReviewTime => $composableBuilder(
      column: $table.weeklyReviewTime,
      builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pomodoroFocusMinutes => $composableBuilder(
      column: $table.pomodoroFocusMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pomodoroShortBreakMinutes => $composableBuilder(
      column: $table.pomodoroShortBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pomodoroLongBreakMinutes => $composableBuilder(
      column: $table.pomodoroLongBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pomodoroLongBreakInterval => $composableBuilder(
      column: $table.pomodoroLongBreakInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alarmMode => $composableBuilder(
      column: $table.alarmMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weeklyReviewTime => $composableBuilder(
      column: $table.weeklyReviewTime,
      builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Language, String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get pomodoroFocusMinutes => $composableBuilder(
      column: $table.pomodoroFocusMinutes, builder: (column) => column);

  GeneratedColumn<int> get pomodoroShortBreakMinutes => $composableBuilder(
      column: $table.pomodoroShortBreakMinutes, builder: (column) => column);

  GeneratedColumn<int> get pomodoroLongBreakMinutes => $composableBuilder(
      column: $table.pomodoroLongBreakMinutes, builder: (column) => column);

  GeneratedColumn<int> get pomodoroLongBreakInterval => $composableBuilder(
      column: $table.pomodoroLongBreakInterval, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlarmMode, String> get alarmMode =>
      $composableBuilder(column: $table.alarmMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<String> get weeklyReviewTime => $composableBuilder(
      column: $table.weeklyReviewTime, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (UserSettingsRow, $$UserSettingsTableReferences),
    UserSettingsRow,
    PrefetchHooks Function({bool userId})> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<Language> language = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> pomodoroFocusMinutes = const Value.absent(),
            Value<int> pomodoroShortBreakMinutes = const Value.absent(),
            Value<int> pomodoroLongBreakMinutes = const Value.absent(),
            Value<int> pomodoroLongBreakInterval = const Value.absent(),
            Value<AlarmMode> alarmMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> weeklyReviewTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            language: language,
            timezone: timezone,
            pomodoroFocusMinutes: pomodoroFocusMinutes,
            pomodoroShortBreakMinutes: pomodoroShortBreakMinutes,
            pomodoroLongBreakMinutes: pomodoroLongBreakMinutes,
            pomodoroLongBreakInterval: pomodoroLongBreakInterval,
            alarmMode: alarmMode,
            notificationsEnabled: notificationsEnabled,
            weeklyReviewTime: weeklyReviewTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            Value<Language> language = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> pomodoroFocusMinutes = const Value.absent(),
            Value<int> pomodoroShortBreakMinutes = const Value.absent(),
            Value<int> pomodoroLongBreakMinutes = const Value.absent(),
            Value<int> pomodoroLongBreakInterval = const Value.absent(),
            Value<AlarmMode> alarmMode = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<String> weeklyReviewTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            language: language,
            timezone: timezone,
            pomodoroFocusMinutes: pomodoroFocusMinutes,
            pomodoroShortBreakMinutes: pomodoroShortBreakMinutes,
            pomodoroLongBreakMinutes: pomodoroLongBreakMinutes,
            pomodoroLongBreakInterval: pomodoroLongBreakInterval,
            alarmMode: alarmMode,
            notificationsEnabled: notificationsEnabled,
            weeklyReviewTime: weeklyReviewTime,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserSettingsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserSettingsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (UserSettingsRow, $$UserSettingsTableReferences),
    UserSettingsRow,
    PrefetchHooks Function({bool userId})>;
typedef $$DeviceSettingsTableCreateCompanionBuilder = DeviceSettingsCompanion
    Function({
  required String deviceId,
  Value<NotificationPermission> notificationPermission,
  Value<int> alarmVolumePercent,
  Value<ThemePreference> theme,
  Value<int?> activeTimerNotificationId,
  Value<String?> lastPullCursor,
  Value<String?> syncGeneration,
  Value<int?> syncEpoch,
  Value<LastSyncStatus> lastSyncStatus,
  Value<DateTime?> lastSyncAt,
  Value<DateTime?> onboardingCompletedAt,
  Value<int> rowid,
});
typedef $$DeviceSettingsTableUpdateCompanionBuilder = DeviceSettingsCompanion
    Function({
  Value<String> deviceId,
  Value<NotificationPermission> notificationPermission,
  Value<int> alarmVolumePercent,
  Value<ThemePreference> theme,
  Value<int?> activeTimerNotificationId,
  Value<String?> lastPullCursor,
  Value<String?> syncGeneration,
  Value<int?> syncEpoch,
  Value<LastSyncStatus> lastSyncStatus,
  Value<DateTime?> lastSyncAt,
  Value<DateTime?> onboardingCompletedAt,
  Value<int> rowid,
});

class $$DeviceSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<NotificationPermission, NotificationPermission,
          String>
      get notificationPermission => $composableBuilder(
          column: $table.notificationPermission,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get alarmVolumePercent => $composableBuilder(
      column: $table.alarmVolumePercent,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ThemePreference, ThemePreference, String>
      get theme => $composableBuilder(
          column: $table.theme,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get activeTimerNotificationId => $composableBuilder(
      column: $table.activeTimerNotificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastPullCursor => $composableBuilder(
      column: $table.lastPullCursor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncGeneration => $composableBuilder(
      column: $table.syncGeneration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncEpoch => $composableBuilder(
      column: $table.syncEpoch, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LastSyncStatus, LastSyncStatus, String>
      get lastSyncStatus => $composableBuilder(
          column: $table.lastSyncStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnFilters(column));
}

class $$DeviceSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationPermission => $composableBuilder(
      column: $table.notificationPermission,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alarmVolumePercent => $composableBuilder(
      column: $table.alarmVolumePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme => $composableBuilder(
      column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get activeTimerNotificationId => $composableBuilder(
      column: $table.activeTimerNotificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastPullCursor => $composableBuilder(
      column: $table.lastPullCursor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncGeneration => $composableBuilder(
      column: $table.syncGeneration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncEpoch => $composableBuilder(
      column: $table.syncEpoch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastSyncStatus => $composableBuilder(
      column: $table.lastSyncStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$DeviceSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationPermission, String>
      get notificationPermission => $composableBuilder(
          column: $table.notificationPermission, builder: (column) => column);

  GeneratedColumn<int> get alarmVolumePercent => $composableBuilder(
      column: $table.alarmVolumePercent, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThemePreference, String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<int> get activeTimerNotificationId => $composableBuilder(
      column: $table.activeTimerNotificationId, builder: (column) => column);

  GeneratedColumn<String> get lastPullCursor => $composableBuilder(
      column: $table.lastPullCursor, builder: (column) => column);

  GeneratedColumn<String> get syncGeneration => $composableBuilder(
      column: $table.syncGeneration, builder: (column) => column);

  GeneratedColumn<int> get syncEpoch =>
      $composableBuilder(column: $table.syncEpoch, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LastSyncStatus, String> get lastSyncStatus =>
      $composableBuilder(
          column: $table.lastSyncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt, builder: (column) => column);
}

class $$DeviceSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceSettingsTable,
    DeviceSettingsRow,
    $$DeviceSettingsTableFilterComposer,
    $$DeviceSettingsTableOrderingComposer,
    $$DeviceSettingsTableAnnotationComposer,
    $$DeviceSettingsTableCreateCompanionBuilder,
    $$DeviceSettingsTableUpdateCompanionBuilder,
    (
      DeviceSettingsRow,
      BaseReferences<_$AppDatabase, $DeviceSettingsTable, DeviceSettingsRow>
    ),
    DeviceSettingsRow,
    PrefetchHooks Function()> {
  $$DeviceSettingsTableTableManager(
      _$AppDatabase db, $DeviceSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<NotificationPermission> notificationPermission =
                const Value.absent(),
            Value<int> alarmVolumePercent = const Value.absent(),
            Value<ThemePreference> theme = const Value.absent(),
            Value<int?> activeTimerNotificationId = const Value.absent(),
            Value<String?> lastPullCursor = const Value.absent(),
            Value<String?> syncGeneration = const Value.absent(),
            Value<int?> syncEpoch = const Value.absent(),
            Value<LastSyncStatus> lastSyncStatus = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<DateTime?> onboardingCompletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSettingsCompanion(
            deviceId: deviceId,
            notificationPermission: notificationPermission,
            alarmVolumePercent: alarmVolumePercent,
            theme: theme,
            activeTimerNotificationId: activeTimerNotificationId,
            lastPullCursor: lastPullCursor,
            syncGeneration: syncGeneration,
            syncEpoch: syncEpoch,
            lastSyncStatus: lastSyncStatus,
            lastSyncAt: lastSyncAt,
            onboardingCompletedAt: onboardingCompletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            Value<NotificationPermission> notificationPermission =
                const Value.absent(),
            Value<int> alarmVolumePercent = const Value.absent(),
            Value<ThemePreference> theme = const Value.absent(),
            Value<int?> activeTimerNotificationId = const Value.absent(),
            Value<String?> lastPullCursor = const Value.absent(),
            Value<String?> syncGeneration = const Value.absent(),
            Value<int?> syncEpoch = const Value.absent(),
            Value<LastSyncStatus> lastSyncStatus = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<DateTime?> onboardingCompletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSettingsCompanion.insert(
            deviceId: deviceId,
            notificationPermission: notificationPermission,
            alarmVolumePercent: alarmVolumePercent,
            theme: theme,
            activeTimerNotificationId: activeTimerNotificationId,
            lastPullCursor: lastPullCursor,
            syncGeneration: syncGeneration,
            syncEpoch: syncEpoch,
            lastSyncStatus: lastSyncStatus,
            lastSyncAt: lastSyncAt,
            onboardingCompletedAt: onboardingCompletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeviceSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceSettingsTable,
    DeviceSettingsRow,
    $$DeviceSettingsTableFilterComposer,
    $$DeviceSettingsTableOrderingComposer,
    $$DeviceSettingsTableAnnotationComposer,
    $$DeviceSettingsTableCreateCompanionBuilder,
    $$DeviceSettingsTableUpdateCompanionBuilder,
    (
      DeviceSettingsRow,
      BaseReferences<_$AppDatabase, $DeviceSettingsTable, DeviceSettingsRow>
    ),
    DeviceSettingsRow,
    PrefetchHooks Function()>;
typedef $$MataKuliahTableCreateCompanionBuilder = MataKuliahCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  required String nama,
  Value<String?> dosen,
  Value<int?> sks,
  Value<String?> semester,
  required String warna,
  Value<int> rowid,
});
typedef $$MataKuliahTableUpdateCompanionBuilder = MataKuliahCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<String> nama,
  Value<String?> dosen,
  Value<int?> sks,
  Value<String?> semester,
  Value<String> warna,
  Value<int> rowid,
});

final class $$MataKuliahTableReferences
    extends BaseReferences<_$AppDatabase, $MataKuliahTable, MataKuliahRow> {
  $$MataKuliahTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.mataKuliah.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CourseNoteTable, List<CourseNoteRow>>
      _courseNoteRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.courseNote,
              aliasName: $_aliasNameGenerator(
                  db.mataKuliah.id, db.courseNote.mataKuliahId));

  $$CourseNoteTableProcessedTableManager get courseNoteRefs {
    final manager = $$CourseNoteTableTableManager($_db, $_db.courseNote).filter(
        (f) => f.mataKuliahId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseNoteRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TugasTable, List<TugasRow>> _tugasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tugas,
          aliasName:
              $_aliasNameGenerator(db.mataKuliah.id, db.tugas.mataKuliahId));

  $$TugasTableProcessedTableManager get tugasRefs {
    final manager = $$TugasTableTableManager($_db, $_db.tugas).filter(
        (f) => f.mataKuliahId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tugasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MataKuliahTableFilterComposer
    extends Composer<_$AppDatabase, $MataKuliahTable> {
  $$MataKuliahTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosen => $composableBuilder(
      column: $table.dosen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sks => $composableBuilder(
      column: $table.sks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warna => $composableBuilder(
      column: $table.warna, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> courseNoteRefs(
      Expression<bool> Function($$CourseNoteTableFilterComposer f) f) {
    final $$CourseNoteTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.courseNote,
        getReferencedColumn: (t) => t.mataKuliahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CourseNoteTableFilterComposer(
              $db: $db,
              $table: $db.courseNote,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tugasRefs(
      Expression<bool> Function($$TugasTableFilterComposer f) f) {
    final $$TugasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.mataKuliahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableFilterComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MataKuliahTableOrderingComposer
    extends Composer<_$AppDatabase, $MataKuliahTable> {
  $$MataKuliahTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosen => $composableBuilder(
      column: $table.dosen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sks => $composableBuilder(
      column: $table.sks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warna => $composableBuilder(
      column: $table.warna, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MataKuliahTableAnnotationComposer
    extends Composer<_$AppDatabase, $MataKuliahTable> {
  $$MataKuliahTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get dosen =>
      $composableBuilder(column: $table.dosen, builder: (column) => column);

  GeneratedColumn<int> get sks =>
      $composableBuilder(column: $table.sks, builder: (column) => column);

  GeneratedColumn<String> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> courseNoteRefs<T extends Object>(
      Expression<T> Function($$CourseNoteTableAnnotationComposer a) f) {
    final $$CourseNoteTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.courseNote,
        getReferencedColumn: (t) => t.mataKuliahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CourseNoteTableAnnotationComposer(
              $db: $db,
              $table: $db.courseNote,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tugasRefs<T extends Object>(
      Expression<T> Function($$TugasTableAnnotationComposer a) f) {
    final $$TugasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.mataKuliahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableAnnotationComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MataKuliahTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MataKuliahTable,
    MataKuliahRow,
    $$MataKuliahTableFilterComposer,
    $$MataKuliahTableOrderingComposer,
    $$MataKuliahTableAnnotationComposer,
    $$MataKuliahTableCreateCompanionBuilder,
    $$MataKuliahTableUpdateCompanionBuilder,
    (MataKuliahRow, $$MataKuliahTableReferences),
    MataKuliahRow,
    PrefetchHooks Function(
        {bool userId, bool courseNoteRefs, bool tugasRefs})> {
  $$MataKuliahTableTableManager(_$AppDatabase db, $MataKuliahTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MataKuliahTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MataKuliahTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MataKuliahTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> nama = const Value.absent(),
            Value<String?> dosen = const Value.absent(),
            Value<int?> sks = const Value.absent(),
            Value<String?> semester = const Value.absent(),
            Value<String> warna = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MataKuliahCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            nama: nama,
            dosen: dosen,
            sks: sks,
            semester: semester,
            warna: warna,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            required String nama,
            Value<String?> dosen = const Value.absent(),
            Value<int?> sks = const Value.absent(),
            Value<String?> semester = const Value.absent(),
            required String warna,
            Value<int> rowid = const Value.absent(),
          }) =>
              MataKuliahCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            nama: nama,
            dosen: dosen,
            sks: sks,
            semester: semester,
            warna: warna,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MataKuliahTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false, courseNoteRefs = false, tugasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (courseNoteRefs) db.courseNote,
                if (tugasRefs) db.tugas
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$MataKuliahTableReferences._userIdTable(db),
                    referencedColumn:
                        $$MataKuliahTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (courseNoteRefs)
                    await $_getPrefetchedData<MataKuliahRow, $MataKuliahTable, CourseNoteRow>(
                        currentTable: table,
                        referencedTable: $$MataKuliahTableReferences
                            ._courseNoteRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MataKuliahTableReferences(db, table, p0)
                                .courseNoteRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mataKuliahId == item.id),
                        typedResults: items),
                  if (tugasRefs)
                    await $_getPrefetchedData<MataKuliahRow, $MataKuliahTable,
                            TugasRow>(
                        currentTable: table,
                        referencedTable:
                            $$MataKuliahTableReferences._tugasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MataKuliahTableReferences(db, table, p0)
                                .tugasRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mataKuliahId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MataKuliahTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MataKuliahTable,
    MataKuliahRow,
    $$MataKuliahTableFilterComposer,
    $$MataKuliahTableOrderingComposer,
    $$MataKuliahTableAnnotationComposer,
    $$MataKuliahTableCreateCompanionBuilder,
    $$MataKuliahTableUpdateCompanionBuilder,
    (MataKuliahRow, $$MataKuliahTableReferences),
    MataKuliahRow,
    PrefetchHooks Function({bool userId, bool courseNoteRefs, bool tugasRefs})>;
typedef $$CourseNoteTableCreateCompanionBuilder = CourseNoteCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String mataKuliahId,
  required String tanggal,
  required String isi,
  Value<int> rowid,
});
typedef $$CourseNoteTableUpdateCompanionBuilder = CourseNoteCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> mataKuliahId,
  Value<String> tanggal,
  Value<String> isi,
  Value<int> rowid,
});

final class $$CourseNoteTableReferences
    extends BaseReferences<_$AppDatabase, $CourseNoteTable, CourseNoteRow> {
  $$CourseNoteTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MataKuliahTable _mataKuliahIdTable(_$AppDatabase db) =>
      db.mataKuliah.createAlias(
          $_aliasNameGenerator(db.courseNote.mataKuliahId, db.mataKuliah.id));

  $$MataKuliahTableProcessedTableManager get mataKuliahId {
    final $_column = $_itemColumn<String>('mata_kuliah_id')!;

    final manager = $$MataKuliahTableTableManager($_db, $_db.mataKuliah)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mataKuliahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CourseNoteTableFilterComposer
    extends Composer<_$AppDatabase, $CourseNoteTable> {
  $$CourseNoteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isi => $composableBuilder(
      column: $table.isi, builder: (column) => ColumnFilters(column));

  $$MataKuliahTableFilterComposer get mataKuliahId {
    final $$MataKuliahTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableFilterComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CourseNoteTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseNoteTable> {
  $$CourseNoteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isi => $composableBuilder(
      column: $table.isi, builder: (column) => ColumnOrderings(column));

  $$MataKuliahTableOrderingComposer get mataKuliahId {
    final $$MataKuliahTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableOrderingComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CourseNoteTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseNoteTable> {
  $$CourseNoteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  GeneratedColumn<String> get isi =>
      $composableBuilder(column: $table.isi, builder: (column) => column);

  $$MataKuliahTableAnnotationComposer get mataKuliahId {
    final $$MataKuliahTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableAnnotationComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CourseNoteTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CourseNoteTable,
    CourseNoteRow,
    $$CourseNoteTableFilterComposer,
    $$CourseNoteTableOrderingComposer,
    $$CourseNoteTableAnnotationComposer,
    $$CourseNoteTableCreateCompanionBuilder,
    $$CourseNoteTableUpdateCompanionBuilder,
    (CourseNoteRow, $$CourseNoteTableReferences),
    CourseNoteRow,
    PrefetchHooks Function({bool mataKuliahId})> {
  $$CourseNoteTableTableManager(_$AppDatabase db, $CourseNoteTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseNoteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseNoteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseNoteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> mataKuliahId = const Value.absent(),
            Value<String> tanggal = const Value.absent(),
            Value<String> isi = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CourseNoteCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            mataKuliahId: mataKuliahId,
            tanggal: tanggal,
            isi: isi,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String mataKuliahId,
            required String tanggal,
            required String isi,
            Value<int> rowid = const Value.absent(),
          }) =>
              CourseNoteCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            mataKuliahId: mataKuliahId,
            tanggal: tanggal,
            isi: isi,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CourseNoteTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mataKuliahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (mataKuliahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mataKuliahId,
                    referencedTable:
                        $$CourseNoteTableReferences._mataKuliahIdTable(db),
                    referencedColumn:
                        $$CourseNoteTableReferences._mataKuliahIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CourseNoteTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CourseNoteTable,
    CourseNoteRow,
    $$CourseNoteTableFilterComposer,
    $$CourseNoteTableOrderingComposer,
    $$CourseNoteTableAnnotationComposer,
    $$CourseNoteTableCreateCompanionBuilder,
    $$CourseNoteTableUpdateCompanionBuilder,
    (CourseNoteRow, $$CourseNoteTableReferences),
    CourseNoteRow,
    PrefetchHooks Function({bool mataKuliahId})>;
typedef $$TugasTableCreateCompanionBuilder = TugasCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  Value<String?> mataKuliahId,
  required String judul,
  Value<String?> deskripsi,
  required DateTime deadline,
  required TugasPrioritas prioritas,
  Value<int?> estimasiMenit,
  required TugasStatus status,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  required List<Map<String, Object?>> reminders,
  Value<int> rowid,
});
typedef $$TugasTableUpdateCompanionBuilder = TugasCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<String?> mataKuliahId,
  Value<String> judul,
  Value<String?> deskripsi,
  Value<DateTime> deadline,
  Value<TugasPrioritas> prioritas,
  Value<int?> estimasiMenit,
  Value<TugasStatus> status,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<List<Map<String, Object?>>> reminders,
  Value<int> rowid,
});

final class $$TugasTableReferences
    extends BaseReferences<_$AppDatabase, $TugasTable, TugasRow> {
  $$TugasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias($_aliasNameGenerator(db.tugas.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MataKuliahTable _mataKuliahIdTable(_$AppDatabase db) =>
      db.mataKuliah.createAlias(
          $_aliasNameGenerator(db.tugas.mataKuliahId, db.mataKuliah.id));

  $$MataKuliahTableProcessedTableManager? get mataKuliahId {
    final $_column = $_itemColumn<String>('mata_kuliah_id');
    if ($_column == null) return null;
    final manager = $$MataKuliahTableTableManager($_db, $_db.mataKuliah)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mataKuliahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TugasChecklistTable, List<TugasChecklistRow>>
      _tugasChecklistRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tugasChecklist,
              aliasName:
                  $_aliasNameGenerator(db.tugas.id, db.tugasChecklist.tugasId));

  $$TugasChecklistTableProcessedTableManager get tugasChecklistRefs {
    final manager = $$TugasChecklistTableTableManager($_db, $_db.tugasChecklist)
        .filter((f) => f.tugasId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tugasChecklistRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TugasTableFilterComposer extends Composer<_$AppDatabase, $TugasTable> {
  $$TugasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deskripsi => $composableBuilder(
      column: $table.deskripsi, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TugasPrioritas, TugasPrioritas, String>
      get prioritas => $composableBuilder(
          column: $table.prioritas,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get estimasiMenit => $composableBuilder(
      column: $table.estimasiMenit, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TugasStatus, TugasStatus, String> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<Map<String, Object?>>,
          List<Map<String, Object>>, String>
      get reminders => $composableBuilder(
          column: $table.reminders,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MataKuliahTableFilterComposer get mataKuliahId {
    final $$MataKuliahTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableFilterComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tugasChecklistRefs(
      Expression<bool> Function($$TugasChecklistTableFilterComposer f) f) {
    final $$TugasChecklistTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugasChecklist,
        getReferencedColumn: (t) => t.tugasId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasChecklistTableFilterComposer(
              $db: $db,
              $table: $db.tugasChecklist,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TugasTableOrderingComposer
    extends Composer<_$AppDatabase, $TugasTable> {
  $$TugasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deskripsi => $composableBuilder(
      column: $table.deskripsi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prioritas => $composableBuilder(
      column: $table.prioritas, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimasiMenit => $composableBuilder(
      column: $table.estimasiMenit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminders => $composableBuilder(
      column: $table.reminders, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MataKuliahTableOrderingComposer get mataKuliahId {
    final $$MataKuliahTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableOrderingComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TugasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TugasTable> {
  $$TugasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get judul =>
      $composableBuilder(column: $table.judul, builder: (column) => column);

  GeneratedColumn<String> get deskripsi =>
      $composableBuilder(column: $table.deskripsi, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TugasPrioritas, String> get prioritas =>
      $composableBuilder(column: $table.prioritas, builder: (column) => column);

  GeneratedColumn<int> get estimasiMenit => $composableBuilder(
      column: $table.estimasiMenit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TugasStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Map<String, Object?>>, String>
      get reminders => $composableBuilder(
          column: $table.reminders, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MataKuliahTableAnnotationComposer get mataKuliahId {
    final $$MataKuliahTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mataKuliahId,
        referencedTable: $db.mataKuliah,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MataKuliahTableAnnotationComposer(
              $db: $db,
              $table: $db.mataKuliah,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tugasChecklistRefs<T extends Object>(
      Expression<T> Function($$TugasChecklistTableAnnotationComposer a) f) {
    final $$TugasChecklistTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tugasChecklist,
        getReferencedColumn: (t) => t.tugasId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasChecklistTableAnnotationComposer(
              $db: $db,
              $table: $db.tugasChecklist,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TugasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TugasTable,
    TugasRow,
    $$TugasTableFilterComposer,
    $$TugasTableOrderingComposer,
    $$TugasTableAnnotationComposer,
    $$TugasTableCreateCompanionBuilder,
    $$TugasTableUpdateCompanionBuilder,
    (TugasRow, $$TugasTableReferences),
    TugasRow,
    PrefetchHooks Function(
        {bool userId, bool mataKuliahId, bool tugasChecklistRefs})> {
  $$TugasTableTableManager(_$AppDatabase db, $TugasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TugasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TugasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TugasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> mataKuliahId = const Value.absent(),
            Value<String> judul = const Value.absent(),
            Value<String?> deskripsi = const Value.absent(),
            Value<DateTime> deadline = const Value.absent(),
            Value<TugasPrioritas> prioritas = const Value.absent(),
            Value<int?> estimasiMenit = const Value.absent(),
            Value<TugasStatus> status = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<List<Map<String, Object?>>> reminders = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TugasCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            mataKuliahId: mataKuliahId,
            judul: judul,
            deskripsi: deskripsi,
            deadline: deadline,
            prioritas: prioritas,
            estimasiMenit: estimasiMenit,
            status: status,
            completedAt: completedAt,
            archivedAt: archivedAt,
            reminders: reminders,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            Value<String?> mataKuliahId = const Value.absent(),
            required String judul,
            Value<String?> deskripsi = const Value.absent(),
            required DateTime deadline,
            required TugasPrioritas prioritas,
            Value<int?> estimasiMenit = const Value.absent(),
            required TugasStatus status,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            required List<Map<String, Object?>> reminders,
            Value<int> rowid = const Value.absent(),
          }) =>
              TugasCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            mataKuliahId: mataKuliahId,
            judul: judul,
            deskripsi: deskripsi,
            deadline: deadline,
            prioritas: prioritas,
            estimasiMenit: estimasiMenit,
            status: status,
            completedAt: completedAt,
            archivedAt: archivedAt,
            reminders: reminders,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TugasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              mataKuliahId = false,
              tugasChecklistRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tugasChecklistRefs) db.tugasChecklist
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$TugasTableReferences._userIdTable(db),
                    referencedColumn:
                        $$TugasTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (mataKuliahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mataKuliahId,
                    referencedTable:
                        $$TugasTableReferences._mataKuliahIdTable(db),
                    referencedColumn:
                        $$TugasTableReferences._mataKuliahIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tugasChecklistRefs)
                    await $_getPrefetchedData<TugasRow, $TugasTable,
                            TugasChecklistRow>(
                        currentTable: table,
                        referencedTable:
                            $$TugasTableReferences._tugasChecklistRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TugasTableReferences(db, table, p0)
                                .tugasChecklistRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tugasId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TugasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TugasTable,
    TugasRow,
    $$TugasTableFilterComposer,
    $$TugasTableOrderingComposer,
    $$TugasTableAnnotationComposer,
    $$TugasTableCreateCompanionBuilder,
    $$TugasTableUpdateCompanionBuilder,
    (TugasRow, $$TugasTableReferences),
    TugasRow,
    PrefetchHooks Function(
        {bool userId, bool mataKuliahId, bool tugasChecklistRefs})>;
typedef $$TugasChecklistTableCreateCompanionBuilder = TugasChecklistCompanion
    Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String tugasId,
  required String judul,
  Value<bool> isDone,
  required int urutan,
  Value<int> rowid,
});
typedef $$TugasChecklistTableUpdateCompanionBuilder = TugasChecklistCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> tugasId,
  Value<String> judul,
  Value<bool> isDone,
  Value<int> urutan,
  Value<int> rowid,
});

final class $$TugasChecklistTableReferences extends BaseReferences<
    _$AppDatabase, $TugasChecklistTable, TugasChecklistRow> {
  $$TugasChecklistTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TugasTable _tugasIdTable(_$AppDatabase db) => db.tugas.createAlias(
      $_aliasNameGenerator(db.tugasChecklist.tugasId, db.tugas.id));

  $$TugasTableProcessedTableManager get tugasId {
    final $_column = $_itemColumn<String>('tugas_id')!;

    final manager = $$TugasTableTableManager($_db, $_db.tugas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tugasIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TugasChecklistTableFilterComposer
    extends Composer<_$AppDatabase, $TugasChecklistTable> {
  $$TugasChecklistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get urutan => $composableBuilder(
      column: $table.urutan, builder: (column) => ColumnFilters(column));

  $$TugasTableFilterComposer get tugasId {
    final $$TugasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tugasId,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableFilterComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TugasChecklistTableOrderingComposer
    extends Composer<_$AppDatabase, $TugasChecklistTable> {
  $$TugasChecklistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get urutan => $composableBuilder(
      column: $table.urutan, builder: (column) => ColumnOrderings(column));

  $$TugasTableOrderingComposer get tugasId {
    final $$TugasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tugasId,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableOrderingComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TugasChecklistTableAnnotationComposer
    extends Composer<_$AppDatabase, $TugasChecklistTable> {
  $$TugasChecklistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get judul =>
      $composableBuilder(column: $table.judul, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get urutan =>
      $composableBuilder(column: $table.urutan, builder: (column) => column);

  $$TugasTableAnnotationComposer get tugasId {
    final $$TugasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tugasId,
        referencedTable: $db.tugas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TugasTableAnnotationComposer(
              $db: $db,
              $table: $db.tugas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TugasChecklistTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TugasChecklistTable,
    TugasChecklistRow,
    $$TugasChecklistTableFilterComposer,
    $$TugasChecklistTableOrderingComposer,
    $$TugasChecklistTableAnnotationComposer,
    $$TugasChecklistTableCreateCompanionBuilder,
    $$TugasChecklistTableUpdateCompanionBuilder,
    (TugasChecklistRow, $$TugasChecklistTableReferences),
    TugasChecklistRow,
    PrefetchHooks Function({bool tugasId})> {
  $$TugasChecklistTableTableManager(
      _$AppDatabase db, $TugasChecklistTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TugasChecklistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TugasChecklistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TugasChecklistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> tugasId = const Value.absent(),
            Value<String> judul = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<int> urutan = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TugasChecklistCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            tugasId: tugasId,
            judul: judul,
            isDone: isDone,
            urutan: urutan,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String tugasId,
            required String judul,
            Value<bool> isDone = const Value.absent(),
            required int urutan,
            Value<int> rowid = const Value.absent(),
          }) =>
              TugasChecklistCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            tugasId: tugasId,
            judul: judul,
            isDone: isDone,
            urutan: urutan,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TugasChecklistTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tugasId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (tugasId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tugasId,
                    referencedTable:
                        $$TugasChecklistTableReferences._tugasIdTable(db),
                    referencedColumn:
                        $$TugasChecklistTableReferences._tugasIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TugasChecklistTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TugasChecklistTable,
    TugasChecklistRow,
    $$TugasChecklistTableFilterComposer,
    $$TugasChecklistTableOrderingComposer,
    $$TugasChecklistTableAnnotationComposer,
    $$TugasChecklistTableCreateCompanionBuilder,
    $$TugasChecklistTableUpdateCompanionBuilder,
    (TugasChecklistRow, $$TugasChecklistTableReferences),
    TugasChecklistRow,
    PrefetchHooks Function({bool tugasId})>;
typedef $$ActivityCategoryTableCreateCompanionBuilder
    = ActivityCategoryCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  required String nama,
  required String warna,
  Value<String?> icon,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$ActivityCategoryTableUpdateCompanionBuilder
    = ActivityCategoryCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<String> nama,
  Value<String> warna,
  Value<String?> icon,
  Value<bool> isSystem,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$ActivityCategoryTableReferences extends BaseReferences<
    _$AppDatabase, $ActivityCategoryTable, ActivityCategoryRow> {
  $$ActivityCategoryTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.activityCategory.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ActivityRecurrenceTable,
      List<ActivityRecurrenceRow>> _activityRecurrenceRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.activityRecurrence,
          aliasName: $_aliasNameGenerator(db.activityCategory.id,
              db.activityRecurrence.activityCategoryId));

  $$ActivityRecurrenceTableProcessedTableManager get activityRecurrenceRefs {
    final manager =
        $$ActivityRecurrenceTableTableManager($_db, $_db.activityRecurrence)
            .filter((f) =>
                f.activityCategoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_activityRecurrenceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ActivityTable, List<ActivityRow>>
      _activityRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.activity,
              aliasName: $_aliasNameGenerator(
                  db.activityCategory.id, db.activity.activityCategoryId));

  $$ActivityTableProcessedTableManager get activityRefs {
    final manager = $$ActivityTableTableManager($_db, $_db.activity).filter(
        (f) => f.activityCategoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ActivityCategoryTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityCategoryTable> {
  $$ActivityCategoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warna => $composableBuilder(
      column: $table.warna, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> activityRecurrenceRefs(
      Expression<bool> Function($$ActivityRecurrenceTableFilterComposer f) f) {
    final $$ActivityRecurrenceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activityRecurrence,
        getReferencedColumn: (t) => t.activityCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityRecurrenceTableFilterComposer(
              $db: $db,
              $table: $db.activityRecurrence,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> activityRefs(
      Expression<bool> Function($$ActivityTableFilterComposer f) f) {
    final $$ActivityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.activityCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableFilterComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivityCategoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityCategoryTable> {
  $$ActivityCategoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warna => $composableBuilder(
      column: $table.warna, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSystem => $composableBuilder(
      column: $table.isSystem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityCategoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityCategoryTable> {
  $$ActivityCategoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get warna =>
      $composableBuilder(column: $table.warna, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> activityRecurrenceRefs<T extends Object>(
      Expression<T> Function($$ActivityRecurrenceTableAnnotationComposer a) f) {
    final $$ActivityRecurrenceTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.activityRecurrence,
            getReferencedColumn: (t) => t.activityCategoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ActivityRecurrenceTableAnnotationComposer(
                  $db: $db,
                  $table: $db.activityRecurrence,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> activityRefs<T extends Object>(
      Expression<T> Function($$ActivityTableAnnotationComposer a) f) {
    final $$ActivityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.activityCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableAnnotationComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivityCategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityCategoryTable,
    ActivityCategoryRow,
    $$ActivityCategoryTableFilterComposer,
    $$ActivityCategoryTableOrderingComposer,
    $$ActivityCategoryTableAnnotationComposer,
    $$ActivityCategoryTableCreateCompanionBuilder,
    $$ActivityCategoryTableUpdateCompanionBuilder,
    (ActivityCategoryRow, $$ActivityCategoryTableReferences),
    ActivityCategoryRow,
    PrefetchHooks Function(
        {bool userId, bool activityRecurrenceRefs, bool activityRefs})> {
  $$ActivityCategoryTableTableManager(
      _$AppDatabase db, $ActivityCategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityCategoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityCategoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityCategoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> nama = const Value.absent(),
            Value<String> warna = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityCategoryCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            nama: nama,
            warna: warna,
            icon: icon,
            isSystem: isSystem,
            isArchived: isArchived,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            required String nama,
            required String warna,
            Value<String?> icon = const Value.absent(),
            Value<bool> isSystem = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityCategoryCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            nama: nama,
            warna: warna,
            icon: icon,
            isSystem: isSystem,
            isArchived: isArchived,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActivityCategoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              activityRecurrenceRefs = false,
              activityRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (activityRecurrenceRefs) db.activityRecurrence,
                if (activityRefs) db.activity
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$ActivityCategoryTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ActivityCategoryTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activityRecurrenceRefs)
                    await $_getPrefetchedData<ActivityCategoryRow,
                            $ActivityCategoryTable, ActivityRecurrenceRow>(
                        currentTable: table,
                        referencedTable: $$ActivityCategoryTableReferences
                            ._activityRecurrenceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivityCategoryTableReferences(db, table, p0)
                                .activityRecurrenceRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.activityCategoryId == item.id),
                        typedResults: items),
                  if (activityRefs)
                    await $_getPrefetchedData<ActivityCategoryRow,
                            $ActivityCategoryTable, ActivityRow>(
                        currentTable: table,
                        referencedTable: $$ActivityCategoryTableReferences
                            ._activityRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivityCategoryTableReferences(db, table, p0)
                                .activityRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.activityCategoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ActivityCategoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityCategoryTable,
    ActivityCategoryRow,
    $$ActivityCategoryTableFilterComposer,
    $$ActivityCategoryTableOrderingComposer,
    $$ActivityCategoryTableAnnotationComposer,
    $$ActivityCategoryTableCreateCompanionBuilder,
    $$ActivityCategoryTableUpdateCompanionBuilder,
    (ActivityCategoryRow, $$ActivityCategoryTableReferences),
    ActivityCategoryRow,
    PrefetchHooks Function(
        {bool userId, bool activityRecurrenceRefs, bool activityRefs})>;
typedef $$ActivityRecurrenceTableCreateCompanionBuilder
    = ActivityRecurrenceCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  required String judul,
  required String activityCategoryId,
  Value<String?> startTime,
  Value<String?> endTime,
  Value<bool> isAllDay,
  required List<int> recurringDays,
  required String startsOn,
  Value<String?> endsOn,
  Value<List<int>> reminderOffsetsMinutes,
  Value<String?> catatan,
  Value<String?> materializedThroughDate,
  Value<int> rowid,
});
typedef $$ActivityRecurrenceTableUpdateCompanionBuilder
    = ActivityRecurrenceCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<String> judul,
  Value<String> activityCategoryId,
  Value<String?> startTime,
  Value<String?> endTime,
  Value<bool> isAllDay,
  Value<List<int>> recurringDays,
  Value<String> startsOn,
  Value<String?> endsOn,
  Value<List<int>> reminderOffsetsMinutes,
  Value<String?> catatan,
  Value<String?> materializedThroughDate,
  Value<int> rowid,
});

final class $$ActivityRecurrenceTableReferences extends BaseReferences<
    _$AppDatabase, $ActivityRecurrenceTable, ActivityRecurrenceRow> {
  $$ActivityRecurrenceTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
      $_aliasNameGenerator(db.activityRecurrence.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ActivityCategoryTable _activityCategoryIdTable(_$AppDatabase db) =>
      db.activityCategory.createAlias($_aliasNameGenerator(
          db.activityRecurrence.activityCategoryId, db.activityCategory.id));

  $$ActivityCategoryTableProcessedTableManager get activityCategoryId {
    final $_column = $_itemColumn<String>('activity_category_id')!;

    final manager =
        $$ActivityCategoryTableTableManager($_db, $_db.activityCategory)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ActivityTable, List<ActivityRow>>
      _activityRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.activity,
              aliasName: $_aliasNameGenerator(
                  db.activityRecurrence.id, db.activity.recurrenceId));

  $$ActivityTableProcessedTableManager get activityRefs {
    final manager = $$ActivityTableTableManager($_db, $_db.activity).filter(
        (f) => f.recurrenceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ActivityRecurrenceTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityRecurrenceTable> {
  $$ActivityRecurrenceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
      get recurringDays => $composableBuilder(
          column: $table.recurringDays,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get startsOn => $composableBuilder(
      column: $table.startsOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endsOn => $composableBuilder(
      column: $table.endsOn, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
      get reminderOffsetsMinutes => $composableBuilder(
          column: $table.reminderOffsetsMinutes,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materializedThroughDate => $composableBuilder(
      column: $table.materializedThroughDate,
      builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityCategoryTableFilterComposer get activityCategoryId {
    final $$ActivityCategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableFilterComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> activityRefs(
      Expression<bool> Function($$ActivityTableFilterComposer f) f) {
    final $$ActivityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.recurrenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableFilterComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivityRecurrenceTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityRecurrenceTable> {
  $$ActivityRecurrenceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringDays => $composableBuilder(
      column: $table.recurringDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startsOn => $composableBuilder(
      column: $table.startsOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endsOn => $composableBuilder(
      column: $table.endsOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderOffsetsMinutes => $composableBuilder(
      column: $table.reminderOffsetsMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materializedThroughDate => $composableBuilder(
      column: $table.materializedThroughDate,
      builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityCategoryTableOrderingComposer get activityCategoryId {
    final $$ActivityCategoryTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableOrderingComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityRecurrenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityRecurrenceTable> {
  $$ActivityRecurrenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get judul =>
      $composableBuilder(column: $table.judul, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get recurringDays =>
      $composableBuilder(
          column: $table.recurringDays, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String>
      get reminderOffsetsMinutes => $composableBuilder(
          column: $table.reminderOffsetsMinutes, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  GeneratedColumn<String> get materializedThroughDate => $composableBuilder(
      column: $table.materializedThroughDate, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityCategoryTableAnnotationComposer get activityCategoryId {
    final $$ActivityCategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> activityRefs<T extends Object>(
      Expression<T> Function($$ActivityTableAnnotationComposer a) f) {
    final $$ActivityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.activity,
        getReferencedColumn: (t) => t.recurrenceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityTableAnnotationComposer(
              $db: $db,
              $table: $db.activity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ActivityRecurrenceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityRecurrenceTable,
    ActivityRecurrenceRow,
    $$ActivityRecurrenceTableFilterComposer,
    $$ActivityRecurrenceTableOrderingComposer,
    $$ActivityRecurrenceTableAnnotationComposer,
    $$ActivityRecurrenceTableCreateCompanionBuilder,
    $$ActivityRecurrenceTableUpdateCompanionBuilder,
    (ActivityRecurrenceRow, $$ActivityRecurrenceTableReferences),
    ActivityRecurrenceRow,
    PrefetchHooks Function(
        {bool userId, bool activityCategoryId, bool activityRefs})> {
  $$ActivityRecurrenceTableTableManager(
      _$AppDatabase db, $ActivityRecurrenceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityRecurrenceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityRecurrenceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityRecurrenceTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> judul = const Value.absent(),
            Value<String> activityCategoryId = const Value.absent(),
            Value<String?> startTime = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            Value<List<int>> recurringDays = const Value.absent(),
            Value<String> startsOn = const Value.absent(),
            Value<String?> endsOn = const Value.absent(),
            Value<List<int>> reminderOffsetsMinutes = const Value.absent(),
            Value<String?> catatan = const Value.absent(),
            Value<String?> materializedThroughDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityRecurrenceCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            judul: judul,
            activityCategoryId: activityCategoryId,
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay,
            recurringDays: recurringDays,
            startsOn: startsOn,
            endsOn: endsOn,
            reminderOffsetsMinutes: reminderOffsetsMinutes,
            catatan: catatan,
            materializedThroughDate: materializedThroughDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            required String judul,
            required String activityCategoryId,
            Value<String?> startTime = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            required List<int> recurringDays,
            required String startsOn,
            Value<String?> endsOn = const Value.absent(),
            Value<List<int>> reminderOffsetsMinutes = const Value.absent(),
            Value<String?> catatan = const Value.absent(),
            Value<String?> materializedThroughDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityRecurrenceCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            judul: judul,
            activityCategoryId: activityCategoryId,
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay,
            recurringDays: recurringDays,
            startsOn: startsOn,
            endsOn: endsOn,
            reminderOffsetsMinutes: reminderOffsetsMinutes,
            catatan: catatan,
            materializedThroughDate: materializedThroughDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ActivityRecurrenceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              activityCategoryId = false,
              activityRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activityRefs) db.activity],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$ActivityRecurrenceTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ActivityRecurrenceTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (activityCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.activityCategoryId,
                    referencedTable: $$ActivityRecurrenceTableReferences
                        ._activityCategoryIdTable(db),
                    referencedColumn: $$ActivityRecurrenceTableReferences
                        ._activityCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activityRefs)
                    await $_getPrefetchedData<ActivityRecurrenceRow,
                            $ActivityRecurrenceTable, ActivityRow>(
                        currentTable: table,
                        referencedTable: $$ActivityRecurrenceTableReferences
                            ._activityRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ActivityRecurrenceTableReferences(db, table, p0)
                                .activityRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.recurrenceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ActivityRecurrenceTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityRecurrenceTable,
    ActivityRecurrenceRow,
    $$ActivityRecurrenceTableFilterComposer,
    $$ActivityRecurrenceTableOrderingComposer,
    $$ActivityRecurrenceTableAnnotationComposer,
    $$ActivityRecurrenceTableCreateCompanionBuilder,
    $$ActivityRecurrenceTableUpdateCompanionBuilder,
    (ActivityRecurrenceRow, $$ActivityRecurrenceTableReferences),
    ActivityRecurrenceRow,
    PrefetchHooks Function(
        {bool userId, bool activityCategoryId, bool activityRefs})>;
typedef $$ActivityTableCreateCompanionBuilder = ActivityCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  required String userId,
  Value<String?> recurrenceId,
  required String occurrenceDate,
  required String judul,
  required String activityCategoryId,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<bool> isAllDay,
  required ActivityStatus status,
  required ActivitySource source,
  Value<String?> sourceId,
  Value<List<int>> reminderOffsetsMinutes,
  Value<String?> catatan,
  Value<int> rowid,
});
typedef $$ActivityTableUpdateCompanionBuilder = ActivityCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
  Value<int?> serverRevision,
  Value<String?> originDeviceId,
  Value<String> userId,
  Value<String?> recurrenceId,
  Value<String> occurrenceDate,
  Value<String> judul,
  Value<String> activityCategoryId,
  Value<DateTime?> startTime,
  Value<DateTime?> endTime,
  Value<bool> isAllDay,
  Value<ActivityStatus> status,
  Value<ActivitySource> source,
  Value<String?> sourceId,
  Value<List<int>> reminderOffsetsMinutes,
  Value<String?> catatan,
  Value<int> rowid,
});

final class $$ActivityTableReferences
    extends BaseReferences<_$AppDatabase, $ActivityTable, ActivityRow> {
  $$ActivityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.activity.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ActivityRecurrenceTable _recurrenceIdTable(_$AppDatabase db) =>
      db.activityRecurrence.createAlias($_aliasNameGenerator(
          db.activity.recurrenceId, db.activityRecurrence.id));

  $$ActivityRecurrenceTableProcessedTableManager? get recurrenceId {
    final $_column = $_itemColumn<String>('recurrence_id');
    if ($_column == null) return null;
    final manager =
        $$ActivityRecurrenceTableTableManager($_db, $_db.activityRecurrence)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ActivityCategoryTable _activityCategoryIdTable(_$AppDatabase db) =>
      db.activityCategory.createAlias($_aliasNameGenerator(
          db.activity.activityCategoryId, db.activityCategory.id));

  $$ActivityCategoryTableProcessedTableManager get activityCategoryId {
    final $_column = $_itemColumn<String>('activity_category_id')!;

    final manager =
        $$ActivityCategoryTableTableManager($_db, $_db.activityCategory)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ActivityTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityTable> {
  $$ActivityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivityStatus, ActivityStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ActivitySource, ActivitySource, String>
      get source => $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
      get reminderOffsetsMinutes => $composableBuilder(
          column: $table.reminderOffsetsMinutes,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityRecurrenceTableFilterComposer get recurrenceId {
    final $$ActivityRecurrenceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurrenceId,
        referencedTable: $db.activityRecurrence,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityRecurrenceTableFilterComposer(
              $db: $db,
              $table: $db.activityRecurrence,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityCategoryTableFilterComposer get activityCategoryId {
    final $$ActivityCategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableFilterComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityTable> {
  $$ActivityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get judul => $composableBuilder(
      column: $table.judul, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
      column: $table.isAllDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderOffsetsMinutes => $composableBuilder(
      column: $table.reminderOffsetsMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catatan => $composableBuilder(
      column: $table.catatan, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityRecurrenceTableOrderingComposer get recurrenceId {
    final $$ActivityRecurrenceTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.recurrenceId,
        referencedTable: $db.activityRecurrence,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityRecurrenceTableOrderingComposer(
              $db: $db,
              $table: $db.activityRecurrence,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityCategoryTableOrderingComposer get activityCategoryId {
    final $$ActivityCategoryTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableOrderingComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityTable> {
  $$ActivityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
      column: $table.serverRevision, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
      column: $table.originDeviceId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate, builder: (column) => column);

  GeneratedColumn<String> get judul =>
      $composableBuilder(column: $table.judul, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivitySource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String>
      get reminderOffsetsMinutes => $composableBuilder(
          column: $table.reminderOffsetsMinutes, builder: (column) => column);

  GeneratedColumn<String> get catatan =>
      $composableBuilder(column: $table.catatan, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ActivityRecurrenceTableAnnotationComposer get recurrenceId {
    final $$ActivityRecurrenceTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.recurrenceId,
            referencedTable: $db.activityRecurrence,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ActivityRecurrenceTableAnnotationComposer(
                  $db: $db,
                  $table: $db.activityRecurrence,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$ActivityCategoryTableAnnotationComposer get activityCategoryId {
    final $$ActivityCategoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.activityCategoryId,
        referencedTable: $db.activityCategory,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ActivityCategoryTableAnnotationComposer(
              $db: $db,
              $table: $db.activityCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ActivityTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityTable,
    ActivityRow,
    $$ActivityTableFilterComposer,
    $$ActivityTableOrderingComposer,
    $$ActivityTableAnnotationComposer,
    $$ActivityTableCreateCompanionBuilder,
    $$ActivityTableUpdateCompanionBuilder,
    (ActivityRow, $$ActivityTableReferences),
    ActivityRow,
    PrefetchHooks Function(
        {bool userId, bool recurrenceId, bool activityCategoryId})> {
  $$ActivityTableTableManager(_$AppDatabase db, $ActivityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> recurrenceId = const Value.absent(),
            Value<String> occurrenceDate = const Value.absent(),
            Value<String> judul = const Value.absent(),
            Value<String> activityCategoryId = const Value.absent(),
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            Value<ActivityStatus> status = const Value.absent(),
            Value<ActivitySource> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<List<int>> reminderOffsetsMinutes = const Value.absent(),
            Value<String?> catatan = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            recurrenceId: recurrenceId,
            occurrenceDate: occurrenceDate,
            judul: judul,
            activityCategoryId: activityCategoryId,
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay,
            status: status,
            source: source,
            sourceId: sourceId,
            reminderOffsetsMinutes: reminderOffsetsMinutes,
            catatan: catatan,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int?> serverRevision = const Value.absent(),
            Value<String?> originDeviceId = const Value.absent(),
            required String userId,
            Value<String?> recurrenceId = const Value.absent(),
            required String occurrenceDate,
            required String judul,
            required String activityCategoryId,
            Value<DateTime?> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> isAllDay = const Value.absent(),
            required ActivityStatus status,
            required ActivitySource source,
            Value<String?> sourceId = const Value.absent(),
            Value<List<int>> reminderOffsetsMinutes = const Value.absent(),
            Value<String?> catatan = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            serverRevision: serverRevision,
            originDeviceId: originDeviceId,
            userId: userId,
            recurrenceId: recurrenceId,
            occurrenceDate: occurrenceDate,
            judul: judul,
            activityCategoryId: activityCategoryId,
            startTime: startTime,
            endTime: endTime,
            isAllDay: isAllDay,
            status: status,
            source: source,
            sourceId: sourceId,
            reminderOffsetsMinutes: reminderOffsetsMinutes,
            catatan: catatan,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ActivityTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {userId = false,
              recurrenceId = false,
              activityCategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable: $$ActivityTableReferences._userIdTable(db),
                    referencedColumn:
                        $$ActivityTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (recurrenceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.recurrenceId,
                    referencedTable:
                        $$ActivityTableReferences._recurrenceIdTable(db),
                    referencedColumn:
                        $$ActivityTableReferences._recurrenceIdTable(db).id,
                  ) as T;
                }
                if (activityCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.activityCategoryId,
                    referencedTable:
                        $$ActivityTableReferences._activityCategoryIdTable(db),
                    referencedColumn: $$ActivityTableReferences
                        ._activityCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ActivityTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityTable,
    ActivityRow,
    $$ActivityTableFilterComposer,
    $$ActivityTableOrderingComposer,
    $$ActivityTableAnnotationComposer,
    $$ActivityTableCreateCompanionBuilder,
    $$ActivityTableUpdateCompanionBuilder,
    (ActivityRow, $$ActivityTableReferences),
    ActivityRow,
    PrefetchHooks Function(
        {bool userId, bool recurrenceId, bool activityCategoryId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$DeviceSettingsTableTableManager get deviceSettings =>
      $$DeviceSettingsTableTableManager(_db, _db.deviceSettings);
  $$MataKuliahTableTableManager get mataKuliah =>
      $$MataKuliahTableTableManager(_db, _db.mataKuliah);
  $$CourseNoteTableTableManager get courseNote =>
      $$CourseNoteTableTableManager(_db, _db.courseNote);
  $$TugasTableTableManager get tugas =>
      $$TugasTableTableManager(_db, _db.tugas);
  $$TugasChecklistTableTableManager get tugasChecklist =>
      $$TugasChecklistTableTableManager(_db, _db.tugasChecklist);
  $$ActivityCategoryTableTableManager get activityCategory =>
      $$ActivityCategoryTableTableManager(_db, _db.activityCategory);
  $$ActivityRecurrenceTableTableManager get activityRecurrence =>
      $$ActivityRecurrenceTableTableManager(_db, _db.activityRecurrence);
  $$ActivityTableTableManager get activity =>
      $$ActivityTableTableManager(_db, _db.activity);
}
