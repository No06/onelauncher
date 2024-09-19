import 'package:dio/dio.dart';
import 'package:one_launcher/api/dio/interceptor.dart';

Dio createDio([BaseOptions? options]) =>
    Dio(options)..interceptors.addAll([const DebugInterceptor()]);
