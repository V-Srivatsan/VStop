import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter_litert/flutter_litert.dart';

const _CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

class CaptchaDecoder {

  static Interpreter? _interpreter;

  static Future<void> init() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset("assets/lite.tflite");
  }

  static Future<String> decode(Uint8List bytes) async {
    // 3. Resize to match your custom CNN dimension expectations exactly (40x200)
    img.Image resizedImg = img.copyResize(img.decodeImage(bytes)!, width: 200, height: 40);

    // 4. Pre-allocate the nested 4D array shape safely: [1, 40, 200, 3]
    // This maps directly to the network's input gate without triggering SIGFAULTs
    var inputStructure = List.generate(1, (_) => List.generate(
      40,
      (y) => List.generate(200, (x) {
        final pixel = resizedImg.getPixel(x, y);
        // Normalize raw bytes [0, 255] down to float32 bounds [0.0, 1.0]
        return [
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0,
        ];
      }),
    ));

    // 5. Pre-allocate the multidimensional output structure: [1, 6, 36]
    var outputStructure = List.generate(1, (_) => List.generate(6, (_) => List<double>.filled(36, 0.0)));

    // 6. Execute the hardware-accelerated inference graph
    _interpreter!.run(inputStructure, outputStructure);

    // 7. Parse the multi-head target predictions out of the batch block
    String predictedText = "";
    var captchaMatrix = outputStructure[0]; // Matrix dimensions: [6, 36]

    for (int position = 0; position < 6; position++) {
      int maxIdx = 0;
      double maxScore = -1.0;

      // Perform an ArgMax search across the 36 classes for this position
      for (int classIdx = 0; classIdx < 36; classIdx++) {
        double confidence = captchaMatrix[position][classIdx];
        if (confidence > maxScore) {
          maxScore = confidence;
          maxIdx = classIdx;
        }
      }
      predictedText += _CHARS[maxIdx];
    }

    return predictedText;
  }

  static void close() { _interpreter!.close(); _interpreter = null; }

}