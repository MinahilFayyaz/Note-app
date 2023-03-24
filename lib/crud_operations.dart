
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_app/boxes/box.dart';
import 'package:note_app/models/note_model.dart';


TextEditingController controllerTitle= TextEditingController();
TextEditingController controllerDescription = TextEditingController();
TextEditingController controllerDate = TextEditingController();
TextEditingController controllerTime = TextEditingController();


class CrudOperations extends StatefulWidget {
  const CrudOperations({Key? key}) : super(key: key);

  @override
  State<CrudOperations> createState() => _CrudOperationsState();
}

class _CrudOperationsState extends State<CrudOperations> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Details'),
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
                          Text(data[index].title.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
                          const Spacer(),
                          InkWell(
                            onTap: (){
                              delete(data[index]);
                            },child: const Icon(Icons.delete,size: 28.0,),
                          ),
                          InkWell(
                            onTap: (){
                              _editDialog(data[index], data[index].title.toString(), data[index].description.toString(), data[index].date.toString(), data[index].time.toString());
                            },child: const Icon(Icons.edit, size: 28.0,),
                          ),
                        ],
                      ),
                      Text(data[index].description.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                      Text(data[index].date.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
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
      },
    );
  }



}








void delete(NoteModel noteModel) async {

  await noteModel.delete();
}


