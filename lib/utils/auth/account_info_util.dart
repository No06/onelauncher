import 'package:dio/dio.dart';
import 'package:one_launcher/models/account/profile.dart';

class AccountInfoUtil {
  AccountInfoUtil(String jwtToken)
      : dio = Dio(BaseOptions(headers: {"Authorization": "Bearer $jwtToken"}));

  final Dio dio;

  Future<Profile> getProfile() async {
    //TODO: 解析皮肤
    const url = "https://api.minecraftservices.com/minecraft/profile";
    var response = await dio.get(url);
    return Profile.fromJson(response.data);
  }
}
