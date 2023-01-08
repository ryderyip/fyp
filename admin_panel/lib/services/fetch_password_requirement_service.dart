import 'dart:convert';

import 'package:flutter_application_1/data/server_urls.dart';

import '../entities/settings_entities.dart';
import 'package:http/http.dart' as http;

class FetchPasswordRequirementService {
  Future<PasswordRequirement> fetch() async {
    var response = await http.get(Uri.parse(ServerUrls.getPasswordRequirement));
    return PasswordRequirement.fromJSON(jsonDecode(response.body));
  }
}