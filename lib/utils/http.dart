import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<dynamic> httpPost(String url,
    {Object? body, Map<String, String>? header}) async {
  final response = await http.post(Uri.parse(url), body: body, headers: header);
  return jsonDecode(response.body);
}

Future<dynamic> httpGet(String url, {Map<String, String>? header}) async {
  final response = await http.get(Uri.parse(url), headers: header);
  debugPrint(response.body);
  return jsonDecode(response.body);
}
