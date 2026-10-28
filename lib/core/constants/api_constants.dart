import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  String get baseUrl => dotenv.env['BASE_API_URL']?.trim() ?? '';
  String get environment => dotenv.env['ENVIRONMENT']?.trim() ?? '';

  ApiConstants._privateConstructor();
  static final ApiConstants _instance = ApiConstants._privateConstructor();
  static ApiConstants get instance => _instance;

  static const String login = '/Auth/login';

  // Logs endpoints
  static const String logs = '/api/Logs';
  static const String logsInformation = '/api/Logs/information';
  static const String logsWarning = '/api/Logs/warning';
  static const String logsError = '/api/Logs/error';
  static const String logsToday = '/api/Logs/today';
  static const String logsDateRange = '/api/Logs/date-range';
  static String logsByLevel(String level) => '/api/Logs/level/$level';

  // User endpoints
  static const String user = '/User';
  static String userById(int id) => '/User/$id';

  static const timeoutduration = Duration(seconds: 30);
}
