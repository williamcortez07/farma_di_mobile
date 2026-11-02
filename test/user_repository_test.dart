import 'dart:convert';

import 'package:farma_di_mobile/core/errors/app_exception.dart';
import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/user_model.dart';
import 'package:farma_di_mobile/data/repositories/app_user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: 'BASE_API_URL=https://api.example.test/api',
    );
  });

  test('GET users builds the paged request and parses the response', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      tokenProvider: () async => 'test-token',
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 7,
                'userName': 'Test',
                'userLastName': 'User',
                'mail': 'test@example.test',
                'userPhone': '5551234',
                'rolId': 0,
                'isActive': true,
                'roles': [
                  {'rolId': 7, 'rolName': 'Admin'},
                ],
              },
            ],
            'meta': {
              'totalItems': 12,
              'totalPages': 2,
              'currentPage': 2,
              'itemsPerPage': 10,
              'hasPreviousPage': true,
              'hasNextPage': false,
            },
          }),
          200,
        );
      }),
    );
    addTearDown(client.dispose);

    final result = await UserRepository(client).getUsers(page: 2, limit: 10);

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/User');
    expect(capturedRequest.url.queryParameters, {'page': '2', 'limit': '10'});
    expect(capturedRequest.headers['Authorization'], 'Bearer test-token');
    expect(result.users.single.fullName, 'Test User');
    expect(result.users.single.roles.single.name, 'Admin');
    expect(result.meta.totalItems, 12);
    expect(result.meta.currentPage, 2);
    expect(result.meta.hasNextPage, isFalse);
  });

  test('POST user sends the expected fields and role ID structure', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 201);
      }),
    );
    addTearDown(client.dispose);

    await UserRepository(client).createUser(
      name: 'Test',
      lastName: 'User',
      password: 'test-password',
      email: 'test@example.test',
      phone: '5551234',
      roleId: 7,
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/User');
    expect(jsonDecode(capturedRequest.body), {
      'userName': 'Test',
      'userLastName': 'User',
      'password': 'test-password',
      'mail': 'test@example.test',
      'userPhone': '5551234',
      'rolesIds': [
        {'idRoles': 7},
      ],
    });
  });

  test(
    'PUT user sends editable fields and only sends a new password when set',
    () async {
      late http.Request capturedRequest;
      final client = ApiClient(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
      );
      addTearDown(client.dispose);
      const user = AppUserModel(
        id: 7,
        name: 'Test',
        lastName: 'User',
        email: 'test@example.test',
        phone: '5551234',
        roleId: 0,
        roles: [],
        isActive: true,
      );

      await UserRepository(client).updateUser(
        user,
        name: 'Updated',
        lastName: 'User',
        email: 'updated@example.test',
        phone: '5550000',
        isActive: false,
      );

      expect(capturedRequest.method, 'PUT');
      expect(capturedRequest.url.path, '/api/User/7');
      expect(jsonDecode(capturedRequest.body), {
        'userName': 'Updated',
        'userLastName': 'User',
        'mail': 'updated@example.test',
        'userPhone': '5550000',
        'isActive': false,
      });
    },
  );

  test('GET users rejects a response without pagination metadata', () async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('{"data":[]}', 200)),
    );
    addTearDown(client.dispose);

    await expectLater(
      UserRepository(client).getUsers(),
      throwsA(isA<ParsingException>()),
    );
  });
}
