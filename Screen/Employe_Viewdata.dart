
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employe_mangement/Screen/Employe_Insertdata.dart';
import 'package:employe_mangement/Screen/Employe_Updatedata.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Employe_Viewdata extends StatefulWidget {
  const Employe_Viewdata({super.key});

  @override
  State<Employe_Viewdata> createState() => _Employe_ViewdataState();
}

class _Employe_ViewdataState extends State<Employe_Viewdata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employe_Viewdata"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context)=>Employe_Insertdata()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("EmployeDetails").snapshots(),
        builder: (BuildContext context,AsyncSnapshot <QuerySnapshot> snapshots)
          {
            if(snapshots.hasData)
              {
                if(snapshots.data!.size<=0)
                  {
                    return Center(
                      child: Text("No Data Found"),
                    );
                  }
                else{
                  return ListView(
                    children: snapshots.data!.docs.map((document){
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          dismissible: DismissiblePane(onDismissed: (){},),
                          children: [
                            IconButton(onPressed: ()async{
                              var id = document.id.toString();
                              // print(id.toString());
                              FirebaseStorage.instance.ref(document["Filename"]).delete().then((value) async{
                                await FirebaseFirestore.instance.collection("EmployeDetails").doc(id).delete().then((value)
                                {
                                  print("Sucessfully deleted");
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Employe_Viewdata()));
                                });
                              });
                            }, icon: Icon(Icons.delete,color: Colors.red,)),
                            IconButton(onPressed: (){
                              var id = document.id.toString();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context)=>Employe_Updatedata(myid: id.toString())),
                              );
                            }, icon: Icon(Icons.edit,color: Colors.brown,)),
                          ],
                        ),
                       child:  ListTile(
                         leading: CircleAvatar(
                           child: Image.network(document["Imageurl"],height: 100,width: 100,fit: BoxFit.cover,),
                         ),
                      title: Text(document["Ename"].toString()+ "" + document["Email"].toString()+ "" + document["Datetime"].toString()),
                         subtitle: Text(document["Ework"].toString()+ "" +document["Salary"].toString()+ "" +document["Age"].toString()),
                       ),
                      );
                  }).toList(),
                  );
                }
              }
            else
              {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
          }
      ),
    );
  }
}
