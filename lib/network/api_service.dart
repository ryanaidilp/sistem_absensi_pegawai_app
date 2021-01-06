import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class ApiService {
  ApiService({@required this.api});

  final API api;
  String token = '';

  Future<void> _getToken() async {
    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    token = jsonDecode(localStorage.getString(PREFS_TOKEN_KEY)) as String;
  }

  Future<Map<String, dynamic>> getEndpointData(
      {@required Endpoint endpoint, Map<String, String> query}) async {
    final url = api.endpointUri(endpoint);
    await _getToken();
    Uri uri = Uri.parse(url);
    if (query != null) {
      uri = uri.replace(queryParameters: query);
    }
    final response = await http.get(uri, headers: _setHeaders());
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        return data;
      }
    }
    print(
        'Request $url failed\nResponse: ${response.statusCode} ${response.reasonPhrase}');
    throw response;
  }

  Future<http.Response> postEndpointWithoutToken(
      {@required Endpoint endpoint, Map<String, dynamic> data}) async {
    final url = api.endpointUri(endpoint);
    return await http.post(url, body: data);
  }

  Future<http.Response> postEndpointWithToken(
      {@required Endpoint endpoint, Map<String, dynamic> data}) async {
    await _getToken();
    final url = api.endpointUri(endpoint);
    return await http.post(url, body: jsonEncode(data), headers: _setHeaders());
  }

  Map<String, String> _setHeaders() => <String, String>{
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
}
