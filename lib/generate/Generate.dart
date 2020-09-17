import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'IO.dart';
import 'dart:io';
import 'package:image/image.dart' as ImageIO;

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
  Image finalImage;

  Future<String> getContent() async {
    Map<String, dynamic> fileContent = await IO.read();
    alphabet = fileContent[widget.alphabet];

    ImageIO.Image resizeImage =
        await AlterPhoto.resizeImage(widget.image, widget.width, widget.height);
    finalImage = await AlterPhoto.changeImage(resizeImage, alphabet);
    //finalImage = await AlterPhoto.changeImage(resizeImage, alphabet);
    return Future.value("Fetched all values.");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: getContent(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                backgroundColor: Color.fromARGB(255, 249, 220, 92),
                body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              return Scaffold(
                  backgroundColor: Color.fromARGB(255, 249, 220, 92),
                  body: Center(child: finalImage));
            }
          }
        });
  }
}

class AlterPhoto {
  static Future<ImageIO.Image> resizeImage(
      File imageFile, int width, int height) async {

    var image = ImageIO.decodeImage(imageFile.readAsBytesSync());
    return ImageIO.copyResize(image, width: width, height: height);
  }

  static Future<Image> changeImage(ImageIO.Image image, String alphabet) async {
    final path = join(
      (await getTemporaryDirectory()).path,
      'ImageText-ConvertedImage-${DateTime.now()}.png',
    );

    File(path).writeAsBytesSync(ImageIO.encodePng(image));
    return Image.file(File(path));
  }
}
