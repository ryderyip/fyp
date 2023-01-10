import 'dart:async';
import 'package:admin_panel/pages/admin/user_create_update_form.dart';
import 'package:admin_panel/pages/admin/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:http/http.dart';

class UserCreatePage extends StatelessWidget {
  final UserType userType;
  final StreamController _userCreatedController = StreamController.broadcast();
  Stream get userCreated => _userCreatedController.stream;

  UserCreatePage({super.key, required this.userType });

  @override
  Widget build(BuildContext context) {
    void onSuccessfulCreated(User user) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Created!')));
      
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
          UserDetailsPage(usertype: userType, userEmail: user.commonInformation.email)));
      
      _userCreatedController.add(null);
    }

    void onFailedToCreate(Response res) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Failed to create user"),
          content: Text('Response Code: ${res.statusCode}.\nReason: ${res.reasonPhrase ?? ''}'),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Create ${userType.name} Page'),
        ),
        body: UserCreateUpdateForm(userType: userType,
         confirmationMessage: "Confirm creating ${userType.name}?")..formSubmitted.listen((User user) async {
          var res = await user.create();
          var successful = res.statusCode == 200;
          if (successful)
            onSuccessfulCreated(user);
          else
            onFailedToCreate(res);
        }),
      );
  }
}

