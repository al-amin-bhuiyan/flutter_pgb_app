import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient({
    required String baseUrl,
    required List<Interceptor> interceptors,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll(interceptors);
  }

  Dio get dio => _dio;
}
