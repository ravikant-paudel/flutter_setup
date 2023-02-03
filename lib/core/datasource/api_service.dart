import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio_logger/dio_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_setup/core/base/base_model.dart';
import 'package:flutter_setup/core/flavour.dart';
import 'package:logger/logger.dart';

typedef PostResponseCallback<T extends BaseModel> = Future<void> Function(T);

class ProcessingFailure extends BaseModel {
  ProcessingFailure({required this.detail, required this.errorCode});

  final String detail;
  final String errorCode;

  factory ProcessingFailure.fromJson(Map<String, dynamic> json) {
    return ProcessingFailure(detail: json['detail'], errorCode: json['error_code']);
  }

  @override
  List<Object?> get props => [detail, errorCode];
}

class ApiService {
  late Dio _dio;

  static final Map<String, dynamic> _header = {};

  CancelToken _cancelToken;

  CancelToken get cancelToken => _cancelToken;

  static final FlavorConfig _flavorConfig = FlavorConfig.instance;

  String? _scene;

  void setScene(String scene) {
    _scene = scene;
  }

  ApiService({Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _flavorConfig.baseUrl,
                connectTimeout: 60000,
                receiveTimeout: 60000,
                headers: _header,
              ),
            )
          ..interceptors.addAll(_flavorConfig.flavor == Flavor.prod ? [] : [dioLoggerInterceptor]),
        _cancelToken = CancelToken();

  void setAuthToken(String? token) {
    if (token == null) {
      _header.remove('Authorization');
    } else {
      _header['Authorization'] = 'Token $token';
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _flavorConfig.baseUrl,
        connectTimeout: 60000,
        receiveTimeout: 60000,
        headers: _header,
      ),
    );

    if (_flavorConfig.flavor != Flavor.prod) {
      _dio.interceptors.add(dioLoggerInterceptor);
    }
  }

  Future<T> post<T extends BaseModel>(
    String path,
    T Function(Map<String, dynamic>) converter, {
    Map<String, dynamic> data = const {},
    PostResponseCallback<T>? after,
  }) async {
    try {
      _cancelToken = CancelToken();
      final response = await _dio.post(
        _buildUrl(path),
        data: data,
        options: Options(
          headers: await _prepareHeader(),
        ),
        cancelToken: _cancelToken,
      );

      final model = converter(response.data);
      await after?.call(model);

      return model;
    } on DioError catch (e) {
      if (e.response?.data != null) {
        final errorMap = _prepareErrorMap(e.response?.data);

        throw ProcessingFailure.fromJson(errorMap);
      } else {
        throw ProcessingFailure.fromJson(const {'detail': 'Something unexpected happened.', 'error_code': 'unexpected'});
      }
    } catch (e) {
      Logger().wtf(e);
      throw ProcessingFailure.fromJson(const {'detail': 'Something unexpected happened.', 'error_code': 'unexpected'});
    }
  }

  final List<String> _excludeErrorKey = ['status_code', 'detail'];

  Map<String, dynamic> _prepareErrorMap(Map<String, dynamic> errorMap) {
    final error = <String, dynamic>{
      'error_code': errorMap['status_code']?.toString() ?? errorMap['error_key'] ?? 'unexpected',
    };

    if (errorMap.containsKey('detail')) {
      error.putIfAbsent('detail', () => errorMap['detail']);
    } else {
      final errorMessage = [];

      for (var e in errorMap.entries) {
        if (_excludeErrorKey.contains(e.key)) continue;

        if (e.value is Iterable) {
          errorMessage.addAll(e.value);
        } else {
          errorMessage.add(e.value);
        }
      }

      error.putIfAbsent('detail', () => errorMessage.join('\n'));
    }

    return error;
  }

  String _buildUrl(String path, {bool fromMainVersion = false}) {
    return 'api/${fromMainVersion ? 'v5' : 'v${_flavorConfig.apiVersion}'}/$path';
  }

  Future<Map<String, dynamic>> _prepareHeader() async {
    final deviceInfo = DeviceInfoPlugin();

    final header = {
      ..._dio.options.headers,
      'DEVICEID': (await deviceInfo.androidInfo).id ?? '',
      if (_scene != null) 's': _scene,
    };

    if (_scene != null) _scene = null;

    return header;
  }
}

// T get<T extends BaseModel>(String path, T Function(Map<String, dynamic>) converter) {
//   return converter({});
// }
//
// _testFunction() {
//   fetchUser('kdfj/sdf', TestModel.fromJson);
// }
//
// class TestModel extends BaseModel {
//   TestModel();
//
//   factory TestModel.fromJson(Map<String, dynamic> json) {
//     return TestModel();
//   }
//
//   @override
//   // TODO: implement props
//   List<Object?> get props => throw UnimplementedError();
// }
//
// extension on Response {
//   T toModel<T extends BaseModel>() {
//     if (T == MerchantModel) {
//       return MerchantModel.fromJson(data) as T;
//     } else if (T == CardModel) {
//       return CardModel.fromJson(data) as T;
//     } else if (T == UserModel) {
//       return UserModel.fromJson(data) as T;
//     } else if (T == PaymentSuccessModel) {
//       return PaymentSuccessModel.fromJson(data) as T;
//     } else if (T == LogoutModel) {
//       return LogoutModel.fromJson(data) as T;
//     } else if (T == TTLModel) {
//       return TTLModel.fromJson(data) as T;
//     }
//
//     throw Exception('Model $T not found.');
//   }
// }

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
