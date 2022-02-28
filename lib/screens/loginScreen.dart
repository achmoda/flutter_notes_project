import 'package:notes/components/button.dart';
import 'package:notes/constants.dart';
import 'package:notes/screens/notesPage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final FirebaseAuth _auth;

  late TextEditingController _email;
  late TextEditingController _password;

  @override
  void initState() {
    super.initState();

    _auth = FirebaseAuth.instance;

    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: 'logo', child: kLogo),
            SizedBox(height: 40),
            TextField(
              controller: _email,
              decoration: kInputFieldDecoration.copyWith(
                hintText: 'Entrez e-mail ici',
              ),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: kInputFieldDecoration.copyWith(
                hintText: 'Entrez le mot de passe ici',
              ),
            ),
            SizedBox(height: 40,),
            Hero(
              tag: 'login',
              child: Button(
                content: Text(
                  'Connexion',
                  style: TextStyle(
                    color: kDefaultTextColor,
                  ),
                ),
                color: kYellow,
                onPress: () async {
                  try {
                  final user = await _auth.signInWithEmailAndPassword(email: _email.text, password: _password.text);

                    Navigator.pushNamed(context, NotesPage.id);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == "user-not-found") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orangeAccent,
                          content: Text(
                            "Aucun utilisateur trouvé pour cet e-mail",
                            style: TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                        ),
                      );
                    } else if (e.code == 'wrong-password') {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orangeAccent,
                          content: Text(
                            "Mauvais mot de passe fourni par l'utilisateur",
                            style: TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                        ),
                      );
                    }
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }
}
