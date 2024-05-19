import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employe_mangement/ChatScreen/Chat_Page.dart';
import 'package:employe_mangement/ChatScreen/Login_Page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat_Home extends StatefulWidget {
  const Chat_Home({super.key});

  @override
  State<Chat_Home> createState() => _Chat_Home();
}

class _Chat_Home extends State<Chat_Home>
  with SingleTickerProviderStateMixin {
  var position;
  late TabController _tabController;

  var getpht,geteml;
  void getdata()async
  {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      getpht = pref.getString("Userphoto").toString();
      geteml = pref.getString("Useremail").toString();
    });
    print(geteml.toString());

    if(geteml.toString() == "null")
      {
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Login_Page()));
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(_setActiveTabIndex);
  }

    void _setActiveTabIndex(){
      var index = _tabController.index;

      setState(() {
        position = index;
      });
    }

    @override
    void dispose(){
      _tabController.dispose();
      super.dispose();
    }
  var chats;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController
      (length: 3,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: ()async{

              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.clear();
              final GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.signOut();

              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=>Login_Page()),
              );

            },
            child: Icon(Icons.message,color: Colors.black,),backgroundColor: Colors.green,
          ),
          drawer: Drawer(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("UserDetalis").where("Useremail",isNotEqualTo: geteml.toString()).snapshots(),
                    builder: (BuildContext context,AsyncSnapshot <QuerySnapshot> snapshots)
                    {
                      if(snapshots.hasData)
                        {
                          if(snapshots.data!.size<=0){
                            return Text("No data available");
                          }
                          else {
                            return ListView(
                                children: snapshots.data!.docs.map((document){
                                  return ListTile(
                                    title: Text(document["Username"].toString()),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(document["Useremail"].toString()),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(document["Userphoto"]),
                                    ),
                                    onTap: (){
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context)=>Chat_Page(chatId: document["Username"].toString(),userImage: document["Userphoto"],reciverid: document.id.toString(),)),
                                      );
                                    }
                                  );
                                }).toList(),
                              );
                        }
                      }
                      else{
                        return CircularProgressIndicator();
                      }
                    }
                ),
            //   ],
            // ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.green,
            // backgroundColor: (position == 0)
            //     ? Colors.green
            //     :(position == 1)
            //     ? Colors.grey
            //     :Colors.red,
            title: Text("WhatsApp"),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text("chat"),
                  icon: Icon(Icons.chat),
                ),
                Tab(
                  child: Text("updates"),
                  icon: Icon(Icons.update),
                ),
                Tab(
                  child: Text("calls"),
                  icon: Icon(Icons.call),
                ),
              ],
            ),
            actions: [
              Image.network(getpht),
              Text(geteml),
              (position == 0)
              ? PopupMenuButton(
                icon: Icon(Icons.more_vert),
                  itemBuilder: (context){
                    return[
                      PopupMenuItem(
                        child: Text("New group"),
                        value: "g1",),
                      PopupMenuItem(
                        child: Text("New broadcast"),
                        value: "b2",),
                      PopupMenuItem(
                        child: Text("Linked devices"),
                        value: "d3",),
                      PopupMenuItem(
                        child: Text("Starred messages"),
                        value: "s4",),
                      PopupMenuItem(
                        child: Text("Settings"),
                        value: "s5",),
                    ];
                  })
                  : (position == 1)
              ? PopupMenuButton(
                icon: Icon(Icons.more_vert),
                  itemBuilder: (context){
                  return[
                    PopupMenuItem(
                      child: Text("Status privacy"),
                      value: "s1",),
                    PopupMenuItem(
                      child: Text("Settings"),
                      value: "s2",),
                  ];
                  })
                  : PopupMenuButton(
                icon: Icon(Icons.more_vert),
                  itemBuilder: (context){
                  return[
                    PopupMenuItem(
                      child: Text("Clear call log"),
                      value: "c1",),
                    PopupMenuItem(
                      child: Text("Settings"),
                      value: "s2",),
                  ];
                  }),
            ],
          ),
body: TabBarView(
  children: [
    Container(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(onPressed: (){}, child: Icon(Icons.add)),
            TextButton(onPressed: (){}, child: Text("textbtn")),
            InkWell(onTap: (){},child: Icon(Icons.add),),
            InkWell(onTap: (){},child:Text("inkwell"),),


          ],
        ),
      ),
    ),
    Text("update"),
    Text("Call"),
  ],
),
        ),
    );
  }
}
