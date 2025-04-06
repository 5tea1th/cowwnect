import 'dart:io';
import 'package:image/image.dart' as img;

class ImageProcessor {
  static List<List<List<double>>> preprocessImage(File image) {
    final rawImage = File(image.path).readAsBytesSync();
    img.Image? imageBytes = img.decodeImage(rawImage);

    if (imageBytes == null) {
      return List.generate(224, (_) => List.generate(224, (_) => [0.0, 0.0, 0.0]));
    }

    img.Image resizedImage = img.copyResize(imageBytes, width: 224, height: 224);

    return List.generate(224, (y) {
      return List.generate(224, (x) {
        final pixel = resizedImage.getPixel(x, y);
        return [
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0
        ];
      });
    });
  }
}