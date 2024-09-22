import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/presentation_settings_form.dart';
import 'package:notifier/updater.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await initGetIt();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(400, 220);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Notifier";
    win.show();
  });
   windowManager.waitUntilReadyToShow().then((_) async{
      await windowManager.setAsFrameless();
  });
}

String getTrayImagePath(String imageName) {
  return Platform.isWindows ? 'assets/$imageName.ico' : 'assets/$imageName.png';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppWindow _appWindow = AppWindow();
  final Menu _menuMain = Menu();

  @override
  void initState() {
    super.initState();
    initSystemTray();
    updater.init();
  }

  @override
  void dispose() {
    super.dispose();
    updater.dispose();
  }

  final Updater updater = Updater();

  late final SystemTray _systemTray = updater.systemTray;

  Future<void> initSystemTray() async {
    await updater.initSystemTray();

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? _appWindow.show() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _appWindow.show();
      }
    });

    await _menuMain.buildFrom(
      [
        MenuItemLabel(
            label: 'Exit', onClicked: (menuItem) => _appWindow.close()),
      ],
    );

    _systemTray.setContextMenu(_menuMain);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: WindowBorder(
          color: const Color(0xFF805306),
          width: 1,
          child: const Column(
            children: [
              TitleBar(),
              // ContentBody(
              //   systemTray: _systemTray,
              //   menu: _menuMain,
              // ),
              SettingsForm(),
            ],
          ),
        ),
      ),
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
              stops: [0.0, 1.0]),
        ),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                  child: const WindowTitle(
                      icon: Icon(Icons.info), title: Text('Notifier'))),
            ),
            const WindowButtons()
          ],
        ),
      ),
    );
  }
}

class WindowTitle extends StatelessWidget {
  final Widget? icon;
  final Widget title;

  const WindowTitle({
    super.key,
    this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            if (icon != null) icon!,
            if (icon != null)
              const SizedBox(
                width: 5,
              ),
            title
          ],
        ),
      );
}

// class ContentBody extends StatelessWidget {
//   final SystemTray systemTray;
//   final Menu menu;

//   const ContentBody({
//     super.key,
//     required this.systemTray,
//     required this.menu,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         color: const Color(0xFFFFFFFF),
//         child: ListView(
//           padding: const EdgeInsets.symmetric(vertical: 4.0),
//           children: [
//             Card(
//               elevation: 2.0,
//               margin: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 8.0,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'systemTray.initSystemTray',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Text(
//                       'Create system tray.',
//                     ),
//                     const SizedBox(
//                       height: 12.0,
//                     ),
//                     ElevatedButton(
//                       child: const Text("initSystemTray"),
//                       onPressed: () async {
//                         if (await systemTray.initSystemTray(
//                             iconPath: getTrayImagePath('app_icon'))) {
//                           systemTray.setTitle("new system tray");
//                           systemTray.setToolTip(
//                               "How to use system tray with Flutter");
//                           systemTray.setContextMenu(menu);
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Card(
//               elevation: 2.0,
//               margin: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 8.0,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'systemTray.destroy',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Text(
//                       'Destroy system tray.',
//                     ),
//                     const SizedBox(
//                       height: 12.0,
//                     ),
//                     ElevatedButton(
//                       child: const Text("destroy"),
//                       onPressed: () async {
//                         await systemTray.destroy();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //MinimizeWindowButton(colors: buttonColors),
        //MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () {
            // showDialog<void>(
            //   context: context,
            //   barrierDismissible: false,
            //   builder: (BuildContext context) {
            //     return AlertDialog(
            //       title: const Text('Exit Program?'),
            //       content: const Text(
            //           ('The window will be hidden, to exit the program you can use the system menu.')),
            //       actions: <Widget>[
            //         TextButton(
            //           child: const Text('OK'),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            appWindow.hide();
          },
          //   ),
          // ],
        )
        //   },
        // );
        // },
        // ),
      ],
    );
  }
}
