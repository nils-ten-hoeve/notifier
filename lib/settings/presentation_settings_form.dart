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
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.alt,
          LogicalKeyboardKey.enter,
        ): const OpenKronosInBrowserIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): SubmitFormIntent(_formKey),
        LogicalKeySet(LogicalKeyboardKey.escape): const CancelFormIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            IncreaseOneMinuteIntent(_formKey),
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            DecreaseOneMinuteIntent(_formKey),
      },
      child: Actions(
        actions: {
          OpenKronosInBrowserIntent: OpenKronosInBrowserAction(),
          SubmitFormIntent: SubmitFormAction(),
          CancelFormIntent: CancelFormAction(),
          IncreaseOneMinuteIntent: IncreaseOneMinuteAction(),
          DecreaseOneMinuteIntent: DecreaseOneMinuteAction(),
        },
        child: FormBuilder(
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
        ),
      ),
    );
  }
}

class DecreaseOneMinuteIntent extends Intent {
  final GlobalKey<FormBuilderState> formKey;
  const DecreaseOneMinuteIntent(this.formKey);
}

class DecreaseOneMinuteAction extends Action<DecreaseOneMinuteIntent> {
  @override
  Object? invoke(DecreaseOneMinuteIntent intent) {
    var formKey = intent.formKey;
    var startTimeString =
        formKey.currentState?.fields[StartTimeInputField.startTime]?.value;
    if (startTimeString != null) {
      var startTime = stringToTimeOfDay(startTimeString);
      if (startTime != null) {
        var hour = startTime.hour;
        var minute = startTime.minute - 1;
        if (minute < 0) {
          hour--;
          minute = 59;
        }
        var newStartTime = timeToStingWith2Digits(hours: hour, minutes: minute);
        formKey.currentState!.fields[StartTimeInputField.startTime]!
            .didChange(newStartTime);
      }
    }
    return null;
  }
}

class IncreaseOneMinuteIntent extends Intent {
  final GlobalKey<FormBuilderState> formKey;
  const IncreaseOneMinuteIntent(this.formKey);
}

class IncreaseOneMinuteAction extends Action<IncreaseOneMinuteIntent> {
  @override
  Object? invoke(IncreaseOneMinuteIntent intent) {
    var formKey = intent.formKey;
    var startTimeString =
        formKey.currentState?.fields[StartTimeInputField.startTime]?.value;
    if (startTimeString != null) {
      var startTime = stringToTimeOfDay(startTimeString);
      if (startTime != null) {
        var hour = startTime.hour;
        var minute = startTime.minute + 1;
        if (minute > 59) {
          hour++;
          minute = 0;
        }
        var newStartTime = timeToStingWith2Digits(hours: hour, minutes: minute);
        formKey.currentState!.fields[StartTimeInputField.startTime]!
            .didChange(newStartTime);
      }
    }
    return null;
  }
}

class CancelFormIntent extends Intent {
  const CancelFormIntent();
}

class CancelFormAction extends Action<CancelFormIntent> {
  @override
  Object? invoke(CancelFormIntent intent) {
    appWindow.hide();
    return null;
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: Actions.handler<CancelFormIntent>(
            context,
            const CancelFormIntent(),
          ),
          child: const Text("Cancel"),
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

class SubmitFormIntent extends Intent {
  final GlobalKey<FormBuilderState> formKey;
  const SubmitFormIntent(this.formKey);
}

class SubmitFormAction extends Action<SubmitFormIntent> {
  @override
  Object? invoke(SubmitFormIntent intent) {
    var formKey = intent.formKey;
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
    }
    return null;
  }
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
          onPressed: Actions.handler<SubmitFormIntent>(
            context,
            SubmitFormIntent(formKey),
          ),
          child: const Text("Modify start time"),
        ),
      );
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
    return dateTimeToTimeStingWith2Digits(workStart);
  }

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
      valueTransformer: stringToTimeOfDay,
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
}

TimeOfDay? stringToTimeOfDay(String? value) {
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

String dateTimeToTimeStingWith2Digits(DateTime workStart) =>
    timeToStingWith2Digits(hours: workStart.hour, minutes: workStart.minute);

String timeToStingWith2Digits({required int hours, required int minutes}) =>
    '${asTwoDigits(hours)}:${asTwoDigits(minutes)}';

String asTwoDigits(int num) => num.toString().padLeft(2, '0');

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

class OpenKronosInBrowserIntent extends Intent {
  const OpenKronosInBrowserIntent();
}

class OpenKronosInBrowserAction extends Action<OpenKronosInBrowserIntent> {
  @override
  Future<Object?> invoke(OpenKronosInBrowserIntent intent) async {
    var url = Uri.parse(
        "https://secure.workforceready.eu/ta/6175861.home?rnd=KBQ&showAdmin=1&Ext=login&sft=EFJIGXIERR");
    await launchUrl(url);
    return null;
  }
}

class KronosButton extends StatelessWidget {
  const KronosButton({super.key});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: Actions.handler(context, const OpenKronosInBrowserIntent()),
        child: const Text("Kronos"),
      );
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
