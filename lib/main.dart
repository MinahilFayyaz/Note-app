import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:note_app/boxes/box.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notify_services.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox<NoteModel>('notes');

  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hive Note App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController controllerTitle= TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerDate = TextEditingController();
  TextEditingController controllerTime = TextEditingController();

  late String msg;

  /*late FlutterLocalNotificationsPlugin localNotification;

  @override
  void initState(){
    super.initState();
    var androidInitialize = const AndroidInitializationSettings('ic_launcher');
    var iosInitialize= const IOSInitializationSettings();
    var initializationSettings= InitializationSettings(
      android: androidInitialize, iOS: iosInitialize);
    localNotification= FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);
  }

  Future _showNotification() async{
    var androidDetails= const AndroidNotificationDetails(
        "channelId",
        "Local Notification",
        "Notification Description",
    importance: Importance.high);

    var iosDetails= const IOSNotificationDetails();
    var generalNotificationDetais= NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(0, "Hello ", 'notify you', generalNotificationDetais);

  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ValueListenableBuilder<Box<NoteModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _){
          var data= box.values.toList().cast<NoteModel>();
          return ListView.builder(
            itemCount: box.length,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index){
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(data[index].title.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
                          const Spacer(),
                          InkWell(
                            onTap: (){
                              delete(data[index]);
                            },child: const Icon(Icons.delete,size: 25.0,),
                          ),
                          InkWell(
                            onTap: (){
                              _editDialog(data[index], data[index].title.toString(), data[index].description.toString(), data[index].date.toString(), data[index].time.toString());
                            },child: const Icon(Icons.edit, size: 25.0,),
                          ),
                        ],
                      ),
                      Text(data[index].description.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
                      Text(data[index].date.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          _showDialog();
        },
        tooltip: 'Add a Note',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void delete(NoteModel noteModel) async {

    await noteModel.delete();
  }

  Future<void> _editDialog(NoteModel noteModel, String title, String description, var date, var time)async {

    controllerTitle.text = title;
    controllerDescription.text = description;
    controllerDate.text = date;
    controllerTime.text= time;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Note'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: controllerTitle,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Title',
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerDescription,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Note',
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerDate,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Date',
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerTime,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Time',
                        border: OutlineInputBorder()
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: const Text("Cancel")),
              TextButton(onPressed: () {

                noteModel.title= controllerTitle.text.toString();
                noteModel.description= controllerDescription.text.toString();
                noteModel.date= controllerDate.text.toString();
                noteModel.time= controllerTime.text.toString();

                noteModel.save();
                controllerTitle.clear();
                controllerDescription.clear();
                //_showNotification();
                Navigator.pop(context);
              }, child: const Text("Edit Note"))
            ],
          );
        }
    );
  }

  Future<void> _showDialog()async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Notes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: controllerTitle,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Title',
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerDescription,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Note',
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerDate,
                    decoration: const InputDecoration(
                        hintText: 'Enter the Date',
                        border: OutlineInputBorder()
                    ),
                    readOnly: true,
                    onTap: () async{
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2200)
                      );
                      if(pickedDate!=null){
                        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          controllerDate.text = formattedDate;
                        });
                      }else {
                        msg = 'Date is not selected';
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: controllerTime,
                    decoration: const InputDecoration(
                        hintText: 'Enter the Time',
                        border: OutlineInputBorder()
                    ),
                    readOnly: true,
                    onTap: () async{
                      TimeOfDay? pickedTime =  await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now());
                      if(pickedTime != null ){  //output 10:51 PM
                        // ignore: use_build_context_synchronously
                        DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context).toString());
                        String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);

                        setState(() {
                          controllerTime.text = formattedTime; //set the value of text field.
                        });
                      }else{
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: const Text("Cancel")),
              TextButton(onPressed: () {

                final data = NoteModel(title: controllerTitle.text, description: controllerDescription.text, date: controllerDate.text, time: controllerTime.text);
                final box = Boxes.getData();

                //_showNotification();
                box.add(data);
                //_showNotification();
                NotificationService().showNotification(title: 'Test Notification', body: 'Just a random notification');
                //data.save();
                controllerTitle.clear();
                controllerDescription.clear();
                controllerDate.clear();
                controllerTime.clear();

                Navigator.pop(context);
              }, child: const Text("Add Note"))
            ],
          );
        }
    );
  }
}

