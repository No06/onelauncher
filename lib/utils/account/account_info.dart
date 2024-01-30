import 'package:dio/dio.dart';

class AccountInfoUtil {
  AccountInfoUtil(String jwtToken)
      : dio = Dio(BaseOptions(headers: {"Authorization": "Bearer $jwtToken"}));

  final Dio dio;

  late String uuid;
  late String name;

  Future<void> getProfile() async {
    //TODO: 解析皮肤
    const url = "https://api.minecraftservices.com/minecraft/profile";
    var response = await dio.get(url);
    uuid = response.data['id'];
    name = response.data['name'];
  }
}
