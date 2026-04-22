import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/db_constants.dart';

/// Singleton que gestiona la conexión a SQLite y el schema de tablas.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.dbName);
    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Habilitar foreign keys en SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(_createRoutines);
      await txn.execute(_createDays);
      await txn.execute(_createExercises);
      await txn.execute(_createExerciseLibrary);
      await txn.execute(_createWorkoutSessions);
      await txn.execute(_createSetLogs);
      await txn.execute(_createExerciseSwaps);
      await txn.execute(_createCardioPlans);
      await txn.execute(_createCardioWeeks);
      await txn.execute(_createCardioSessionTemplates);
      await txn.execute(_createCardioSessionLogs);
      await txn.execute(_createReminders);
      await txn.execute(_createNotificationLogs);
      // Índices para las queries más frecuentes
      await txn.execute(_idxSessionDate);
      await txn.execute(_idxSetLogExercise);
      await txn.execute(_idxSetLogSession);
      await txn.execute(_idxCardioLogDate);
    });
  }

  // ── DDL ───────────────────────────────────────────────────────────────────

  static const _createRoutines = '''
    CREATE TABLE ${DbConstants.tableRoutines} (
      ${DbConstants.colId}               INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colRoutineName}      TEXT    NOT NULL,
      ${DbConstants.colRoutineDescription} TEXT  NOT NULL DEFAULT '',
      ${DbConstants.colCreatedAt}        TEXT    NOT NULL,
      ${DbConstants.colRoutineUpdatedAt} TEXT    NOT NULL
    )
  ''';

  static const _createDays = '''
    CREATE TABLE ${DbConstants.tableDays} (
      ${DbConstants.colId}           INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colDayRoutineId} INTEGER NOT NULL,
      ${DbConstants.colDayName}      TEXT    NOT NULL,
      ${DbConstants.colDayOrder}     INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (${DbConstants.colDayRoutineId})
        REFERENCES ${DbConstants.tableRoutines}(${DbConstants.colId})
        ON DELETE CASCADE
    )
  ''';

  static const _createExercises = '''
    CREATE TABLE ${DbConstants.tableExercises} (
      ${DbConstants.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colExDayId}     INTEGER NOT NULL,
      ${DbConstants.colExName}      TEXT    NOT NULL,
      ${DbConstants.colExMuscle}    TEXT    NOT NULL,
      ${DbConstants.colExSets}      INTEGER NOT NULL DEFAULT 3,
      ${DbConstants.colExRepMin}    INTEGER NOT NULL DEFAULT 8,
      ${DbConstants.colExRepMax}    INTEGER NOT NULL DEFAULT 12,
      ${DbConstants.colExRir}       INTEGER NOT NULL DEFAULT 2,
      ${DbConstants.colExNotes}     TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colExOrder}     INTEGER NOT NULL DEFAULT 0,
      ${DbConstants.colExRest}      INTEGER NOT NULL DEFAULT 90,
      ${DbConstants.colExCompound}  INTEGER NOT NULL DEFAULT 0,
      ${DbConstants.colExLibraryId} INTEGER,
      FOREIGN KEY (${DbConstants.colExDayId})
        REFERENCES ${DbConstants.tableDays}(${DbConstants.colId})
        ON DELETE CASCADE
    )
  ''';

  static const _createExerciseLibrary = '''
    CREATE TABLE ${DbConstants.tableExerciseLibrary} (
      ${DbConstants.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colLibName}     TEXT    NOT NULL,
      ${DbConstants.colLibMuscle}   TEXT    NOT NULL,
      ${DbConstants.colLibCompound} INTEGER NOT NULL DEFAULT 0,
      ${DbConstants.colLibCustom}   INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _createWorkoutSessions = '''
    CREATE TABLE ${DbConstants.tableWorkoutSessions} (
      ${DbConstants.colId}            INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colSessDayId}     INTEGER NOT NULL,
      ${DbConstants.colSessDate}      TEXT    NOT NULL,
      ${DbConstants.colSessDuration}  INTEGER,
      ${DbConstants.colSessNotes}     TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colSessFeeling}   INTEGER,
      ${DbConstants.colSessCompleted} INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (${DbConstants.colSessDayId})
        REFERENCES ${DbConstants.tableDays}(${DbConstants.colId})
    )
  ''';

  static const _createSetLogs = '''
    CREATE TABLE ${DbConstants.tableSetLogs} (
      ${DbConstants.colId}            INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colSetSessionId}  INTEGER NOT NULL,
      ${DbConstants.colSetExerciseId} INTEGER NOT NULL,
      ${DbConstants.colSetNumber}     INTEGER NOT NULL,
      ${DbConstants.colSetWeight}     REAL    NOT NULL DEFAULT 0,
      ${DbConstants.colSetReps}       INTEGER NOT NULL DEFAULT 0,
      ${DbConstants.colSetRir}        INTEGER,
      ${DbConstants.colSetCompleted}  INTEGER NOT NULL DEFAULT 0,
      ${DbConstants.colSetNotes}      TEXT    NOT NULL DEFAULT '',
      FOREIGN KEY (${DbConstants.colSetSessionId})
        REFERENCES ${DbConstants.tableWorkoutSessions}(${DbConstants.colId})
        ON DELETE CASCADE
    )
  ''';

  static const _createExerciseSwaps = '''
    CREATE TABLE ${DbConstants.tableExerciseSwaps} (
      ${DbConstants.colId}           INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colSwapOrigId}   INTEGER NOT NULL,
      ${DbConstants.colSwapSubId}    INTEGER NOT NULL,
      ${DbConstants.colSwapSessId}   INTEGER,
      ${DbConstants.colSwapDate}     TEXT    NOT NULL,
      ${DbConstants.colSwapReason}   TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colSwapPermanent} INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _createCardioPlans = '''
    CREATE TABLE ${DbConstants.tableCardioPlan} (
      ${DbConstants.colId}               INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colPlanName}         TEXT    NOT NULL,
      ${DbConstants.colPlanDescription}  TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colPlanStartDate}    TEXT    NOT NULL,
      ${DbConstants.colPlanCurrentWeek}  INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const _createCardioWeeks = '''
    CREATE TABLE ${DbConstants.tableCardioWeeks} (
      ${DbConstants.colId}             INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colWeekPlanId}     INTEGER NOT NULL,
      ${DbConstants.colWeekNumber}     INTEGER NOT NULL,
      ${DbConstants.colWeekObjective}  TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colWeekTargetSess} INTEGER NOT NULL DEFAULT 3,
      FOREIGN KEY (${DbConstants.colWeekPlanId})
        REFERENCES ${DbConstants.tableCardioPlan}(${DbConstants.colId})
        ON DELETE CASCADE
    )
  ''';

  static const _createCardioSessionTemplates = '''
    CREATE TABLE ${DbConstants.tableCardioSessionTemplates} (
      ${DbConstants.colId}           INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colCstWeekId}    INTEGER NOT NULL,
      ${DbConstants.colCstName}      TEXT    NOT NULL,
      ${DbConstants.colCstType}      TEXT    NOT NULL,
      ${DbConstants.colCstDuration}  INTEGER NOT NULL DEFAULT 30,
      ${DbConstants.colCstDesc}      TEXT    NOT NULL DEFAULT '',
      ${DbConstants.colCstCompleted} INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (${DbConstants.colCstWeekId})
        REFERENCES ${DbConstants.tableCardioWeeks}(${DbConstants.colId})
        ON DELETE CASCADE
    )
  ''';

  static const _createCardioSessionLogs = '''
    CREATE TABLE ${DbConstants.tableCardioSessionLogs} (
      ${DbConstants.colId}            INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colCslTemplateId} INTEGER NOT NULL,
      ${DbConstants.colCslDate}       TEXT    NOT NULL,
      ${DbConstants.colCslDuration}   INTEGER NOT NULL,
      ${DbConstants.colCslDistance}   REAL,
      ${DbConstants.colCslAvgHr}      INTEGER,
      ${DbConstants.colCslMaxHr}      INTEGER,
      ${DbConstants.colCslSpeed}      REAL,
      ${DbConstants.colCslIncline}    REAL,
      ${DbConstants.colCslFeeling}    INTEGER,
      ${DbConstants.colCslNotes}      TEXT    NOT NULL DEFAULT '',
      FOREIGN KEY (${DbConstants.colCslTemplateId})
        REFERENCES ${DbConstants.tableCardioSessionTemplates}(${DbConstants.colId})
    )
  ''';

  static const _createReminders = '''
    CREATE TABLE ${DbConstants.tableReminders} (
      ${DbConstants.colId}             INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colRemType}        TEXT    NOT NULL,
      ${DbConstants.colRemTime}        TEXT    NOT NULL,
      ${DbConstants.colRemDays}        INTEGER NOT NULL DEFAULT 127,
      ${DbConstants.colRemActive}      INTEGER NOT NULL DEFAULT 1,
      ${DbConstants.colRemPersonality} TEXT    NOT NULL DEFAULT 'sarcastico',
      ${DbConstants.colRemPostpone}    INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const _createNotificationLogs = '''
    CREATE TABLE ${DbConstants.tableNotificationLogs} (
      ${DbConstants.colId}          INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DbConstants.colNlRemId}     INTEGER NOT NULL,
      ${DbConstants.colNlSentAt}    TEXT    NOT NULL,
      ${DbConstants.colNlMessage}   TEXT    NOT NULL,
      ${DbConstants.colNlInteract}  TEXT    NOT NULL DEFAULT 'ignorada'
    )
  ''';

  // ── Índices ───────────────────────────────────────────────────────────────
  static const _idxSessionDate =
      'CREATE INDEX idx_sessions_date ON ${DbConstants.tableWorkoutSessions}(${DbConstants.colSessDate})';
  static const _idxSetLogExercise =
      'CREATE INDEX idx_setlogs_exercise ON ${DbConstants.tableSetLogs}(${DbConstants.colSetExerciseId})';
  static const _idxSetLogSession =
      'CREATE INDEX idx_setlogs_session ON ${DbConstants.tableSetLogs}(${DbConstants.colSetSessionId})';
  static const _idxCardioLogDate =
      'CREATE INDEX idx_cardiologs_date ON ${DbConstants.tableCardioSessionLogs}(${DbConstants.colCslDate})';

  // ── Utilidades ────────────────────────────────────────────────────────────
  /// Borra y recrea la base de datos (usado en pruebas / reset manual).
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DbConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _db = null;
  }
}
