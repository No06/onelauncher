import 'dart:convert';

import 'package:http/http.dart' as http;

Future<dynamic> httpPost(String url, Map params) async {
  final response = await http.post(Uri.parse(url), body: params);
  return jsonDecode(response.body);
}
