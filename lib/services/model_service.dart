import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import '../services/image_processor.dart';

class ModelService {
  tfl.Interpreter? _interpreter;

  Future<String> loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset('assets/cow_breed_model.tflite');
      _interpreter!.allocateTensors();
      return "Model loaded successfully!";
    } catch (e) {
      return "Failed to load model: $e";
    }
  }

  Future<String> classifyImage(File image) async {
    if (_interpreter == null) return "Model not loaded";

    try {
      var input = [ImageProcessor.preprocessImage(image)];
      var output = List.filled(2, 0.0).reshape([1, 2]);

      _interpreter!.run(input, output);

      return output[0][0] > output[0][1] ? 'Gir ' : 'Sahiwal ';
    } catch (e) {
      return "Error during classification: $e";
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}