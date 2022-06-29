import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/ui/pages/add_task_page.dart';
import 'package:todo_app/ui/size_config.dart';
import 'package:todo_app/ui/widgets/task_tile.dart';

import '../../controllers/bloc/app_cubit.dart';
import '../../controllers/bloc/app_states.dart';
import '../theme.dart';
import '../widgets/button.dart';
import '../widgets/home_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    AppCubit cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is ScCreateDB) {
          cubit.initializeNotification(context);
          cubit.getTask();
        }
      },
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          backgroundColor:
              !cubit.moodl ? Theme.of(context).backgroundColor : Colors.white,
          appBar: appBar(context),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                addTaskBar(context),
                addDateBar(context),
                const SizedBox(
                  height: 10,
                ),
                showTasks(context),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar appBar(context) {
    AppCubit cubit = AppCubit.get(context);
    return AppBar(
      elevation: 0,
      backgroundColor:
          !cubit.moodl ? Theme.of(context).backgroundColor : Colors.white,
      leading: IconButton(
        color: cubit.moodl ? darkHeaderClr : Colors.white,
        icon: Icon(
          !cubit.moodl
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round_outlined,
          size: 24,
        ),
        onPressed: () {
          cubit.changMood(!cubit.moodl);
        },
      ),
      actions: [
        IconButton(
          color: cubit.moodl ? darkHeaderClr : Colors.white,
          icon: const Icon(
            Icons.cleaning_services_outlined,
            size: 24,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: const Text(
                      "Remove All Nots",
                      style: TextStyle(color: Colors.red),
                    ),
                    content: const Text(
                      "Are you sure you want to delete all notes?",
                      style: TextStyle(color: Colors.red),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          cubit.deleteAllTask();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "YES",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "NO",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(
              "assets/images/person.png",
            ),
          ),
        ),
      ],
    );
  }

  Widget addTaskBar(context) {
    AppCubit cubit = AppCubit.get(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(cubit.selectedData),
                style: Themes.titleStyle,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "Today : ${DateFormat.yMMMMd().format(DateTime.now())}",
                style: Themes.supTitleStyle,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        DefaultButton(
          onPress: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddTaskPage()));
          },
          label: "+ Add Task",
        ),
      ],
    );
  }

  Widget addDateBar(context) {
    AppCubit cubit = AppCubit.get(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        width: 80,
        height: 80,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle:
            Themes.headingStyle.copyWith(color: Colors.grey, fontSize: 20),
        dayTextStyle:
            Themes.headingStyle.copyWith(color: Colors.grey, fontSize: 16),
        monthTextStyle:
            Themes.headingStyle.copyWith(color: Colors.grey, fontSize: 12),
        onDateChange: (DateTime newDate) {
          cubit.changSelectedDate(newDate);
        },
      ),
    );
  }

  Widget showTasks(context) {
    AppCubit cubit = AppCubit.get(context);
    return Expanded(
      child: (cubit.taskList.isEmpty)
          ? noTasks(context)
          : RefreshIndicator(
              onRefresh: () async {
                cubit.getTask();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: SizeConfig.orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                itemCount: cubit.taskList.length,
                separatorBuilder: (BuildContext context, intindix) =>
                    const SizedBox(
                  height: 10,
                ),
                itemBuilder: (BuildContext context, int indix) {
                  Task task = cubit.taskList[indix];
                  if (cubit.showTask(task)) {
                    var h =
                        task.startTime.toString().split(" ")[0].split(":")[0];
                    var m =
                        task.startTime.toString().split(" ")[0].split(":")[0];
                    cubit.notifyHelper.scheduledNotification(
                        int.parse(h), int.parse(m), task);
                    return AnimationConfiguration.staggeredList(
                      position: indix,
                      duration: const Duration(seconds: 1),
                      child: SlideAnimation(
                        horizontalOffset: SizeConfig.screenWidth * 0.75,
                        child: FadeInAnimation(
                          child: InkWell(
                            onTap: () {
                              showMyBottomSheet(context, task);
                              print("ok");
                            },
                            child: TaskTile(task: task),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
    );
  }
}
