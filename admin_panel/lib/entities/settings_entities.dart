import 'package:flutter/src/widgets/framework.dart';

class SettingsMeta {
  String name;
  String description;

  SettingsMeta({required this.name, required this.description});

  factory SettingsMeta.fromJSON(Map<String, dynamic> json) =>
    SettingsMeta(name: json['name'], description: json['description']);
}

class PasswordRequirement {
  SettingsMeta meta;
  int minLength;
  RegExp pattern;
  String patternDescription;


  PasswordRequirement({required this.meta, required this.minLength, required this.pattern, required this.patternDescription});
  
  factory PasswordRequirement.fromJSON(Map<String, dynamic> json) =>
      PasswordRequirement(
          meta: SettingsMeta.fromJSON(json['meta']), 
          minLength: json['min_length'], 
          pattern: RegExp(json['pattern']),
          patternDescription: json['pattern_description']);
}