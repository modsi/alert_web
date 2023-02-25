import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

Uint8List getBytesImage(String b64) {
  Uint8List bytesImage = const Base64Decoder().convert(b64);
  return bytesImage;
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final box = GetStorage();
  final ValueNotifier<Map<String, dynamic>> showdata =
      new ValueNotifier<Map<String, dynamic>>({});
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Emergency Accident Alert"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'ออกจากระบบ',
              onPressed: () {
                box.remove('email');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login UI'),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          // onTap: _onItemTapped,
        ),
        body: Row(children: [
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('alert').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  data["doc_id"] = document.id.toString();
                  return Card(
                      elevation: 50,
                      shadowColor: Colors.black,
                      color: Colors.white,
                      child: SizedBox(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ประเภทการแจ้งเหตุ : " + data["type"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    Text("หน่วยงาน : " + data["agency"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    Text(
                                        "สถานะ : " +
                                            (data["status"] == 0
                                                ? "รอตรวจสอบ"
                                                : "ตรวจสอบแล้ว"),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    ElevatedButton(
                                      onPressed: () {
                                        showdata.value = data;
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.fromLTRB(
                                            40, 15, 40, 15),
                                      ),
                                      child: Text(
                                        (data["status"] == 0
                                            ? 'ตรวจสอบ'
                                            : 'ดูรายละเอียด'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ]))));
                }).toList(),
              );
            },
          )),
          Expanded(
              child: ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: showdata,
                  builder: (_, tasks, __) {
                    if (tasks.length > 0 &&
                        tasks!['doc_id'] != null &&
                        tasks!['status'] != 1) {
                      CollectionReference alert =
                          FirebaseFirestore.instance.collection('alert');
                      alert
                          .doc(tasks!['doc_id'])
                          .update({'status': 1, 'viewby': box.read('email')});
                    }
                    return Card(
                        elevation: 50,
                        shadowColor: Colors.black,
                        color: Colors.white,
                        child: SizedBox(
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment: tasks.length > 0 &&
                                            tasks!['type'] != null
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    children: [
                                      (tasks.length > 0 &&
                                              tasks!['type'] != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                  const Text(
                                                    'รายการแจ้งเหตุ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                      "ประเภทการแจ้งเหตุ : " +
                                                          tasks!['type'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "หน่วยงานที่ต้องการแจ้งเหตุ : " +
                                                          tasks!['agency'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "รายละเอียด : \n" +
                                                          tasks!['detail'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "สถานที่ : " +
                                                          tasks!['address'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "พิกัด :  Latitude: " +
                                                          tasks!['lat']
                                                              .toString() +
                                                          "  Longitude: " +
                                                          tasks!['lng']
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "แจ้งเหตุโดย : " +
                                                          (tasks!['alertby'] !=
                                                                  null
                                                              ? tasks![
                                                                  'alertby']
                                                              : ""),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  Text(
                                                      "แจ้งเหตุเมื่อ : " +
                                                          (tasks!['date_alert'] !=
                                                                  null
                                                              ? tasks![
                                                                      'date_alert']
                                                                  .toDate()
                                                                  .toString()
                                                              : ""),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  if (tasks!['image_1_64base'] !=
                                                          null &&
                                                      tasks!['image_1_64base'] !=
                                                          "")
                                                    Container(
                                                        width: 200,
                                                        height: 200,
                                                        child: Image.memory(
                                                            getBytesImage(tasks[
                                                                    'image_1_64base']
                                                                .toString()))),
                                                  if (tasks!['image_2_64base'] !=
                                                          null &&
                                                      tasks!['image_2_64base'] !=
                                                          "")
                                                    Container(
                                                        width: 200,
                                                        height: 200,
                                                        child: Image.memory(
                                                            getBytesImage(tasks[
                                                                    'image_2_64base']
                                                                .toString()))),
                                                  if (tasks!['image_3_64base'] !=
                                                          null &&
                                                      tasks!['image_3_64base'] !=
                                                          "")
                                                    Container(
                                                        width: 200,
                                                        height: 200,
                                                        child: Image.memory(
                                                            getBytesImage(tasks[
                                                                    'image_3_64base']
                                                                .toString()))),
                                                ])
                                          : Text(
                                              " - กรุณาเลือกรายการที่ต้องการตรวจสอบ - ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)))
                                    ]))));
                  }))
        ]));
  }
}
