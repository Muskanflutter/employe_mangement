import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:employe_mangement/Screen/Employe_Viewdata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Employe_Updatedata extends StatefulWidget {
  var myid;
   Employe_Updatedata({super.key,this.myid});

  @override
  State<Employe_Updatedata> createState() => _Employe_UpdatedataState();
}

class _Employe_UpdatedataState extends State<Employe_Updatedata> {
  getSingledata() async {
    var data = FirebaseFirestore.instance.collection("EmployeDetails").doc(widget.myid.toString()).get().then((value)
    {
      ename.text = value.data()?["Ename"];
      email.text = value.data()?["Email"];
      ework.text = value.data()?["Ework"];
      salary.text = value.data()?["Salary"];
      age.text = value.data()?["Age"];
      myselecteddate = value.data()?["Datetime"];

      setState(() {
        oldimgFile = value["Filename"].toString();
        oldimgurl = value["Imageurl"].toString();
      });
      print("selectedfile " + selectedfile.toString());
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSingledata();
  }
  final ImagePicker picker = ImagePicker();

  var myselecteddate;
  TextEditingController ename = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController ework = TextEditingController();
  TextEditingController salary = TextEditingController();
  TextEditingController age = TextEditingController();
  File? selectedfile = null;
  var oldimgFile = "";
  var oldimgurl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employe_Updatedata"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
              children: [
              (selectedfile != null)?Image.file(selectedfile!):(oldimgurl!= "")?Image.network(oldimgurl):Image.asset("img/7.png"),
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
         Column(
            children: [
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

                if(selectedfile != null) {
                  var uuid = Uuid();
                  var filename = uuid.v1().toString() + ".jpg";
                  FirebaseStorage.instance.ref(oldimgFile).delete();
                  await FirebaseStorage.instance.ref(filename).putFile(
                      selectedfile!).whenComplete(() {}).then((filedata) async {
                    await filedata.ref.getDownloadURL().then((fileurl) async {
                      await FirebaseFirestore.instance.collection(
                          "EmployeDetails").doc(widget.myid.toString()).update(
                          {
                            "Ename": ename.text,
                            "Email": email.text,
                            "Ework": ework.text,
                            "Salary": salary.text,
                            "Age": age.text,
                            "Datetime": myselecteddate.toString(),
                            "Imageurl": fileurl,
                            "Filename": filename,
                          }).then((value) {
                        print("Succesfully update");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => Employe_Viewdata()),
                        );
                      });
                    });
                  });
                }
                else
                  {
                    await FirebaseFirestore.instance.collection(
                        "EmployeDetails").doc(widget.myid.toString()).update(
                        {
                          "Ename": ename.text,
                          "Email": email.text,
                          "Ework": ework.text,
                          "Salary": salary.text,
                          "Age": age.text,
                          "Datetime": myselecteddate.toString(),

                        }).then((value) {
                      print("Succesfully update");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => Employe_Viewdata()),
                      );
                    });
                  }
              }, child: Text("Submit")),
            ],
          ),
          ],
        ),
      ),
    ),
    );
  }
}
