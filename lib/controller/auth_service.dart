import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fridge/controller/global.dart';

Future<http.Response> authenticatedRequest({
  required BuildContext context,
  required Uri url,
  required String method,
  Map<String, String>? headers,
  dynamic body,
}) async {
  final accessToken = await storage.read(key: 'accessToken');

  final defaultHeaders = {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  };

  http.Response response;

  try {
    response = await _sendRequest(
      url: url,
      method: method,
      headers: {...?headers, ...defaultHeaders},
      body: body,
    );

    // accessToken 만료시
    if (response.statusCode == 401) {
      final reissued = await _tryReissueToken(context);

      if (!reissued) return response;

      // 새 토큰으로 다시 요청
      final newAccessToken = await storage.read(key: 'accessToken');
      final retryHeaders = {
        'Authorization': 'Bearer $newAccessToken',
        'Content-Type': 'application/json',
      };

      response = await _sendRequest(
        url: url,
        method: method,
        headers: retryHeaders,
        body: body,
      );
    }

    return response;
  } catch (e) {
    rethrow;
  }
}

Future<http.Response> _sendRequest({
  required Uri url,
  required String method,
  required Map<String, String> headers,
  dynamic body,
}) {
  switch (method.toUpperCase()) {
    case 'GET':
      return http.get(url, headers: headers);
    case 'POST':
      return http.post(url, headers: headers, body: jsonEncode(body));
    case 'PUT':
      return http.put(url, headers: headers, body: jsonEncode(body));
    case 'DELETE':
      return http.delete(url, headers: headers);
    default:
      throw UnsupportedError('Unsupported HTTP method: $method');
  }
}

Future<bool> _tryReissueToken(BuildContext context) async {
  final refreshToken = await storage.read(key: 'refreshToken');

  final response = await http.post(
    Uri.parse('$BASE_URL/auth/reissue'),
    headers: {
      'Authorization': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    await storage.write(key: 'accessToken', value: data['accessToken']);
    await storage.write(key: 'refreshToken', value: data['refreshToken']);
    return true;
  } else {
    // refreshToken도 만료 → 로그인 페이지로 이동
    await storage.deleteAll();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
    return false;
  }
}