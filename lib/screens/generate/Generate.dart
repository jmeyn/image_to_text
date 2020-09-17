import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_to_text/IO/ViewIO.dart';
import 'package:image_to_text/screens/create/DetailScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../IO/AlphabetIO.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class Generate extends StatefulWidget {
  final File image;
  final int width;
  final int height;
  final String alphabet;

  const Generate({
    Key key,
    @required this.image,
    @required this.width,
    @required this.height,
    @required this.alphabet,
  }) : super(key: key);

  @override
  _GenerateState createState() => _GenerateState();
}

class _GenerateState extends State<Generate> {
  String alphabet;
  List<String> textImageLines;
  String textImage;
  File resizeImageFile;
  final nameController = TextEditingController();

  Future<String> getContent() async {
    Map<String, dynamic> fileContent = await AlphabetIO.read();
    alphabet = fileContent[widget.alphabet];

    img.Image resizeImage =
        await AlterPhoto.resizeImage(widget.image, widget.width, widget.height);

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    resizeImageFile = File(path);
    resizeImageFile.writeAsBytesSync(img.encodePng(resizeImage));
    textImageLines = await AlterPhoto.changeImage(resizeImage, alphabet);

    textImage = textImageLines[0];
    for (int i = 1; i < textImageLines.length; i += 1) {
      textImage = textImage + "\n" + textImageLines[i];
    }

    return Future.value("Fetched all values.");
  }

  @override
  void initState() {
    super.initState();
    getContent();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getContent(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                backgroundColor: Color.fromARGB(255, 43, 45, 66),
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 43, 45, 66),
                  title: Text("Image Generating..."),
                ),
                body: Center(
                    child: Dialog(
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new CircularProgressIndicator(),
                      new Text("Loading"),
                    ],
                  ),
                )));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              return Scaffold(
                  resizeToAvoidBottomPadding: false,
                  backgroundColor: Color.fromARGB(255, 43, 45, 66),
                  appBar: AppBar(
                    backgroundColor: Color.fromARGB(255, 43, 45, 66),
                    title: Text("Generated Image!"),
                  ),
                  body: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: textImageLines == null
                                    ? 0
                                    : textImageLines.length,
                                itemBuilder: (context, index) {
                                  return FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(textImageLines[index],
                                          style: TextStyle(
                                              fontFamily: 'Consolas',
                                              color: Color.fromARGB(
                                                  255, 237, 242, 244))));
                                },
                              ),
                            )),
                        Container(
                            padding:
                                const EdgeInsets.fromLTRB(32.0, 0, 32.0, 0),
                            child: RaisedButton(
                                child: Text("Save Image!",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Color.fromARGB(
                                            255, 237, 242, 244))),
                                color: Colors.green,
                                onPressed: () {
                                  createNewPhoto(context);
                                }))
                      ]));
            }
          }
        });
  }

  void _createPhoto(String name) {
    ViewIO.write(name, textImageLines, widget.width, widget.height);
  }

  void createNewPhoto(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      onPressed: () {
        Navigator.of(context).pop();
        _createPhoto(nameController.text);
      },
    );

    AlertDialog create = AlertDialog(
      backgroundColor: Color.fromARGB(255, 43, 45, 66),
      title: Text("Create TextPhoto",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.95,
          child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Text('What is the name of your new photo?',
                    style:
                        TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: Color.fromARGB(255, 141, 153, 174),
                  ),
                  decoration: InputDecoration(
                      labelText: 'Name: ',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 141, 153, 174)),
                      alignLabelWithHint: true),
                ),
              ])),
      actions: [
        cancelButton,
        createButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return create;
      },
    );
  }
}

class AlterPhoto {
  static Future<img.Image> resizeImage(
      File imageFile, int height, int width) async {
    img.Image baseSizeImage = img.decodeImage(imageFile.readAsBytesSync());
    img.Image resizeImage =
        img.copyResize(baseSizeImage, height: height, width: width);
    img.pixelate(resizeImage, 2);
    return resizeImage;
  }

  static Future<List<String>> changeImage(
      img.Image image, String alphabet) async {
    int imgWidth = image.width;
    int imgHeight = image.height;
    List<int> peaks = imagePeaks(image);
    int pixelMax = peaks[0];
    int pixelMin = peaks[1];
    List<String> output = [];

    for (int widthPixel = 0; widthPixel < imgWidth; widthPixel += 1) {
      String nextLine = "";
      for (int heightPixel = 0; heightPixel < imgHeight; heightPixel += 1) {
        int pixel32 = image.getPixelSafe(widthPixel, heightPixel);
        int hex = abgrToArgb(pixel32);
        nextLine = nextLine + getChar(hex, alphabet, pixelMax, pixelMin);
      }
      output.add(nextLine);
    }
    return output;
  }

  static List<int> imagePeaks(img.Image image) {
    int imgWidth = image.width;
    int imgHeight = image.height;

    int max = image.getPixelSafe(0, 0);
    int min = max;

    for (int widthPixel = 0; widthPixel < imgWidth; widthPixel += 1) {
      for (int heightPixel = 0; heightPixel < imgHeight; heightPixel += 1) {
        int pixel32 = image.getPixelSafe(widthPixel, heightPixel);
        int hex = abgrToArgb(pixel32);
        max = hex > max ? hex : max;
        min = min > hex ? hex : min;
      }
    }
    return [min, max];
  }

  /// Converts #AABBGGRR to #AARRGGBB, as ImageLib uses KML color format.
  /// Credit to roipeker on github gist
  static int abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  /// Returns String character best representing the current hex color.
  static String getChar(int hex, String alphabet, int max, int min) {
    int range = max - min;
    double scale = alphabet.length / range;
    return alphabet[(((hex - min + 1) * scale)).toInt() % alphabet.length];
  }
}
