import 'dart:async';

import 'package:flutter_application_1/data/server_urls.dart';
import 'package:flutter_application_1/services/fetch_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'fetch_user_tests.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('fetch student/teacher/admin', () {
    test('returns a student if the http call completes successfully', () async {
      final client = MockClient();
      var service = FetchUserService(client: client);
      var url = Uri.parse(ServerUrls.getStudentsUrl());

      when(client.get(url, headers: <String, String>{
        'name': '',
        'phone': '',
        'email': '',
      })).thenAnswer((_) async => Future.delayed(const Duration(seconds: 10)).then((value) => http.Response('', 200)));
      expect(() async => await service.fetchUsers(url.toString()), throwsA(isA<TimeoutException>()));
    });
  });
}
