import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:employe_mangement/Screen/Employe_Viewdata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Employe_Insertdata extends StatefulWidget {
  const Employe_Insertdata({super.key});

  @override
  State<Employe_Insertdata> createState() => _Employe_InsertdataState();
}

class _Employe_InsertdataState extends State<Employe_Insertdata> {
  final ImagePicker picker = ImagePicker();

  GlobalKey fromkey = GlobalKey<FormState>();
  var myselecteddate;
  TextEditingController ename = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController ework = TextEditingController();
  TextEditingController salary = TextEditingController();
  TextEditingController age = TextEditingController();
  File? selectedfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employe_Insertdata"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: fromkey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              children: [
                (selectedfile == null)? Image.asset("img/7.png") : Image.file(selectedfile!,width: 200,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: ()async{
                      XFile? photo = await picker.pickImage(source: ImageSource.camera);
                      setState(() {
                        selectedfile = File(photo!.path);
                      });
                    }, icon: Icon(Icons.camera)),
                    IconButton(onPressed: ()async{
                      XFile? photo = await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        selectedfile = File(photo!.path);
                      });
                    }, icon: Icon(Icons.photo)),
                  ],
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: ename,
                  decoration: InputDecoration(
                    labelText: "Ename:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: ework,
                  decoration: InputDecoration(
                    labelText: "Ework:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: salary,
                  decoration: InputDecoration(
                    labelText: "Salary:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: age,
                  decoration: InputDecoration(
                    labelText: "Age:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'dd MMM,yyyy',
                  initialValue: DateTime.now().toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                  icon: Icon(Icons.event),
                  dateLabelText: "Date",
                  timeLabelText: "Minu",
                  selectableDayPredicate: (date){
                    if(date.weekday == 6 || date.weekday == 7){
                      return false;
                    }
                    return true;
                  },
                  onChanged: (val)
                  {
                    setState(() {
                      myselecteddate = val;
                    });
                  },
                  validator: (val){
                    print(val);
                    return null;
                  },
                  onSaved: (val) => print(val),
                ),
                ElevatedButton(onPressed: ()async{
                  var enm = ename.text.toString();
                  var eml = email.text.toString();
                  var ewk = ework.text.toString();
                  var sal = int.parse(salary.text).toString();
                  var ag = int.parse(age.text).toString();
                  var mydatetime = myselecteddate.toString();
                  // insert

                  if(selectedfile!=null)
                  {
                    var uuid = Uuid();
                    var filename = uuid.v1().toString();
                    await FirebaseStorage.instance.ref(filename).putFile(selectedfile!).whenComplete((){}).then((filedata) async{
                      await filedata.ref.getDownloadURL().then((fileurl) async{
                        await FirebaseFirestore.instance.collection("EmployeDetails").add(
                          {
                          "Ename" : enm,
                          "Email" : eml,
                          "Ework" : ewk,
                          "Salary" : sal.toString(),
                          "Age" : ag.toString(),
                          "Datetime" : mydatetime.toString(),
                            "Imageurl" :fileurl,
                            "Filename" : filename,
                          }).then((value)
                  {
                  print("Succesfully insertdata");
                  Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=>Employe_Viewdata()),
                  );
                          }
                        );
                      });
                    });

                  }
                  else
                    {
                      print("please select file");
                    }
                }, child: Text("Submit")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
