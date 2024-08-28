// NO LONGER USED

// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:notifier/status.dart';

// void main(List<String> args) {
//   generateTimeIconFiles();
//   exit(0);
// }

// void generateTimeIconFiles() {
//    for (var status in remainingIcons) {
//     var image = createImage(status);
//     writeImage(status, image);
//   }
// }

// final remainingIcons = <WorkTimeStatus>[
//     for (int m = 0; m <= WorkTimeStatus.defaultWorkDuration.inMinutes; m++)
//       WorkTimeStatus.remaining(Duration(minutes: m))
//   ];

// img.Image createImage(WorkTimeStatus status) {
//   final image = img.Image(width: 32, height: 32);

//   var transparant = img.ColorRgba8(0, 0, 0, 0);
//   img.fill(image, color: transparant);

//   // Draw text on the image
//   var text = status.iconText!;
// var font = img.arial14;
//   var color = status.iconColor;
//   img.drawString(image, text, font: font, color: color);

//   return image;
// }

// void writeImage(WorkTimeStatus status, img.Image image) {
//   final outputFile = File(status.iconPath);
//   outputFile.writeAsBytesSync(img.encodePng(image));
// }
