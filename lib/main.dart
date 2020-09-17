import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_to_text/screens/create/CreateScreen.dart';
import 'package:image_to_text/screens/customize/Customize.dart';
import 'package:image_to_text/screens/settings/Settings.dart';
import 'package:image_to_text/screens/view/View.dart';
import 'IO/AlphabetIO.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Images to Text',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 43, 45, 66),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'PhotoArt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    asyncSetup();
  }

  void asyncSetup() {
    //Nothing here but us chickens!
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Container(
              child: CreateScreen(),
            ),
            Container(
              child: View(),
            ),
            Container(
              child: Customize(),
            ),
            Container(
              child: Settings(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Color.fromARGB(255, 237, 242, 244),
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Create'),
              icon: Icon(Icons.add_a_photo),
              activeColor: Color.fromARGB(255, 239, 35, 60),
              textAlign: TextAlign.center),
          BottomNavyBarItem(
              title: Text('View'),
              icon: Icon(Icons.apps),
              textAlign: TextAlign.center),
          BottomNavyBarItem(
              title: Text('Customize'),
              icon: Icon(Icons.tune),
              activeColor: Color.fromARGB(255, 229, 61, 0),
              textAlign: TextAlign.center),
          BottomNavyBarItem(
              title: Text('Settings'),
              icon: Icon(Icons.settings),
              activeColor: Color.fromARGB(255, 43, 45, 66),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
