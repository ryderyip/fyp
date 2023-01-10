import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/extensions/string_extensions.dart';

import '../../../services/check_availability_service.dart';

class CheckAvailibilityButton extends StatefulWidget {
  final StreamController<bool> setEnableController = StreamController.broadcast();

  final String valueName;
  Stream get setEnabled => setEnableController.stream;
  final bool enabledInitial;
  final String Function() realValueRetriever;
  final AvailabilityCheckingService availabilityCheckingService;
  
  set enabled(bool enabled) {
    setEnableController.add(enabled);
  }
  
  CheckAvailibilityButton({super.key, required this.enabledInitial, required this.realValueRetriever, required this.availabilityCheckingService, required this.valueName});
  
  @override
  State<StatefulWidget> createState() => _CheckAvailibilityButton();
}

class _CheckAvailibilityButton extends State<CheckAvailibilityButton> {
  late bool _enabled;
  
  @override
  void initState() {
    super.initState();
    _enabled = widget.enabledInitial;
    widget.setEnabled.listen((enabled) => setState(() => _enabled = enabled));
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith(
              (states) => _enabled ?
              Colors.white : Colors.grey,
        ),
      ),
      onPressed: () => _enabled ? _checkAvailabilityAndTellResult(
          checkIsAvailable: widget.availabilityCheckingService.checkIsAvailable,
          target: widget.realValueRetriever(),
          okText: 'This ${widget.valueName.toLowerCase()} can be used',
          notOkText: 'This ${widget.valueName.toLowerCase()} is used by another user')
      : null,
      child: Tooltip(message: 'Check ${widget.valueName.toTitleCase()} Availability', child: Text('Check')),
    );
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
}

