import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class AlphabetIO {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/alphabet.json');
  }

  static Future<void> write(String key, String value) async {
    final file = await _localFile;
    Map<String, dynamic> content = {key: value};
    Map<String, dynamic> jsonFileContent = json.decode(file.readAsStringSync());
    jsonFileContent.addAll(content);
    file.writeAsStringSync(json.encode(jsonFileContent));
  }

  static Future<Map<String, dynamic>> read() async {
    try {
      final file = await _localFile;
      // Read the file
      //Map<String, dynamic> jsonFileContent = json.decode(file.readAsStringSync());
      //print("Read value: " + jsonFileContent.toString());

      return json.decode(file.readAsStringSync());
    } catch (e) {
      // If encountering an error, return 0
      return Future.value();
    }
  }

  static Future<bool> remove(String key) async {
    try {
      final file = await _localFile;
      Map<String, dynamic> jsonFileContent =
          json.decode(file.readAsStringSync());
      jsonFileContent.remove(key);
      file.writeAsStringSync(json.encode(jsonFileContent));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> basicSetup() async {
    if (await AlphabetIO.isEmpty()) {
      write(
          "ASCII 1",
          "\"#\$%&\'()*+,-./0123456789:;<=>?" +
              "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
      write("ASCII 2",".,-`\'\"+^_:;!<>~aoegmnvwzAOEGMNVWZ&%\$#0@");
    }
  }

  static Future<void> clearJSON() async {
    final file = await _localFile;
    file.writeAsStringSync("");
  }

  static Future<bool> isEmpty() async {
    final file = await _localFile;
    Map<String, dynamic> jsonFileContent = json.decode(file.readAsStringSync());
    return jsonFileContent.isEmpty;
  }
}
