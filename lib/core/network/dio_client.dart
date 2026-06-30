import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class DioClient {
  final Dio _dio;

  DioClient({
    Dio? dio,
    String? baseUrl,
    List<Interceptor>? interceptors,
  }) : _dio = dio ?? Dio(
          BaseOptions(
            baseUrl: baseUrl ?? '',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  Dio get dio => _dio;

  // Generic GET Request for a single object
  Future<T> get<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      (data) => fromJson(data as Map<String, dynamic>),
    );
  }

  // Generic GET Request for a list response wrapped in a "data" map key
  Future<List<T>> getList<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      (data) {
        final Map<String, dynamic> dataMap = data as Map<String, dynamic>;
        final list = dataMap['data'] as List<dynamic>;
        return list.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  // Generic POST Request
  Future<T> post<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    dynamic data,
  }) async {
    return _request(
      () => _dio.post(path, data: data),
      (resData) {
        if (resData == null) {
          return null as T;
        }
        return fromJson(resData as Map<String, dynamic>);
      },
    );
  }

  // Generic PUT Request
  Future<T> put<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    dynamic data,
  }) async {
    return _request(
      () => _dio.put(path, data: data),
      (resData) {
        if (resData == null) {
          return null as T;
        }
        return fromJson(resData as Map<String, dynamic>);
      },
    );
  }

  // Generic PATCH Request
  Future<void> patch({
    required String path,
    dynamic data,
  }) async {
    await _request<void>(
      () => _dio.patch(path, data: data),
      (_) => null,
    );
  }

  // Generic DELETE Request
  Future<void> delete({
    required String path,
  }) async {
    await _request<void>(
      () => _dio.delete(path),
      (_) => null,
    );
  }

  // Private helper to wrap executions and handle exceptions consistently
  Future<R> _request<R>(
    Future<Response<dynamic>> Function() request,
    R Function(dynamic data) parse,
  ) async {
    try {
      final response = await request();
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return parse(response.data);
      } else {
        throw ServerException(
          message: response.statusMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          message: e.response?.data?['error']?['message'] as String? ?? 'Unauthorized',
        );
      }
      throw ServerException(
        message: e.response?.data?['error']?['message'] as String? ?? e.message,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
