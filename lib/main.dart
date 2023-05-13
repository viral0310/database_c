import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sql_lite/db%20helper.dart';
import 'model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ImagePicker picker = ImagePicker();
  late Future<List<Student>> getAllStudents;
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nameUpdateController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController ageUpdateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController cityUpdateController = TextEditingController();
  String? name;
  int? age;
  String? city;
  Uint8List? image;
  Uint8List? result;
  @override
  void initState() {
    super.initState();
    getAllStudents = DBHelper.dbHelper.fetchAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (val) async {
                setState(
                  () {
                    getAllStudents =
                        DBHelper.dbHelper.fetchSearchedRecords(data: val);
                  },
                );
              },
              decoration:
                  const InputDecoration(hintText: "Search name here..."),
            ),
          ),
          Expanded(
            flex: 14,
            child: FutureBuilder(
              future: getAllStudents,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  List<Student> data = snapshot.data as List<Student>;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          // leading: Text("${data[i]['id']}"),
                          // title: Text("${data[i]['name']}"),
                          // subtitle: Text("${data[i]['age']}"),
                          // trailing: Text("${data[i]['city']}"),
                          leading: (result != "")
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(data[i].image!),
                                )
                              : const CircleAvatar(),
                          title: Text(data[i].name),
                          subtitle: Text("${data[i].age}\n${data[i].city}"),
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  ValidateAndUpdate(data: data[i]);

                                  /*   int resId = await DBHelper.dbHelper
                                        .updateRecord(
                                            name: 'parimal',
                                            age: 19,
                                            city: 'Delhi',
                                            id: data[i].id!);

                                    if (resId == 1) {
                                      print("------------------------------");
                                      print("record updated successfully");
                                      print("------------------------------");
                                      setState(() {
                                        getAllStudents =
                                            DBHelper.dbHelper.fetchAllRecords();
                                      });
                                    } else {
                                      print("-------------------------------");
                                      print("record updation failed.....");
                                      print("-------------------------------");
                                    }*/
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Delete Record's"),
                                        content: const Text(
                                          "Are you sure to delete the record?",
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                int resId = await DBHelper
                                                    .dbHelper
                                                    .deleteRecord(
                                                        id: data[i].id!);

                                                if (resId == 1) {
                                                  print(
                                                      "----------------------------");
                                                  print(
                                                      "Recorded deleted successfully");
                                                  print(
                                                      "----------------------------");

                                                  setState(
                                                    () {
                                                      getAllStudents = DBHelper
                                                          .dbHelper
                                                          .fetchAllRecords();
                                                    },
                                                  );
                                                } else {
                                                  print(
                                                      "----------------------------");

                                                  print(
                                                      "Recorded deletion failed.....");
                                                  print(
                                                      "----------------------------");
                                                }
                                              },
                                              child: const Text("Delete")),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"))
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ValidateAndInsert();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void ValidateAndInsert() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Add Record"),
        ),
        content: Form(
          key: insertFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  XFile? xFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  image = await xFile!.readAsBytes();
                  result = await FlutterImageCompress.compressWithList(
                    image!,
                    minHeight: 1920,
                    minWidth: 1080,
                    quality: 96,
                    rotate: 135,
                  );
                },
                child: const Text("Pick Image"),
              ),
              TextFormField(
                controller: nameController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter name first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      name = val;
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: ageController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter age first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      age = int.parse(val!);
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "age"),
              ),
              TextFormField(
                controller: cityController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter city first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      city = val;
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "City"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (insertFormKey.currentState!.validate()) {
                insertFormKey.currentState!.save();

                int id = await DBHelper.dbHelper.insertRecord(
                    name: name!, age: age!, city: city!, image: result!);

                if (id > 0) {
                  print("--------------------------------");
                  print("Recorde inserted successfully with id of $id");
                  print("---------------------------------");

                  setState(
                    () {
                      getAllStudents = DBHelper.dbHelper.fetchAllRecords();
                    },
                  );
                } else {
                  print("---------------------------------");
                  print("Record inserted failed.........");
                  print("----------------------------------");
                }
              }

              nameController.clear();
              ageController.clear();
              cityController.clear();
              setState(() {
                name = null;
                age = null;
                city = null;
                image = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Insert"),
          ),
          ElevatedButton(
              onPressed: () {
                nameController.clear();
                ageController.clear();
                cityController.clear();
                setState(
                  () {
                    name = null;
                    age = null;
                    city = null;
                    image = null;
                  },
                );
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"))
        ],
      ),
    );
  }

  void ValidateAndUpdate({required Student data}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text("Add Record"),
        ),
        content: Form(
          key: updateFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*ElevatedButton(
                onPressed: () async {
                  XFile? xFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  image = await xFile!.readAsBytes();
                  result = await FlutterImageCompress.compressWithList(
                    image!,
                    minHeight: 1920,
                    minWidth: 1080,
                    quality: 96,
                    rotate: 135,
                  );
                },
                child: const Text("Pick Image"),
              ),*/
              TextFormField(
                controller: nameUpdateController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter name first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      name = val;
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: ageUpdateController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter age first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      age = int.parse(val!);
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "age"),
              ),
              TextFormField(
                controller: cityUpdateController,
                validator: (val) {
                  return (val!.isEmpty) ? "Enter city first" : null;
                },
                onSaved: (val) {
                  setState(
                    () {
                      city = val;
                    },
                  );
                },
                decoration: const InputDecoration(labelText: "City"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (updateFormKey.currentState!.validate()) {
                updateFormKey.currentState!.save();

                int id = await DBHelper.dbHelper.updateRecord(
                    name: name!,
                    age: age!,
                    city: city!,
                    //  image: result!,
                    id: data.id!);

                if (id > 0) {
                  print("--------------------------------");
                  print("Recorde updated successfully with id of $id");
                  print("---------------------------------");

                  setState(() {
                    getAllStudents = DBHelper.dbHelper.fetchAllRecords();
                  });
                } else {
                  print("---------------------------------");
                  print("Record updated failed.........");
                  print("----------------------------------");
                }
              }

              nameUpdateController.clear();
              ageUpdateController.clear();
              cityUpdateController.clear();
              setState(
                () {
                  name = null;
                  age = null;
                  city = null;
                  // image = null;
                },
              );
              Navigator.of(context).pop();
            },
            child: const Text("Insert"),
          ),
          ElevatedButton(
            onPressed: () {
              nameUpdateController.clear();
              ageUpdateController.clear();
              cityUpdateController.clear();
              setState(
                () {
                  name = null;
                  age = null;
                  city = null;
                  //  image = null;
                },
              );
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          )
        ],
      ),
    );
  }
}
