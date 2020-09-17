import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class ViewIO {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/pictures.json');
  }

  static Future<bool> fileExists() async {
    File file = await _localFile;
    if (await file.exists()) {
      
    }
  }

  static Future<void> write(String key, List<String> text, int width, int height) async {
    final file = await _localFile;
    Map<String, dynamic> content = {key: [text, width, height]};
    Map<String, dynamic> jsonFileContent = json.decode(file.readAsStringSync());
    jsonFileContent.addAll(content);
    print(jsonFileContent);
    file.writeAsStringSync(json.encode(jsonFileContent));
  }

  static Future<Map<String, dynamic>> read() async {
    try {
      final file = await _localFile;
      return json.decode(file.readAsStringSync());
    } catch (e) {
      // If encountering an error, return empty
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
    if (await isEmpty()) {
      //
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
