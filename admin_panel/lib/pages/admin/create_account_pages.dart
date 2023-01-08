import 'package:admin_panel/entities/settings_entities.dart';
import 'package:admin_panel/pages/admin/create_account_widgets/gender_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';
import 'package:flutter_application_1/services/create_user_service.dart';
import 'package:flutter_application_1/services/fetch_occupations_service.dart';
import 'package:http/http.dart' as http;

import '../../services/check_availability_service.dart';
import '../../services/fetch_password_requirement_service.dart';
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
            List<Widget> formFields = _makeCommonFields();
            if (T == Teacher) formFields.addAll(_makeTeacherFields(snapshot.data));
            formFields.add(_makeSubmitButton());

            return !snapshot.hasData
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(children: formFields),
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
        if (value == null || value.isEmpty) return 'Please enter the full name';
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
        if (value == null || value.isEmpty) return 'Please enter a phone number';
        if (value.length != 8) return 'Please enter an 8-digit HK phone number';
      },
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: phoneController,
    );
    _fieldValueGetterMap[CreateUserRequestKeys.phone] = () => phoneController.value.text;
    return field;
  }

  Future<void> _checkAvailabilityAndTellResult(
          {required Future<bool> Function(String) checkIsAvailable,
          required String target,
          required String okText,
          required String notOkText}) async =>
      checkIsAvailable(target).then((isAvailable) => isAvailable
          ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
              children: [Expanded(child: Text(okText)), const Icon(Icons.thumb_up, color: Colors.white)],
            )))
          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
              Expanded(child: Text(notOkText)),
              const Icon(
                Icons.thumb_down,
                color: Colors.white,
              )
            ]))));

  Widget makeEmailField() {
    final TextEditingController emailController = TextEditingController();
    String getEmail() => emailController.value.text;

    _fieldValueGetterMap[CreateUserRequestKeys.email] = () => emailController.value.text;
    return Row(
      children: [
        Expanded(
            child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: emailController,
          decoration: const InputDecoration(hintText: 'Email Address'),
          validator: (String? email) {
            if (email == null || email.isEmpty) return 'Please enter an email address';
            RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
            return !emailRegex.hasMatch(email) ? 'Please enter a valid email address' : null;
          },
        )),
        ElevatedButton(
          onPressed: () => _checkAvailabilityAndTellResult(
              checkIsAvailable: CheckEmailAvailabilityService().checkIsAvailable,
              target: getEmail(),
              okText: 'Email can be used',
              notOkText: 'Email is used by another user'),
          child: const Tooltip(message: 'Check Username Availability', child: Text('Check')),
        )
      ],
    );
  }

  Widget makeUsernameField() {
    final TextEditingController usernameController = TextEditingController();
    String getUsername() => usernameController.value.text;
    _fieldValueGetterMap[CreateUserRequestKeys.username] = getUsername;
    return Row(
      children: [
        Expanded(
            child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(hintText: 'Username'),
          validator: (String? username) {
            if (username == null || username.isEmpty) return 'Please enter a username';
            return username.length < 3 ? 'Username must have at least 3 characters' : null;
          },
          controller: usernameController,
        )),
        ElevatedButton(
          onPressed: () => _checkAvailabilityAndTellResult(
              checkIsAvailable: CheckUsernameAvailabilityService().checkIsAvailable,
              target: getUsername(),
              okText: 'This username is available',
              notOkText: 'This username is used by another user'),
          child: const Text('Check'),
        )
      ],
    );
  }

  Widget makePasswordField() {
    final TextEditingController passwordController = TextEditingController();
    _fieldValueGetterMap[CreateUserRequestKeys.password] = () => passwordController.value.text;
    return FutureBuilder(
      future: FetchPasswordRequirementService().fetch(),
      builder: (context, AsyncSnapshot<PasswordRequirement> snapshot) => !snapshot.hasData
          ? const CircularProgressIndicator()
          : TextFormField(
              decoration: const InputDecoration(hintText: 'Password', errorMaxLines: 2),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? password) {
                var requirement = snapshot.data!;
                return (password == null || password.isEmpty)
                    ? 'Please enter a password'
                    : !requirement.pattern.hasMatch(password)
                        ? 'Password must satisfy the following requirements: ${requirement.patternDescription}'
                        : null;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: passwordController,
            ),
    );
  }

  List<Widget> _makeTeacherFields(Iterable<String>? existingOccupations) {
    return [
      LayoutBuilder(
        builder: (context, constraints) => Autocomplete<String>(
          fieldViewBuilder: (context, occupationController, focusNode, onFieldSubmitted) {
            return TextFormField(
              decoration: const InputDecoration(hintText: 'Occupation'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
    return Center(
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(150, 60)),
        child: const Text('Submit', style: TextStyle(fontSize: 23)),
      ),
    );
  }

  void onSubmit() async {
    bool formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    showDialog(
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
            onPressed: onSubmitConfirmed,
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> onSubmitConfirmed() async {
    Map<CreateUserRequestKeys, String> fieldValueMap =
        _fieldValueGetterMap.map((key, value) => MapEntry<CreateUserRequestKeys, String>(key, value()));
    var res = await CreateUserService().create<T>(fieldValueMap);
    var successful = res.statusCode == 200;
    if (successful)
      onSuccessfulCreated();
    else
      onFailedToCreate(res);
  }

  void onSuccessfulCreated() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Created!')));
    Navigator.of(context).popUntil((route) => route.isFirst);
    // TODO goto new user detail page
  }

  void onFailedToCreate(http.Response res) {
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
