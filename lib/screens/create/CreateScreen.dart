import 'dart:ui';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/IO/AlphabetIO.dart';
import 'package:image_to_text/screens/generate/Generate.dart';
import 'DetailScreen.dart';
import 'TakePicture.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  File _imageFile;
  bool _photoSelected = false;
  String alphabet = 'ASCII 1';
  String photoSize = '100%';
  bool _customSize = false;
  Image image;
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  Map<String, dynamic> fileContent;

  Future<String> getContent() async {
    fileContent = await AlphabetIO.read();
    return Future.value("Completed Successfully");
  }

  /// Setup for TakePicture. */
  void _showCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicture(camera: firstCamera)));
    setState(() {
      _imageFile = File(result);
      _photoSelected = true;
    });
  }

  /// Setup for choosing an image from phone. */
  Future<void> _showPhotoLibrary() async {
    File imageFile =
        await Future.value(ImagePicker.pickImage(source: ImageSource.gallery));
    setState(() {
      _imageFile = imageFile;
      _photoSelected = true;
    });
  }

  /// Show menu to choose from gallery or camera. */
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Color.fromARGB(255, 237, 242, 244),
        builder: (context) {
          return Container(
              height: 150,
              child: Column(children: <Widget>[
                ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showCamera();
                    },
                    leading: Icon(Icons.photo_camera,
                        color: Color.fromARGB(255, 43, 45, 66)),
                    title: Text("Take a Picture from Camera",
                        style:
                            TextStyle(color: Color.fromARGB(255, 43, 45, 66)))),
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showPhotoLibrary();
                    },
                    leading: Icon(Icons.photo_library,
                        color: Color.fromARGB(255, 43, 45, 66)),
                    title: Text("Choose a from Photo Library",
                        style:
                            TextStyle(color: Color.fromARGB(255, 43, 45, 66))))
              ]));
        });
  }

  ///Begins Photo Generation Process. */
  Future<void> _generate(BuildContext context) async {
    int imageWidth = 0;
    int imageHeight = 0;

    if (photoSize == "Custom") {
      try {
        if (int.parse(widthController.text) <= 0 ||
            int.parse(heightController.text) <= 0 ||
            int.parse(widthController.text) >= 10000 ||
            int.parse(heightController.text) >= 10000) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text(
                        "Size input is too small or too large (>10,000px)"));
              });
          return;
        }
      } catch (e) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("Size input is not a real number!"));
            });
        return;
      }
      print("Height: " + imageHeight.toString());
      print("Width: " + imageWidth.toString());
      imageWidth = int.parse(widthController.text);
      imageHeight = int.parse(heightController.text);
      print("Adjusted Height: " + imageHeight.toString());
      print("Adjusted Width: " + imageWidth.toString());
    } else {
      var decodedImage =
          await decodeImageFromList(_imageFile.readAsBytesSync());
      imageWidth = decodedImage.width;
      imageHeight = decodedImage.height;

      double scalar = 1.0;
      if (photoSize == "50%") {
        scalar = 0.5;
      } else if (photoSize == "25%") {
        scalar = 0.25;
      } else if (photoSize == "10%") {
        scalar = 0.1;
      } else if (photoSize == "200%") {
        scalar = 2.0;
      }
      print("Height: " + imageHeight.toString());
      print("Width: " + imageWidth.toString());
      imageHeight = (imageHeight * scalar).floor();
      imageWidth = (imageWidth * scalar).floor();
      print("Adjusted Height: " + imageHeight.toString());
      print("Adjusted Width: " + imageWidth.toString());
    }

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Generate(
                  image: _imageFile,
                  height: imageHeight,
                  width: imageWidth,
                  alphabet: alphabet,
                )));
  }

  /// Scaffold shown before selecting/taking picture. */
  Widget _beforePicture(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 43, 45, 66),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 200.0),
                  child: ListTile(
                    title: Text(
                      "Create your own artwork from your pictures!",
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Color.fromARGB(255, 237, 242, 244)),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      "Press the button below and choose a picture " +
                          "that is already on your phone or take one now. " +
                          "Then, go to the next screen to customize it!",
                      style: TextStyle(fontSize: 20.0, color: Colors.black87),
                    ),
                  )),
              ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 75.0),
                  child: RaisedButton(
                    child: Text("Take/Upload Picture",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromARGB(255, 43, 45, 66))),
                    color: Color.fromARGB(255, 141, 153, 174),
                    onPressed: () {
                      _showOptions(context);
                    },
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ));
  }

  /// Scaffold shown after selecting/taking picture*/
  Widget _afterPicture(BuildContext context) {
    List<String> alphabets = [];
    image = Image.file(_imageFile);

    return FutureBuilder<String>(
        future: getContent(), // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                resizeToAvoidBottomPadding: false,
                backgroundColor: Color.fromARGB(255, 43, 45, 66),
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 43, 45, 66),
                  title: Text("Image Selected"),
                ),
                body: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    GestureDetector(
                      child: Hero(
                          tag: "imageSelected",
                          child: Image.file(_imageFile,
                              height: 200, fit: BoxFit.cover)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DetailScreen(image: image)));
                      },
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 0),
                      child: ListView(
                        padding: EdgeInsets.all(8.0),
                        shrinkWrap: true,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              _showOptions(context);
                            },
                            color: Colors.red,
                            child: Text(
                              "Redo Photo",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ListTile(
                              dense: false,
                              title: Text(
                                "Alphabet",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "Choose what set of characters you want your image to transform into.",
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: DropdownButton<String>(
                                icon: Icon(Icons.arrow_downward,
                                    color: Color.fromARGB(255, 237, 242, 244)),
                                iconSize: 24,
                                elevation: 16,
                                value: alphabet,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 141, 153, 174)),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                items: alphabets.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 141, 153, 174))),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    alphabet = newValue;
                                  });
                                },
                              )),
                          ListTile(
                              title: Text(
                                "Photo Size",
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "How big do you want your text art to be relative to the photo's resolution?" +
                                    "Note: larger photo sizes will take longer to process",
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: DropdownButton<String>(
                                value: photoSize,
                                icon: Icon(Icons.arrow_downward,
                                    color: Color.fromARGB(255, 237, 242, 244)),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 141, 153, 174)),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _customSize = (newValue == 'Custom');
                                    photoSize = newValue;
                                  });
                                },
                                items: <String>[
                                  '100%',
                                  '50%',
                                  '25%',
                                  '10%',
                                  '200%',
                                  'Custom'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 141, 153, 174))),
                                  );
                                }).toList(),
                              )),
                          !_customSize
                              ? SizedBox(width: 0, height: 60.0)
                              : Row(children: <Widget>[
                                  Flexible(
                                      child: TextField(
                                    controller: widthController,
                                    decoration: InputDecoration(
                                        labelText: 'Width (in pixels): ',
                                        alignLabelWithHint: true),
                                  )),
                                  SizedBox(width: 10),
                                  Flexible(
                                      child: TextField(
                                    controller: heightController,
                                    decoration: InputDecoration(
                                        labelText: 'Height (in pixels): ',
                                        alignLabelWithHint: true),
                                  )),
                                ]),
                          RaisedButton(
                            onPressed: () {
                              _generate(context);
                            },
                            color: Colors.green,
                            child: Text(
                              "Generate Art!",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              fileContent.forEach((k, v) => alphabets.add(k));
              print(alphabets);
              return Scaffold(
                  resizeToAvoidBottomPadding: false,
                  backgroundColor: Color.fromARGB(255, 43, 45, 66),
                  appBar: AppBar(
                    backgroundColor: Color.fromARGB(255, 43, 45, 66),
                    title: Text("Image Selected"),
                  ),
                  body: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      GestureDetector(
                        child: Hero(
                            tag: "imageSelected",
                            child: Image.file(_imageFile,
                                height: 200, fit: BoxFit.cover)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(image: image)));
                        },
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 0),
                        child: ListView(
                          padding: EdgeInsets.all(8.0),
                          shrinkWrap: true,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                _showOptions(context);
                              },
                              color: Colors.red,
                              child: Text(
                                "Redo Photo",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ListTile(
                                dense: false,
                                title: Text(
                                  "Alphabet",
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "Choose what set of characters you want your image to transform into.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                trailing: DropdownButton<String>(
                                  icon: Icon(Icons.arrow_downward,
                                      color:
                                          Color.fromARGB(255, 237, 242, 244)),
                                  iconSize: 24,
                                  elevation: 16,
                                  value: alphabet,
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 141, 153, 174)),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  items: alphabets
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 141, 153, 174))),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      alphabet = newValue;
                                    });
                                  },
                                )),
                            ListTile(
                                title: Text(
                                  "Photo Size",
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "How big do you want your text art to be relative to the photo's resolution?" +
                                      "Note: larger photo sizes will take longer to process",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                trailing: DropdownButton<String>(
                                  value: photoSize,
                                  icon: Icon(Icons.arrow_downward,
                                      color:
                                          Color.fromARGB(255, 237, 242, 244)),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 141, 153, 174)),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _customSize = (newValue == 'Custom');
                                      photoSize = newValue;
                                    });
                                  },
                                  items: <String>[
                                    '100%',
                                    '50%',
                                    '25%',
                                    '10%',
                                    '200%',
                                    'Custom'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 141, 153, 174))),
                                    );
                                  }).toList(),
                                )),
                            !_customSize
                                ? SizedBox(width: 0, height: 60.0)
                                : Row(children: <Widget>[
                                    Flexible(
                                        child: TextField(
                                      controller: widthController,
                                      decoration: InputDecoration(
                                          labelText: 'Width (in pixels): ',
                                          alignLabelWithHint: true),
                                    )),
                                    SizedBox(width: 10),
                                    Flexible(
                                        child: TextField(
                                      controller: heightController,
                                      decoration: InputDecoration(
                                          labelText: 'Height (in pixels): ',
                                          alignLabelWithHint: true),
                                    )),
                                  ]),
                            RaisedButton(
                              onPressed: () {
                                _generate(context);
                              },
                              color: Colors.green,
                              child: Text(
                                "Generate Art!",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return _photoSelected ? _afterPicture(context) : _beforePicture(context);
  }
}
