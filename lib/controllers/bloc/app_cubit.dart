import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../models/db/database.dart';
import '../../models/task.dart';
import '../../services/notification_services.dart';
import '../../services/shared_preferences.dart';
import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitLogin());
  static AppCubit get(context) => BlocProvider.of(context);

  bool moodl = (CachHelper.getData(key: "mood") == null)
      ? true
      : CachHelper.getData(key: "mood");
  void changMood(value) {
    moodl = value;
    CachHelper.setData(key: "mood", value: moodl).then((value) {
      emit(Mood());
    });
    print('l mood is $moodl');
  }

  DateTime selectedData = DateTime.now();
  void changSelectedDate(DateTime date) {
    selectedData = date;
    emit(ChangSelectedDate());
    print('l mood is $moodl');
  }

  DataBase db = DataBase();
  createDataBase() async {
    await db.createDB();
    emit(ScCreateDB());
  }

  NotifyHelper notifyHelper = NotifyHelper();
  initializeNotification(BuildContext context) async {
    await notifyHelper.initializeNotification(context);
    notifyHelper.requestIOSPermissions();
    emit(ScInitNots());
  }

  List<Task> taskList = [Task()];
  getTask() async {
    emit(LoadingGetTasks());
    taskList = [];
    List<Map<dynamic, dynamic>> tasks = await db.getTableDataFromDB();
    for (var element in tasks) {
      Task t = Task.fromJason(element);
      taskList.add(t);
    }
    emit(ScGetTasks());
  }

  Future<int> addTask(Task t) async {
    int id = await t.insertMeToDb();
    emit(ScAddTask());
    return id;
  }

  void deleteTask(Task task) async {
    db.deletItemFromDB(task.id!);
    taskList.remove(task);
    emit(ScRemoveTask());
  }

  void updateTask(Task t) async {
    await db.update(t);
    await notifyHelper.cancelNotification(t);
    if (taskList.contains(t)) {
      int i = taskList.indexOf(t);
      taskList[i].isCompleted = 1;
    }
    emit(ScUpdateTask());
  }

  Future<void> deleteAllTask() async {
    db.deletAll();
    await notifyHelper.cancelAllNotification();
    taskList = [];
    emit(ScRemoveAllTask());
  }

  bool showTask(Task task) {
    return (task.repeat == "Daily" ||
        DateFormat.yMd().format(selectedData) == task.date ||
        (task.repeat == "weekly" &&
            selectedData.difference(DateFormat.yMd().parse(task.date!)).inDays %
                    7 ==
                0) ||
        (task.repeat == "Monthly" &&
            DateFormat.yMd().parse(task.date!).day == selectedData.day));
  }

  saveAnddisplayNotification(Task t) {
    taskList.add(t);
    var d = DateFormat.yMd().parse(t.date!);
    notifyHelper.displayNotification(
        title: t.title!, body: t.note!, startTime: t.startTime);
    notifyHelper.scheduledNotification(d.hour, d.minute, t);
    emit(SaveAndDisplayNotification());
  }
}
