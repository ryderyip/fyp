import 'dart:async';

import 'package:admin_panel/entities/settings_entities.dart';
import 'package:admin_panel/pages/admin/create_account_widgets/gender_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';
import 'package:flutter_application_1/services/fetch_occupations_service.dart';

import '../../services/check_availability_service.dart';
import '../../services/fetch_password_requirement_service.dart';
import 'create_account_widgets/birthday_field.dart';
import 'create_account_widgets/check_availibility_buttons.dart';

class UserCreateUpdateForm<T extends User> extends StatefulWidget {
  final UserType userType;
  
  final StreamController<T> _userCreatedOrUpdatedController = StreamController<T>.broadcast();

  final String confirmationMessage;
  Stream<T> get formSubmitted => _userCreatedOrUpdatedController.stream;
  final T? userToUpdate;

  UserCreateUpdateForm({super.key, required this.userType, this.userToUpdate, required this.confirmationMessage});

  @override
  State<StatefulWidget> createState() => _UserCreateUpdateFormState();
}

class _UserCreateUpdateFormState extends State<UserCreateUpdateForm> {
  late User _userTemplate;
  final List<void Function()> _templateFieldSetters = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.userToUpdate != null) {
      _userTemplate = widget.userToUpdate!;
    } else {
      _userTemplate = widget.userType == UserType.student
        ? Student.getTemplate()
        : widget.userType == UserType.teacher
        ? Teacher.getTemplate()
        : Admin.getTemplate();
      _userTemplate.commonInformation.dateOfBirth = DateTime(DateTime.now().year - 18);
    }
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Iterable<String>>(
          future: FetchOccupationService().fetchOccupations(),
          builder: (context, snapshot) {
            List<Widget> formFields = _makeCommonFields();
            if (widget.userType == UserType.teacher) formFields.addAll(_makeTeacherFields(snapshot.data));
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
          });

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
    String initial = _userTemplate.commonInformation.name;
    nameController.text = initial;
    _templateFieldSetters.add(() => _userTemplate.commonInformation.name = nameController.value.text);
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
    Gender initialValue = _userTemplate.commonInformation.gender;
    Gender selected = initialValue;
    void selectedGenderListener(Gender gender) => selected = gender;
    _templateFieldSetters.add(() => _userTemplate.commonInformation.gender = selected);
    return GenderFieldGroup(defaultSelected: selected, onGenderChanged: selectedGenderListener);
  }

  Widget makeBirthdayField() {
    DateTime initialValue = _userTemplate.commonInformation.dateOfBirth;
    DateTime selected = initialValue;
    void selectedBirthdayChangedListener(DateTime birthday) => selected = birthday;
    _templateFieldSetters.add(() => _userTemplate.commonInformation.dateOfBirth = selected);
    return BirthdayField(defaultSelected: selected, onBirthdateChanged: selectedBirthdayChangedListener);
  }

  Widget makePhoneField() {
    final TextEditingController phoneController = TextEditingController();
    String initial = _userTemplate.commonInformation.phone;
    phoneController.text = initial;
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
    _templateFieldSetters.add(() => _userTemplate.commonInformation.phone = phoneController.value.text);
    return field;
  }

  

  Widget makeEmailField() {
    final TextEditingController emailController = TextEditingController();
    String getEmail() => emailController.value.text;
    String initial = _userTemplate.commonInformation.email;
    emailController.text = initial;
    _templateFieldSetters.add(() => _userTemplate.commonInformation.email = emailController.value.text);

    var checkButton = CheckAvailibilityButton(enabledInitial: false, 
      realValueRetriever: getEmail, availabilityCheckingService: CheckEmailAvailabilityService(), valueName: 'Email',);
    
    return Row(
      children: [
        Expanded(
            child: TextFormField(
              onChanged: (value) => checkButton.enabled = value != initial,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Email Address'),
              validator: (String? email) {
                if (email == null || email.isEmpty) return 'Please enter an email address';
                RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                return !emailRegex.hasMatch(email) ? 'Please enter a valid email address' : null;
              },
            )),
        checkButton,
      ],
    );
  }

  Widget makeUsernameField() {
    final TextEditingController usernameController = TextEditingController();
    String getUsername() => usernameController.value.text;
    String initial = _userTemplate.commonInformation.username ?? '';
    usernameController.text = initial;
    _templateFieldSetters.add(() => _userTemplate.commonInformation.username = getUsername());

    var checkButton = CheckAvailibilityButton(valueName: 'Username',
      enabledInitial: false,
      realValueRetriever: getUsername, availabilityCheckingService: CheckUsernameAvailabilityService(),);

    return Row(
      children: [
        Expanded(
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(hintText: 'Username'),
              onChanged: (value) => checkButton.enabled = value.isNotEmpty && (value != initial),
              validator: (String? username) {
                if (username == null || username.isEmpty) return null;
                return username.length < 3 ? 'Username must have at least 3 characters' : null;
              },
              controller: usernameController,
            )),
        checkButton
      ],
    );
  }

  Widget makePasswordField() {
    final TextEditingController passwordController = TextEditingController();
    String initialValue = _userTemplate.commonInformation.password;
    passwordController.text = initialValue;
    
    _templateFieldSetters.add(() => _userTemplate.commonInformation.password = passwordController.value.text);
    
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
            _templateFieldSetters.add(() => (_userTemplate as Teacher).occupation = occupationController.value.text);
            String initial = (_userTemplate as Teacher).occupation;
            occupationController.text = initial;
            
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

    Future<void> onSubmitConfirmed() async {
      void collectFieldValues() {
        for (var templateFieldSetter in _templateFieldSetters) {
          templateFieldSetter();
        }
      }
      collectFieldValues();

      Navigator.of(context).pop();
      widget._userCreatedOrUpdatedController.add(_userTemplate);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(widget.confirmationMessage),
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
}
