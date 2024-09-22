import 'package:process_run/shell.dart';

main() async {
  var shell = Shell(commentVerbose: true);
  await shell.run('''
    # Buildin Windows MSIX installer4
    dart run msix:create

    #See also https://www.youtube.com/watch?v=QKhr7a783wA
  ''');

}
