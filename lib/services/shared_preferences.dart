import 'package:shared_preferences/shared_preferences.dart';

class CachHelper{
  static late  SharedPreferences shared;
  static inti()async{
    shared=await SharedPreferences.getInstance();
  }
  static Future<bool> setData({
    required String key,
    required dynamic value,
  }){
    if(value is String) return shared.setString(key, value);
    if(value is int) return shared.setInt(key, value);
    if(value is bool) return shared.setBool(key, value);
    return shared.setString(key, value);
  }
  static dynamic getData({
    required String key,
  }){
    return  shared.get(key);
  }
  static Future<bool> removeData({
    required  String key,
  }){
   return shared.remove(key);
  }
}