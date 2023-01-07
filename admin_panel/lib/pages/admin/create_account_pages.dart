import 'package:admin_panel/pages/admin/create_account_widgets/gender_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';
import 'package:flutter_application_1/services/create_user_service.dart';
import 'package:flutter_application_1/services/fetch_occupations_service.dart';
import 'package:http/src/response.dart';

import 'create_account_widgets/birthday_field.dart';

class AccountCreatePage<T extends User> extends StatefulWidget {
  const AccountCreatePage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountCreatePageState<T>();
}

class _AccountCreatePageState<T extends User> extends State<AccountCreatePage> {
  // first value is the CreateUserRequestKeys, second is the function that fetches the field value
  final Map<CreateUserRequestKeys, String Function()> _fieldValueGetterMap = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _buildCreateUserPlace();
  }

  Widget _buildCreateUserPlace() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${T == Student ? 'Student' : T == Teacher ? 'Teacher' : 'Admin'} Page'),
      ),
      body: FutureBuilder<Iterable<String>>(
          future: FetchOccupationService().fetchOccupations(),
          builder: (context, snapshot) {
            List<Widget> makeFormFields() =>T == Student
                ? (_makeCommonFields()..add(_makeSubmitButton()))
                : T == Teacher
                ? (_makeCommonFields()
              ..addAll(_makeTeacherFields(snapshot.data))
              ..add(_makeSubmitButton()))
                : (_makeCommonFields()..add(_makeSubmitButton()));
            
            return !snapshot.hasData
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Form(
                        child: Column(
                          children: makeFormFields()),
                        ),
                      ),
                    ),
                  );
          }),
    );
  }

  List<Widget> _makeCommonFields() {
    return [
      makeNameField(),
      makeGenderField(),
      makeBirthdayField(),
      makePhoneField(),
      makeEmailField(),
      makeUsernameField(),
      makePasswordField(),
    ];
  }

  Widget makeNameField() {
    final TextEditingController nameController = TextEditingController();
    _fieldValueGetterMap[CreateUserRequestKeys.fullname] = () => nameController.value.text;
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Full Name'),
      validator: (String? value) {
        if (value == null || value.isEmpty) return 'Please enter your full name';
        return null;
      },
      enableSuggestions: false,
      controller: nameController,
    );
  }
  
  Widget makeGenderField() {
    Gender selected = Gender.male;
    void selectedGenderListener(Gender gender) => selected = gender;
    _fieldValueGetterMap[CreateUserRequestKeys.gender] = () => selected.name;
    return GenderFieldGroup(defaultSelected: selected, onGenderChanged: selectedGenderListener);
  }

  Widget makeBirthdayField() {
    DateTime selected = DateTime(DateTime.now().year - 18);
    void selectedBirthdayChangedListener(DateTime birthday) => selected = birthday;
    _fieldValueGetterMap[CreateUserRequestKeys.dateOfBirth] = () => selected.toString();
    return BirthdayField(defaultSelected: selected, onBirthdateChanged: selectedBirthdayChangedListener);
  }

  Widget makePhoneField() {
    final TextEditingController phoneController = TextEditingController();
    var field = TextFormField(
        maxLength: 20,
        decoration: const InputDecoration(hintText: 'Phone Number'),
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Please enter your phone number';
          return null;
        },
        keyboardType: TextInputType.phone,
        controller: phoneController,
      );
    _fieldValueGetterMap[CreateUserRequestKeys.phone] = () => phoneController.value.text;
    return field;
  }

  Widget makeEmailField() {
    final TextEditingController emailController = TextEditingController();
    var field = TextFormField(
        controller: emailController,
        decoration: const InputDecoration(hintText: 'Email Address'),
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Please enter your email address';
          return null;
        },
      );
    _fieldValueGetterMap[CreateUserRequestKeys.email] = () => emailController.value.text;
    return field;
  }

  Widget makeUsernameField() {
    final TextEditingController usernameController = TextEditingController();
    var field = TextFormField(
        decoration: const InputDecoration(hintText: 'Username'),
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Please enter your username';
          return null;
        },
        controller: usernameController,
      );
    _fieldValueGetterMap[CreateUserRequestKeys.username] = () => usernameController.value.text;
    return field;
  }

  Widget makePasswordField() {
    final TextEditingController passwordController = TextEditingController();
    var field = TextFormField(
        decoration: const InputDecoration(hintText: 'Password'),
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Please enter your password';
          return null;
        },
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        controller: passwordController,
      );
    _fieldValueGetterMap[CreateUserRequestKeys.password] = () => passwordController.value.text;
    return field;
  }

  List<Widget> _makeTeacherFields(Iterable<String>? existingOccupations) {
    
    return [
      LayoutBuilder(
        builder: (context, constraints) => Autocomplete<String>(
          fieldViewBuilder: (context, occupationController, focusNode, onFieldSubmitted) {
            
            return TextFormField(
            decoration: const InputDecoration(hintText: 'Occupation'),
            validator: (String? value) {
              if (value == null || value.isEmpty) return 'Please enter the occupation';
              return null;
            },
            controller: occupationController,
            focusNode: focusNode,
            onFieldSubmitted: (_) => onFieldSubmitted(),
          );
          },
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.black26,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
              ),
              child: SizedBox(
                height: 52.0 * options.length,
                width: constraints.biggest.width,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  shrinkWrap: false,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(option),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          optionsBuilder: (TextEditingValue textEditingValue) {
            return existingOccupations!
                .where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                .map((option) => option.toTitleCase());
          },
        ),
      )
    ];
  }

  Widget _makeSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ElevatedButton(
        onPressed: () async => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Confirmation"),
              content: const Text("Confirm creating user?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Confirm"),
                  onPressed: onSubmitConfirmed,
                ),
              ],
            ),
          ),
        child: const Text('Create'),
      ),
    );
  }
  
  Future<void> onSubmitConfirmed() async {
    bool formValid = _formKey.currentState?.validate() ?? false;
    // if (!formValid) return;
      
    Map<CreateUserRequestKeys, String> fieldValueMap = _fieldValueGetterMap.map((key, value) => MapEntry<CreateUserRequestKeys, String>(key, value()));
    var res = await CreateUserService().create<T>(fieldValueMap);
    var successful = res.statusCode == 200;
    if (successful) onSuccessfulCreated();
    else onFailedToCreate(res);
  }
  
  void onSuccessfulCreated() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User Created!'))
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
    // TODO goto new user detail page
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
}
