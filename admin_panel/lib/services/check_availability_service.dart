import 'dart:convert';
import 'package:flutter_application_1/data/server_urls.dart';
import 'package:http/http.dart' as http;

abstract class AvailabilityCheckingService {
  Future<bool> checkIsAvailable(String value);
}

Future<bool> _checkIsAvailable(String queryKey, String queryValue, String url) async {
  var idk = Uri.parse(url);
  var uri = Uri.http(idk.authority, idk.path, {queryKey: queryValue});
  var response = await http.get(uri);
  return jsonDecode(response.body)['available'] as bool;
}

class CheckUsernameAvailabilityService implements AvailabilityCheckingService {
  @override
  Future<bool> checkIsAvailable(String username) async {
    return _checkIsAvailable('username', username, ServerUrls.checkUsernameAvailable);
  }
}

class CheckEmailAvailabilityService implements AvailabilityCheckingService {
  @override
  Future<bool> checkIsAvailable(String email) async {
    return _checkIsAvailable('email', email, ServerUrls.checkEmailAvailable);
  }
}