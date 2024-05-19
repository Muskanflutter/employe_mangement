


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employe_mangement/ChatScreen/Chat_Home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Chat_Page extends StatefulWidget {
  var chatId,userImage, reciverid;
   Chat_Page({super.key, required this.chatId,this.userImage,this.reciverid});

  @override
  State<Chat_Page> createState() => _Chat_PageState();
}

class _Chat_PageState extends State<Chat_Page>  with SingleTickerProviderStateMixin {
  TextEditingController mesg = TextEditingController();
  var senderid;
  var msg;
  var msgtype = "text";

  ImagePicker picker = ImagePicker();
  File? imagefile = null;

  getStoreData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      senderid = pref.getString("senderid");
    });
    print(widget.reciverid.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStoreData();
  }
  late final controller = SlidableController(this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                onTap: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Chat_Home()),
                  );
                },
                leading: CircleAvatar(
                   child: Image.network(widget.userImage),
                ),
                title: Text(widget.chatId.toString()),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(onPressed: (){
                print("Video call");
              }, icon: Icon(Icons.video_call),),
              IconButton(onPressed: (){
                print("Call");
              }, icon: Icon(Icons.call),),
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                  itemBuilder: (context){
                  return[
                    PopupMenuItem(
                        child: Text("View contact"),
                    value: "v1",),
                    PopupMenuItem(
                      child: Text("Media,links,and docs"),
                      value: "m2",),
                    PopupMenuItem(
                      child: Text("Search"),
                      value: "s3",),
                    PopupMenuItem(
                      child: Text("Mute notification"),
                      value: "m4",),
                    PopupMenuItem(
                      child: Text("Disappeaing messages"),
                      value: "d5",),
                  ];
                  }),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // decoration: BoxDecoration(),
            child:
            StreamBuilder(
              stream: FirebaseFirestore.instance
              .collection("UserDetalis")
              .doc(senderid)
              .collection("chat")
              .doc(widget.reciverid)
              .collection("message")
              .orderBy("Mtime")
              .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data!.size <= 0){
                    return Center(child: Text("no data"));
                  }
                  else{
                    return ListView(
                      children: snapshot.data!.docs.map((document){
                        return SingleChildScrollView(
                            child: Slidable(
                              // Specify a key if the Slidable is dismissible.
                              key: ValueKey(0),

                              // The start action pane is the one at the left or the top side.
                              startActionPane: ActionPane(
                                // A motion is a widget used to control how the pane animates.
                                motion: const ScrollMotion(),

                                // A pane can dismiss the Slidable.
                                dismissible: DismissiblePane(onDismissed: () {
                                  print("-----------------------obj--------------------------------------");
                                    FirebaseFirestore.instance
                                        .collection("UserDetalis")
                                        .doc(senderid)
                                        .collection("chat")
                                        .doc(widget.reciverid)
                                        .collection("message")
                                        .doc(document.id)
                                        .delete()
                                        .then((value) {
                                      print("Message deleted");
                                    }).catchError((error) {
                                      print("Failed to delete message: $error");
                                    });
                                  // var id =  document["senderid"];
                                  // print(id);
                                }),

                                // All actions are defined in the children parameter.
                                children: const [
                                  // A SlidableAction can have an icon and/or a label.
                                  SlidableAction(
                                    onPressed: doNothing,
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              // The child of the Slidable is what the user sees when the
                              // component is not dragged.
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Align(
                                      alignment: (document["senderid"] == senderid.toString() ? Alignment.topRight : Alignment.topLeft),
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      color: (document["senderid"] == senderid.toString())?Colors.green.shade50 : Colors.grey.shade200,

                                        child: (document["type"].toString() == "text")
                                            ? Text(document["msg"].toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ))
                                            :Image.network(document["msg"].toString(),
                                          height: 50,
                                          width: 50,),
                                      ),
                                            ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        // simple list
                        //   ListTile(
                        //   title: Column(
                        //     children: [
                        //       Align(
                        //         alignment: (document["senderid"] == senderid.toString() ? Alignment.topRight : Alignment.topLeft),
                        //       child: Container(
                        //         padding: EdgeInsets.all(10.0),
                        //         color: (document["senderid"] == senderid.toString())?Colors.green.shade50 : Colors.grey.shade200,
                        //
                        //           child: (document["type"].toString() == "text")
                        //               ?
                        //           Text(document["msg"].toString(),
                        //               style: TextStyle(
                        //                 fontSize: 20,
                        //               ))
                        //               :Image.network(document["msg"].toString(),
                        //             height: 50,
                        //             width: 50,),
                        //         ),
                        //               ),
                        //     ],
                        //   ),
                        // );
                    }).toList(),
                    );
                  }
                }
                else {
                  return CircularProgressIndicator();
                }
              }
            ),
          ),
        Align(
          alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.red,
                        child:TextField(
                          controller: mesg,
                          decoration: InputDecoration(
                            icon: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context){
                                return[
                                  PopupMenuItem(child: IconButton(
                                    onPressed: ()async{
                                      XFile? photo = await picker.pickImage(source: ImageSource.gallery);
                                            setState(() {
                                              imagefile = File(photo!.path);
                                            });
                                    },
                                    icon: Icon(Icons.photo),
                                  )),
                                  PopupMenuItem(child: IconButton(
                                    onPressed: () async{
                                        XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                        setState(() {
                                          imagefile = File(photo!.path);
                                        });
                                    },
                                    icon: Icon(Icons.camera),
                                  ))
                                ];
                              },
                            ),
                            hintText: "Write message...",
                            helperStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    IconButton(onPressed: ()async {
                      print("button clicked");

                      if(imagefile==null)
                      {
                            msgtype = "text";
                            msg = mesg.text.toString();
                            int timestamp = DateTime.now().millisecondsSinceEpoch;
                            FirebaseFirestore.instance.collection("UserDetalis").doc(senderid).collection("chat").doc(widget.reciverid).collection("message").add({
                              "senderid": senderid,
                              "reciverid" : widget.reciverid,
                              "msg" : msg,
                              "type" : msgtype,
                              "Mtime" : timestamp
                            }).then((value) {
                              FirebaseFirestore.instance.collection("UserDetalis").doc(widget.reciverid).collection("chat").doc(senderid).collection("message").add(
                                  {
                                    "senderid" : senderid,
                                    "reciverid" :widget.reciverid ,
                                    "msg" : msg,
                                    "type" : msgtype,
                                    "Mtime": timestamp
                                  }).then((value) {
                                print("msg inserted");
                              });
                            });
                        mesg.clear();
                      }
                     else{
                        msgtype = "Img";
                        msg = mesg.text.toString();
                        int timestamp = DateTime.now().millisecondsSinceEpoch;
                        var uuid = Uuid();
                        var filename = uuid.v1().toString();

                        await FirebaseStorage.instance.ref(filename).putFile(imagefile!).whenComplete((){}).then((filedata)async{
                          await filedata.ref.getDownloadURL().then((fileurl)async{

                            FirebaseFirestore.instance.collection("UserDetalis").doc(senderid).collection("chat").doc(widget.reciverid).collection("message").add({
                              "senderid": senderid,
                              "reciverid" : widget.reciverid,
                              "msg" : fileurl,
                              "type" : msgtype,
                              "Mtime" : timestamp
                            }).then((value) {
                              FirebaseFirestore.instance.collection("UserDetalis").doc(widget.reciverid).collection("chat").doc(senderid).collection("message").add(
                                  {
                                    "senderid" : senderid,
                                    "reciverid" :widget.reciverid ,
                                    "msg" : fileurl,
                                    "type" : msgtype,
                                    "Mtime": timestamp,

                                  }).then((value) {
                                print("msg inserted");
                              });
                            });
                          });
                        });
                        mesg.clear();
                      }
                    },
                      icon: Icon(Icons.send)
                    ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

}
void doNothing(BuildContext context) {
// print("--------------------------------------------"+context.toString());
}