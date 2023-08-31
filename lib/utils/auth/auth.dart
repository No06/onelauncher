import 'dart:convert';
import 'package:http/http.dart' as http;

// 获取code
String? _getUrlCode(final String url) {
  const url =
      'https://login.live.com/oauth20_authorize.srf?client_id=00000000402b5328&response_type=code&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf';
  final uri = Uri.parse(url);
  return uri.queryParameters['code'];
}

// 定义请求的URL和参数
final code = _getUrlCode(url)!;
const url =
    'https://login.microsoftonline.com/your_tenant_id/oauth2/v2.0/token';
final Map<String, String> params = {
  "client_id": "00000000402b5328", // 还是Minecraft客户端id
  "code": code, // 第一步中获取的代码
  "grant_type": "authorization_code",
  "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
  "scope": "service::user.auth.xboxlive.com::MBI_SSL"
};

// 发送POST请求并解析响应
void main() async {
  final response = await http.post(Uri.parse(url), body: params);
  final json = jsonDecode(response.body);
  final accessToken = json['access_token'];
  print('Access token: $accessToken');
}
