import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_to_text/IO/AlphabetIO.dart';

class Customize extends StatefulWidget {
  @override
  _CustomizeState createState() => _CustomizeState();
}

class _CustomizeState extends State<Customize> {
  Map<String, dynamic> fileContent;
  final alphabetController = TextEditingController();
  final nameController = TextEditingController();

  Future<String> getContent() async {
    AlphabetIO.basicSetup();
    fileContent = await AlphabetIO.read();
    return Future.value("Completed Successfully");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List data = [];
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color.fromARGB(255, 141, 153, 174),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 141, 153, 174),
          title: ListTile(
            leading: Icon(
              Icons.sort_by_alpha,
              size: 20.0,
              color: Colors.white,
            ),
            title: Text('View all Alphabets',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: double.infinity,
                  child: SingleChildScrollView(
                      child: FutureBuilder<String>(
                          future: getContent(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(width: 10);
                            } else {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                fileContent.forEach((k, v) => data.add([k, v]));
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: (data == null) ? 0 : data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      color: Color.fromARGB(255, 237, 242, 244),
                                      child: ListTile(
                                          title: Text(data[index][0],
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 43, 45, 66))),
                                          subtitle: Text(data[index][1],
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 43, 45, 66))),
                                          trailing: IconButton(
                                              onPressed: () => showAlertDialog(
                                                  context, data[index][0]),
                                              icon: Icon(Icons.cancel,
                                                  color: Color.fromARGB(
                                                      255, 227, 74, 111)))),
                                    );
                                  },
                                );
                              }
                            }
                          }))),
              Container(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
                  height: 50,
                  child: RaisedButton(
                      child: Text("Create a new Alphabet!",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromARGB(255, 237, 242, 244))),
                      color: Colors.green,
                      onPressed: () => createNewAlphabet(context)))
            ]));
  }

  void createNewAlphabet(BuildContext context) {
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
        _createAlphabet(nameController.text, alphabetController.text);
      },
    );

    AlertDialog create = AlertDialog(
      backgroundColor: Color.fromARGB(255, 43, 45, 66),
      title: Text("Create Alphabet",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.35,
          width: MediaQuery.of(context).size.width * 0.95,
          child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Text(
                    'Input the characters or emojis you want to use for your new ' +
                        'alphabet. Earlier characters will appear as the lighter ' +
                        'colors of your picture, so choose character order wisely.',
                    style:
                        TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: Color.fromARGB(255, 141, 153, 174),
                  ),
                  decoration: InputDecoration(
                      labelText: 'Name of Alphabet: ',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 141, 153, 174)),
                      alignLabelWithHint: true),
                ),
                TextField(
                  controller: alphabetController,
                  style: TextStyle(
                    color: Color.fromARGB(255, 141, 153, 174),
                  ),
                  decoration: InputDecoration(
                      labelText: 'Alphabet: ',
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

  void showAlertDialog(BuildContext context, String key) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      onPressed: () {
        _removeAlphabet(key);
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Color.fromARGB(255, 43, 45, 66),
      title: Text("Delete Confirmation",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      content: Text(
          "Are you sure you want to delete this Alphabet?" +
              "\n(Note: if you delete ALL alphabets, the default ones will reappear.",
          style: TextStyle(color: Color.fromARGB(255, 237, 242, 244))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _removeAlphabet(String key) {
    AlphabetIO.remove(key);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        getContent();
      });
    });
  }

  void _createAlphabet(String key, String value) {
    AlphabetIO.write(key, value);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        getContent();
      });
    });
  }
}
