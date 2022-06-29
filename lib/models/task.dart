import 'package:todo_app/models/db/database.dart';

class Task {
  int? id;
  String? title;
  String? note;
  int? isCompleted;
  String? date;
  String? startTime;
  String? endTime;
  int? color;
  int? remind;
  String? repeat;
  DataBase db = DataBase();
  Task(
      {this.id,
      this.color,
      this.date,
      this.endTime,
      this.isCompleted,
      this.note,
      this.remind,
      this.repeat,
      this.startTime,
      this.title});
  Task.fromJason(Map<dynamic, dynamic> task) {
    id = task["id"] as int;
    color = task["color"] as int;
    remind = task["remind"] as int;
    isCompleted = task["isCompleted"] as int;
    repeat = task["repeat"].toString();
    title = task["title"].toString();
    note = task["note"].toString();
    date = task["date"].toString();
    endTime = task["endTime"].toString();
    startTime = task["startTime"].toString();
  }
  Map<String, Object> toMap() {
    return {
      "color": color!,
      "date": date!,
      "endTime": endTime!,
      "isCompleted": isCompleted!,
      "note": note!,
      "remind": remind!,
      "repeat": repeat!,
      "startTime": startTime!,
      "title": title!,
    };
  }

  Future<int> insertMeToDb() async {
    return await db.insertPersonDataToDB(this);
  }

  void setId(int id) {
    this.id = id;
  }
}
