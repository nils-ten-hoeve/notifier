import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/service_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  final SettingsService settingsService = getIt<SettingsService>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            StartTimeInputField(formKey: _formKey),
            // For debuging:
            // SelectableText(getIt<SettingsDatabase>().yamlFilePath),
            // Text(settingsService.settings.workStart.toIso8601String()),
            const SizedBox(height: 30),
            Row(
              children: <Widget>[
                const Expanded(child: SizedBox()),
                const CancelButton(),
                const SizedBox(width: 10),
                ModifyStartTimeButton(formKey: _formKey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

/// TODO escape to hide window https://www.youtube.com/watch?v=WMVoNA5cY9A
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: OutlinedButton(
          child: const Text(
            "Cancel",
          ),
          onPressed: () {
            appWindow.hide();
          },
        ),
      );
}

class ResetButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const ResetButton({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        child: const Text(
          "Reset",
        ),
        onPressed: () {
          formKey.currentState!.reset();
        },
      );
}

class ModifyStartTimeButton extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  const ModifyStartTimeButton({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => onPressed(context),
          child: const Text("Modify start time"),
        ),
      );

  void onPressed(BuildContext context) {
    formKey.currentState!.save();
    var map = formKey.currentState!.value;
    TimeOfDay? startTime = map[StartTimeInputField.startTime];

    if (formKey.currentState!.validate() && startTime != null) {
      var settingsService = getIt<SettingsService>();
      var settings = settingsService.settings;
      var workStart = settings.workStart
          .copyWith(hour: startTime.hour, minute: startTime.minute);
      settingsService.settings = settings.copyWith(workStart: workStart);
      appWindow.hide();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid input')));
    }
  }
}

class StartTimeInputField extends StatefulWidget {
  static const String startTime = 'startTime';
  final GlobalKey<FormBuilderState> formKey;
  const StartTimeInputField({super.key, required this.formKey});

  @override
  State<StartTimeInputField> createState() => _StartTimeInputFieldState();
}

class _StartTimeInputFieldState extends State<StartTimeInputField> {
  String get _startTime {
    var workStart = getIt<SettingsService>().settings.workStart;
    return '${asTwoDigits(workStart.hour)}:${asTwoDigits(workStart.minute)}';
  }

  String asTwoDigits(int num) => num.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    var startTime = _startTime;
    final timeFormatter = MaskTextInputFormatter(
      mask: "##:##",
      initialText: startTime,
    );
    return FormBuilderTextField(
      name: StartTimeInputField.startTime,
      autofocus: true,
      initialValue: startTime,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      decoration: InputDecoration(
        labelText: 'Start time',
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: StartTimeInputFieldButtons(
          formKey: widget.formKey,
        ),
      ),
      inputFormatters: <TextInputFormatter>[timeFormatter],
      validator: timeValidator,
      valueTransformer: valueTransformer,
    );
  }

  String? timeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final components = value.split(":");
    if (components.length == 2) {
      final hours = int.tryParse(components[0]);
      final minutes = int.tryParse(components[1]);
      if (hours != null && minutes != null && hours <= 23 && minutes <= 59) {
        return null;
      }
    }
    return "invalid time";
  }

  TimeOfDay? valueTransformer(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final components = value.split(":");
    if (components.length == 2) {
      try {
        final hour = int.tryParse(components[0]);
        final minute = int.tryParse(components[1]);
        return TimeOfDay(hour: hour!, minute: minute!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class StartTimeInputFieldButtons extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;

  const StartTimeInputFieldButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KronosButton(),
            const SizedBox(width: 10),
            ResetButton(formKey: formKey)
          ],
        ),
      );
}

class KronosButton extends StatelessWidget {
  const KronosButton({super.key});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: openKronosInBrowser,
        child: const Text("Kronos"),
      );

  Future<void> openKronosInBrowser() async {
    var url = Uri.parse(
        "https://secure.workforceready.eu/ta/6175861.home?rnd=KBQ&showAdmin=1&Ext=login&sft=EFJIGXIERR");
    await launchUrl(url);
  }
}

class PropertyRow extends StatelessWidget {
  final String propertyName;
  final Widget field;

  static const double height = 50;

  const PropertyRow({
    super.key,
    required this.propertyName,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(propertyName),
        ),
        field,
      ],
    );
  }
}
