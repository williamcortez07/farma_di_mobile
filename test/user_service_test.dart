import 'dart:convert';

import 'package:farma_di_mobile/core/network/api_client.dart';
import 'package:farma_di_mobile/data/models/auth_model/update_user_dto.dart';
import 'package:farma_di_mobile/data/repositories/user_repository.dart';
import 'package:farma_di_mobile/presentation/controllers/roles_controller.dart';
import 'package:farma_di_mobile/services/user_service.dart';
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

  test('GET users sends page and limit and parses total metadata', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
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
              'currentPage': 1,
              'itemsPerPage': 10,
              'hasPreviousPage': false,
              'hasNextPage': true,
            },
          }),
          200,
        );
      }),
    );
    addTearDown(client.dispose);

    final response = await UserService(client).getUsers(page: 1, limit: 10);

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/User');
    expect(capturedRequest.url.queryParameters, {'page': '1', 'limit': '10'});
    expect(response.users.single.fullName, 'Test User');
    expect(response.meta.totalItems, 12);
    expect(response.meta.hasNextPage, isTrue);
  });

  test('GET roles parses catalog IDs and omits inactive roles', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 7, 'rolName': 'Admin', 'isActive': true},
              {'id': 8, 'rolName': 'Empleado', 'isActive': true},
              {'id': 9, 'rolName': 'Inactive', 'isActive': false},
            ],
            'meta': {'totalAmount': 3, 'message': 'Operación exitosa'},
          }),
          200,
        );
      }),
    );
    addTearDown(client.dispose);

    final roles = await UserService(client).getRoles();

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/Roles');
    expect(roles.map((role) => '${role.rolId}:${role.rolName}'), [
      '7:Admin',
      '8:Empleado',
    ]);
  });

  test('POST user sends the API fields and selected role ID', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 201);
      }),
    );
    addTearDown(client.dispose);

    await UserService(client).createUser(
      userName: 'Test',
      userLastName: 'User',
      password: 'synthetic-test-password',
      mail: 'test@example.test',
      userPhone: '5551234',
      roleId: 7,
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/User');
    expect(jsonDecode(capturedRequest.body), {
      'userName': 'Test',
      'userLastName': 'User',
      'password': 'synthetic-test-password',
      'mail': 'test@example.test',
      'userPhone': '5551234',
      'rolesIds': [
        {'idRoles': 7},
      ],
    });
  });

  test('PUT managed user omits a blank password', () async {
    late http.Request capturedRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      }),
    );
    addTearDown(client.dispose);

    await UserService(client).updateManagedUser(
      7,
      const UpdateUserDto(
        userName: 'Updated',
        userLastName: 'User',
        mail: 'updated@example.test',
        userPhone: '5550000',
        isActive: false,
      ),
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
  });

  test('controller renders an unpaged API collection in limit-sized pages', () async {
    var userRequests = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/api/Roles') {
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 7, 'rolName': 'Admin', 'isActive': true},
              ],
              'meta': {'totalAmount': 1, 'message': 'Operación exitosa'},
            }),
            200,
          );
        }
        userRequests++;
        final users = List.generate(
          12,
          (index) => {
            'id': index + 1,
            'userName': 'User${index + 1}',
            'userLastName': 'Test',
            'mail': 'user${index + 1}@example.test',
            'userPhone': '5550000',
            'rolId': 7,
            'isActive': true,
            'roles': [
              {'rolId': 7, 'rolName': 'Admin'},
            ],
          },
        );
        return http.Response(
          jsonEncode({
            'data': users,
            'meta': {
              'totalItems': 12,
              'totalPages': 2,
              'currentPage': 1,
              'itemsPerPage': 10,
              'hasPreviousPage': false,
              'hasNextPage': true,
            },
          }),
          200,
        );
      }),
    );
    addTearDown(client.dispose);
    final controller = RolesController(
      UserRepository(UserService(client)),
    );
    addTearDown(controller.dispose);

    await controller.fetchUsers();
    expect(controller.users, hasLength(10));
    expect(controller.totalItems, 12);
    expect(controller.hasNextPage, isTrue);

    await controller.nextPage();
    expect(controller.users, hasLength(2));
    expect(controller.users.first.id, 11);
    expect(controller.users.last.id, 12);
    expect(controller.currentPage, 2);
    expect(userRequests, 1);
  });
}
