import 'package:notes/components/button.dart';
import 'package:notes/constants.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


class EditNotePage extends StatefulWidget {
  static const String id = 'editNote';

  String initialTitle;
  String initialContent;

  EditNotePage({required this.initialContent, required this.initialTitle});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final FirebaseAuth _auth;
  late final _user;

  late TextEditingController _title;
  late TextEditingController _content;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();

    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;

    _title = TextEditingController(text: widget.initialTitle);
    _content = TextEditingController(text: widget.initialContent);
    _initSpeech();
  }


  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _content.text = result.recognizedWords;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: kLightBlue,
              leading: Hero(
                tag: 'logo',
                child: Icon(
                  FontAwesomeIcons.stickyNote,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Notes',
                style: TextStyle(
                  color: kDefaultTextColor,
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 5),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: TextField(
                          controller: _title,
                          decoration: InputDecoration(hintText: '  Title'),
                        ),
                      ),
                      SizedBox(height: 15.0,),

                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: TextField(
                              controller: _content,
                              maxLines: null,
                              decoration: InputDecoration(hintText: '  Content'),

                            ),
                          ),
                        onTap: () {
                          _speechToText.isListening
                              ? _content.text

                          // If listening isn't active but could be tell the user
                          // how to start it, otherwise indicate that speech
                          // recognition is not yet ready or not supported on
                          // the target device
                              : _speechEnabled
                              ? 'Tap the microphone to start listening...'
                              : 'Speech not available';
                        },
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  child: Button(
                    content: Icon(Icons.save),
                    width: 145,
                    color: Color(0xFF75B9BE),
                    onPress: () {


                      if (_content.text.isNotEmpty && _title.text.isNotEmpty ) {
                        kRef.add({
                          'author': _user!.email,
                          'title': _title.text,
                          'content': _content.text,
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Il faut verifier les coordonnées !')),
                        );
                      }

                    }
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Button(
                    content: Icon(Icons.delete),
                    width: 145,
                    color: Color(0xFF75B9BE),
                    onPress: () {Navigator.pop(context);}
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        // If not yet listening for speech start, otherwise stop
        _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _title.dispose();
    _content.dispose();
  }
}
