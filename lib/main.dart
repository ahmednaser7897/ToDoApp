
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_app/controllers/bloc/app_states.dart';
import 'package:todo_app/ui/theme.dart';


import 'controllers/bloc/app_cubit.dart';
import 'controllers/bloc/observer.dart';

import 'services/shared_preferences.dart';
import 'ui/pages/home_page.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await CachHelper.inti();

   BlocOverrides.runZoned(() {runApp(const MyApp(),);
  }, blocObserver: MyBlocObserver());

  
}
final navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
      create:  (ctx) =>AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder:(context, state) {
          AppCubit cubit=AppCubit.get(context);
          return MaterialApp(
          theme:Themes.light,
          darkTheme: Themes.dark,
          themeMode: cubit.moodl? ThemeMode.light :ThemeMode.dark ,
          title: 'TODO',
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
        );
        },
      ),
    );
  }
}
