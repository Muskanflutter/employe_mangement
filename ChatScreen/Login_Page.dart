import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employe_mangement/ChatScreen/Chat_Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
              child: ElevatedButton(
                onPressed: () async {
              final GoogleSignIn googleSignIn = GoogleSignIn();
              final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
              if (googleSignInAccount != null) {
                final GoogleSignInAuthentication googleSignInAuthentication =
                await googleSignInAccount.authentication;
                final AuthCredential authCredential = GoogleAuthProvider.credential(
                    idToken: googleSignInAuthentication.idToken,
                    accessToken: googleSignInAuthentication.accessToken);

                // Getting users credential
                UserCredential result = await auth.signInWithCredential(authCredential);
                User user = result.user!;

                var nm = user.displayName.toString();
                var ph = user.phoneNumber.toString();
                var pot = user.photoURL.toString();
                var em = user.email.toString();
                var gid = user.uid.toString();
                //print(nm);

                await FirebaseFirestore.instance.collection("UserDetalis").where("Useremail",isEqualTo: em).get().then((value) async {
                  if(value.size<=0)
                    {
                      await FirebaseFirestore.instance.collection("UserDetalis").add(
                          {
                            "Username" : nm,
                            "Userphoneno" : ph,
                            "Userphoto" : pot,
                            "Useremail" : em,
                            "Googleid" : gid,
                          }).then((value) async {

                        // print(value);
                        // print("Successfully insert");
                        Fluttertoast.showToast(
                          msg: "Login Succesfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);

                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.setString("Userphoto", pot.toString() );
                        pref.setString("Useremail", em.toString());
                        pref.setString("senderid", value.id.toString());
                      });
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Chat_Home()),
                      );
                    }
                  else
                    {
                      // print("Already exists");
                      Fluttertoast.showToast(
                        msg: "Data Already Exist",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );

                      SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setString("Userphoto", pot.toString() );
                      pref.setString("Useremail", em.toString());
                      pref.setString("senderid", value.docs.first.id.toString());

                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Chat_Home()),
                      );
                    }
                });
    }
                },
                child: Text("Google"),
              ),
            ),
    );
  }
}
