import 'dart:convert';

import 'package:http/http.dart' as http;

Future<dynamic> httpPost(String url,
    {Object? params, Map<String, String>? header}) async {
  final response =
      await http.post(Uri.parse(url), body: params, headers: header);
  // print(response.body);
  return jsonDecode(response.body);
}

Future<dynamic> httpGet(String url, {Map<String, String>? header}) async {
  final response = await http.get(Uri.parse(url), headers: header);
  // print(response.body);
  return jsonDecode(response.body);
}
