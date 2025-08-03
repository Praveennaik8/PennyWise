import 'package:penny_wise/api/base_provider.dart';
import 'package:penny_wise/models/models.dart';
import 'package:get/get.dart';

class ApiProvider extends BaseProvider {
  Future<Response> login(String path, LoginRequest data) {
    return post(path, data.toJson());
  }

  Future<Response> register(String path, RegisterRequest data) {
    return post(path, data.toJson());
  }

  Future<Response> getUsers(String path) {
    return get(path);
  }
}
