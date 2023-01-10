import 'dart:async';

import 'package:admin_panel/pages/admin/user_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';
import 'package:flutter_application_1/services/fetch_user_service.dart';

class UserDetailsPage<T extends User> extends StatefulWidget {
  final UserType usertype;
  final String userEmail;
  final StreamController<void> _userUpdatedController = StreamController<void>.broadcast();
  Stream<void> get userUpdated => _userUpdatedController.stream;
  
  UserDetailsPage({super.key, required this.usertype, required this.userEmail});

  @override
  State<StatefulWidget> createState() => _UserDetailsPage<T>();
}

class _UserDetailsPage<T extends User> extends State<UserDetailsPage<T>> {
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = widget.userEmail;
  }

  @override
  Widget build(BuildContext context) {
    Widget makeRow(String name, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                '$name:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )),
              Expanded(
                flex: 2,
                child: TextFormField(decoration: InputDecoration(
                    filled: true, fillColor: Colors.orange[200]), initialValue: value, readOnly: true,
                    key: Key(value.toString())),
              )
            ],
          ),
        );

    List<Widget> makeRows(T user) {
      CommonInformation userInfo = user.commonInformation;
      _makeRows() => [
            makeRow('Name', userInfo.name),
            makeRow('Gender', userInfo.gender.name),
            makeRow('Birthday', userInfo.dateOfBirth.toIso8601String().split('T')[0]),
            makeRow('Phone No.', userInfo.phone),
            makeRow('Email Address', userInfo.email),
            makeRow('Username', userInfo.username ?? '-'),
          ];
      return widget.usertype == UserType.teacher
          ? (_makeRows()..add(makeRow('Occupation', (user as Teacher).occupation.toTitleCase())))
          : _makeRows();
    }
 
    return FutureBuilder(
        future: FetchUserService(search: _userEmail).fetch<T>(),
        builder: (BuildContext context, AsyncSnapshot<Iterable<T>> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          var user = snapshot.data!.first;
          return Scaffold(
              appBar: AppBar(
                title: Text('${widget.usertype.name} ${user.commonInformation.name}'),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  children: [
                    Expanded(child: Column(children: makeRows(user))),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextButton(
                        onPressed: () => _showUpdatePage(user),
                        child: const Text('Update'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TextButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Confirmation"),
                                  content: Text("Confirm removing ${widget.usertype.name} '${user.commonInformation.name}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => _confirmAndRemoveUser(user),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                )),
                        child: const Text('Remove Account'),
                      ),
                    ),
                  ],
                ),
              ),
            );
        });
  }

  void _showUpdatePage(T user) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => 
          UserUpdatePage<T>(userType: widget.usertype, userToUpdate: user)
            ..userUpdated.listen((updatedUser) => setState(() => _userEmail = updatedUser.commonInformation.email)),
    ));
  }

  void _confirmAndRemoveUser(T user) {
    user.remove();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.commonInformation.name}\'s account removed!')));
    Navigator.of(context).popUntil((Route route) => route.isFirst);
    widget._userUpdatedController.add(null);
  }
}
