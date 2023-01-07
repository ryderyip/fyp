import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/user_entities.dart';

class GenderFieldGroup extends StatefulWidget {
  final ValueChanged<Gender> onGenderChanged;
  final Gender defaultSelected;
  
  const GenderFieldGroup({super.key, required this.onGenderChanged, required this.defaultSelected});

  @override
  State<StatefulWidget> createState() => _GenderFieldGroup();
}

class _GenderFieldGroup extends State<GenderFieldGroup> {
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.defaultSelected;
  }

  onChange(Gender? gender) => setState(() {
    _selectedGender = gender;
    widget.onGenderChanged(gender!);
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<Gender>(
          title: const Text('Male'),
          value: Gender.male,
          groupValue: _selectedGender,
          onChanged: onChange,
          selected: _selectedGender == Gender.male,
        ),
        RadioListTile<Gender>(
          title: const Text('Female'),
          value: Gender.female,
          groupValue: _selectedGender,
          onChanged: onChange,
          selected: _selectedGender == Gender.female,
        ),
      ],
    );
  }

}
