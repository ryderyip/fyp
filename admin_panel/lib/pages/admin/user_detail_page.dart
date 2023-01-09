import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';
import 'package:flutter_application_1/services/fetch_user_service.dart';

class UserDetailsPage extends StatefulWidget {
  final UserType usertype;
  final User user;

  const UserDetailsPage({super.key, required this.usertype, required this.user});

  @override
  State<StatefulWidget> createState() => _UserDetailsPage();
}

class _UserDetailsPage extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var userInfo = widget.user.commonInformation;
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
                child: TextFormField(decoration: InputDecoration(filled: true, fillColor: Colors.orange[200]), initialValue: value, readOnly: true),
              )
            ],
          ),
        );

    List<Widget> makeRows() => [
          makeRow('Name', userInfo.name),
          makeRow('Gender', userInfo.gender.name),
          makeRow('Birthday', userInfo.dateOfBirth.toIso8601String().split('T')[0]),
          makeRow('Phone No.', userInfo.phone),
          makeRow('Email Address', userInfo.email),
          makeRow('Username', userInfo.username ?? '-'),
        ];
    
    return FutureBuilder(
        future: FetchUserService(search: userInfo.email).fetch(),
        builder: (context, AsyncSnapshot<Iterable> snapshot) => Scaffold(
              appBar: AppBar(
                title: Text('${widget.usertype.name} ${userInfo.name}'),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  children: widget.usertype == UserType.teacher 
                  ? (makeRows()..add(makeRow('Occupation', (widget.user as Teacher).occupation.toTitleCase())))
                  : makeRows(),
                ),
              ),
            ));
  }
}
