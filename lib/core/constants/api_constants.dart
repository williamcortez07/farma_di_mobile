import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  String get baseUrl => dotenv.env['BASE_API_URL']?.trim() ?? '';
  String get environment => dotenv.env['ENVIRONMENT']?.trim() ?? '';

  ApiConstants._privateConstructor();
  static final ApiConstants _instance = ApiConstants._privateConstructor();
  static ApiConstants get instance => _instance;

  static const String login = '/Auth/login';

  // Logs endpoints
  static const String logs = '/Logs';
  static const String logsInformation = '/Logs/information';
  static const String logsWarning = '/Logs/warning';
  static const String logsError = '/Logs/error';
  static const String logsToday = '/Logs/today';
  static const String logsDateRange = '/Logs/date-range';
  static String logsByLevel(String level) => '/Logs/level/$level';

  // User endpoints
  static const String user = '/User';
  static String userById(int id) => '/User/$id';

  static const timeoutduration = Duration(seconds: 30);
}
