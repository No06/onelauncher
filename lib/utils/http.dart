import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<dynamic> httpPost(
  String url, {
  Object? body,
  Map<String, String>? header,
  bool catchError = true,
}) async {
  final uri = Uri.parse(url);
  final response = await http.post(uri, body: body, headers: header);
  if (response.statusCode != 200 && response.reasonPhrase != null) {
    throw HttpException(response.reasonPhrase!, uri: uri);
  }
  return jsonDecode(response.body);
}

Future<dynamic> httpGet(String url, {Map<String, String>? header}) async {
  final uri = Uri.parse(url);
  final response = await http.get(uri, headers: header);
  if (response.statusCode != 200 && response.reasonPhrase != null) {
    throw HttpException(response.reasonPhrase!, uri: uri);
  }
  return jsonDecode(response.body);
}
