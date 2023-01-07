import 'package:flutter/material.dart';

class BirthdayField extends StatefulWidget {
  final void Function(DateTime birthday) onBirthdateChanged;
  final DateTime defaultSelected;
  
  const BirthdayField({super.key, required this.onBirthdateChanged, required this.defaultSelected});

  @override
  State<StatefulWidget> createState() => _BirthdayField();
}

class _BirthdayField extends State<BirthdayField> {
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.defaultSelected;
  }
  
  @override
  Widget build(BuildContext context) {
    Future<void> selectDate() async {
      final DateTime? picked =
      await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(1900), lastDate: DateTime(DateTime.now().year));
      setState(() => _selectedDate = picked ?? _selectedDate);
    }

    return Row(
      children: <Widget>[
        Text("Birthday: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
        const Spacer(),
        ElevatedButton(
          onPressed: () => selectDate(),
          child: const Text('Select'),
        ),
      ],
    );
  }
}