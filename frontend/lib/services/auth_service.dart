import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    final response = await _client.post(
      '/auth/register',
      body: {'email': email, 'password': password, 'name': name},
      withAuth: false,
    );
    return {
      'token': response['token'],
      'user': User.fromJson(response['user']),
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      withAuth: false,
    );
    return {
      'token': response['token'],
      'user': User.fromJson(response['user']),
    };
  }

  Future<User> getMe() async {
    final response = await _client.get('/auth/me');
    return User.fromJson(response['user']);
  }
}
