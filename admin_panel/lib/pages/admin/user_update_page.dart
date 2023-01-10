import 'dart:async';
import 'package:admin_panel/pages/admin/user_create_update_form.dart';
import 'package:admin_panel/pages/admin/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:http/http.dart';

class UserUpdatePage<T extends User> extends StatelessWidget {
  final UserType userType;
  final StreamController<T> _userUpdatedController = StreamController<T>.broadcast();
  Stream<T> get userUpdated => _userUpdatedController.stream;
  final T userToUpdate;
  late final String originalEmail;

  UserUpdatePage({super.key, required this.userType, required this.userToUpdate}) {
    originalEmail = userToUpdate.commonInformation.email;
  }

  @override
  Widget build(BuildContext context) {
    void onSuccessfulCreated({required T updatedUser}) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated!')));
      _userUpdatedController.add(updatedUser);
    }

    void onFailedToUpdate(Response res) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Failed to update user"),
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
    
    void formSubmitted(T updatedUser) async{
        var res = await updatedUser.update(originalEmail: originalEmail);
        var successful = res.statusCode == 200;
        if (successful) {
          onSuccessfulCreated(updatedUser: updatedUser);
        } else {
          onFailedToUpdate(res);
        }
    }
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Update ${userToUpdate.commonInformation.name}\'s Account Info'),
        ),
        body: UserCreateUpdateForm(userType: userType, userToUpdate: userToUpdate,
        confirmationMessage: "Confirm updating ${userType.name}?",)
          ..formSubmitted.listen((user) => formSubmitted(user)),
      );
  }
}

