import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:note_app/boxes/box.dart';
import 'package:note_app/crud_operations.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/notify_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  Color? tileColor= Colors.white;
  List<Map> status = [
    {"isChecked": false},
  ];

  double progress = 0.0;
  currentProgressColor() {
    if (progress >= 0.0 && progress <= 0.4) {
      return Colors.red;
    }
    if(progress > 0.4 && progress <= 0.7 ){
      return Colors.orange;
    }
    else{
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:

      Column(
        children: [
          Center(
              child: Container(
                margin: const EdgeInsets.only(top: 50.0),
                child: CircularPercentIndicator(
                  radius: 100,
                  lineWidth: 20,
                  percent: progress,
                  animation: true,
                  animationDuration: 1000,
                  animateFromLastPercent: true,
                  progressColor: currentProgressColor(),
                  backgroundColor: Colors.blue.shade100,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: const Icon(Icons.task_alt_rounded, size: 50, color: Colors.blue,
                  ),

                ),
              )),
          const SizedBox(height: 50,),
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            child: ValueListenableBuilder<Box<NoteModel>>(
              valueListenable: Boxes.getData().listenable(),
              builder: (context, box, _){
                var data= box.values.toList().cast<NoteModel>();
                return ListView.builder(
                  itemCount: box.length,
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    return GestureDetector(
                      onDoubleTap:(){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const CrudOperations()),);
                      } ,

                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                            status.map((key) {
                                  return CheckboxListTile(
                                    controlAffinity: ListTileControlAffinity.leading,
                                    value: key["isChecked"],
                                    tileColor: tileColor,
                                    title: Text(data[index].title.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                    subtitle: Text(data[index].description.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                                    onChanged: (value) {

                                      setState(() {
                                          key["isChecked"] = value;
                                          if(key["isChecked"]== true){
                                            final updated = ((progress + 0.1).clamp(0.0, 1.0) * 100);
                                            tileColor = Colors.blue.shade200;
                                            progress = updated.round() / 100;
                                          }
                                          else{
                                            final updated = ((progress - 0.1).clamp(0.0, 1.0) * 100);
                                            tileColor = Colors.white;
                                            progress = updated.round() / 100;
                                          }
                                        });
                                    },

                                  );
                              }).toList(),
                          ),
                        ),
                      ),
                      /*
                      ListTile(
                                     leading: Checkbox(
                                      value: status[key],
                                   onChanged: (bool? value) {
                                        setState(() {
                                          status[key]= value!;
                                        });
                                   },
                                ),
                            title: Text(data[index].title.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                            subtitle: Text(data[index].description.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                               );

                      child :Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CheckboxListTile(value: is_Checked,
                              controlAffinity: ListTileControlAffinity.leading,
                              title : Text(data[index].title.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
                              subtitle : Text(data[index].description.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
                                onChanged: (value){
                              setState(() {
                                is_Checked = value!;
                              });
                            }),
                          ],
                        ),
                      ),*/
                    );
                  },
                );
              },
            ),
          ),
        ],
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
