import 'package:dio/dio.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';

void _requestPrint(String message) =>
    debugPrint(message, title: "Request ➡", contentColor: cyan);
void _responsePrint(String message) =>
    debugPrint(message, title: "Response ⬅", contentColor: cyan);
void _errorPrint(String message) =>
    debugPrint(message, title: "Request Error ✖", contentColor: red);

class DebugInterceptor extends Interceptor {
  const DebugInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestPrint(_handleRequestFormat(options));
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _responsePrint(_handleResponseFormat(response));
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _errorPrint(err.message.toString());
    super.onError(err, handler);
  }
}

String _handleRequestFormat(RequestOptions options) => '''
[${options.method}] ${options.uri}
$blue data: ${options.data}
''';

String _handleResponseFormat(Response response) => '''
[${response.statusCode}: ${response.statusMessage}] ${response.realUri}
$blue data: ${response.data}
''';
