import 'package:flutter_setup/core/datasource/api_service.dart';

class BaseService {
  BaseService(this.api);

  final ApiService? api;

  void setScene(String scene) => (api ?? ApiService()).setScene(scene);
}
