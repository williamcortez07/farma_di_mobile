import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  String get baseUrl => dotenv.env['BASE_API_URL'] ?? '';
  String get environment => dotenv.env['ENVIRONMENT'] ?? '';

  ApiConstants._privateConstructor();
  static final ApiConstants _instance = ApiConstants._privateConstructor();
  static ApiConstants get instance => _instance;

  static const String login = '/Auth/login';

  // Catálogos
  static const String products = '/Products';
  static const String categories = '/Categories';
  static const String brands = '/Brands';
  static const String inventory = '/Inventory';
  static const String stock = '/Stock';

  static const timeoutduration = Duration(seconds: 30);
}
