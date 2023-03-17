import 'package:hive/hive.dart';
part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {

  @HiveField(0)
  String title;
  @HiveField(1)
  String description;
  @HiveField(2)
  // ignore: prefer_typing_uninitialized_variables
  var date;

  @HiveField(3)
  // ignore: prefer_typing_uninitialized_variables
  var time;

  NoteModel ({required this.title, required  this.description, required this.date, required this.time } );
}