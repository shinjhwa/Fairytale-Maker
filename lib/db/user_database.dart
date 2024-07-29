import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final int? id;
  final String username;
  final String password;
  final String name; // 이름 필드
  final String phoneNumber; // 휴대폰 번호 필드
  final String childGender; // 아이의 성별 필드
  final int childAge; // 아이의 나이 필드

  User({
    this.id,
    required this.username,
    required this.password,
    required this.name, // 이름 필드 초기화
    required this.phoneNumber, // 휴대폰 번호 필드 초기화
    required this.childGender, // 아이의 성별 필드 초기화
    required this.childAge, // 아이의 나이 필드 초기화
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? name,
    String? phoneNumber,
    String? childGender,
    int? childAge,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      childGender: childGender ?? this.childGender,
      childAge: childAge ?? this.childAge,
    );
  }

  Map<String, dynamic> toJson() => {
    UserFields.id: id,
    UserFields.username: username,
    UserFields.password: password,
    UserFields.name: name,
    UserFields.phoneNumber: phoneNumber,
    UserFields.childGender: childGender,
    UserFields.childAge: childAge,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json[UserFields.id],
    username: json[UserFields.username],
    password: json[UserFields.password],
    name: json[UserFields.name],
    phoneNumber: json[UserFields.phoneNumber],
    childGender: json[UserFields.childGender],
    childAge: json[UserFields.childAge],
  );
}

class UserFields {
  static final List<String> values = [
    id,
    username,
    password,
    name,
    phoneNumber,
    childGender,
    childAge
  ];

  static const String id = '_id';
  static const String username = 'username';
  static const String password = 'password';
  static const String name = 'name';
  static const String phoneNumber = 'phoneNumber';
  static const String childGender = 'childGender';
  static const String childAge = 'childAge';
}

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE users ( 
  ${UserFields.id} $idType, 
  ${UserFields.username} $textType,
  ${UserFields.password} $textType,
  ${UserFields.name} $textType,
  ${UserFields.phoneNumber} $textType,
  ${UserFields.childGender} $textType,
  ${UserFields.childAge} $intType
  )
''');
  }

  Future<User?> getUser(String username, String password) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: UserFields.values,
      where: '${UserFields.username} = ? AND ${UserFields.password} = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<User?> fetchUserByUsername(String username) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: UserFields.values,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertUser(User user) async {
    final db = await instance.database;

    await db.insert('users', user.toJson());
  }

  Future<void> updateUser(User user) async {
    final db = await instance.database;

    await db.update(
      'users',
      user.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await instance.database;

    await db.delete(
      'users',
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    await deleteDatabase(path);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
