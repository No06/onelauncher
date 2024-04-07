import 'package:dio/dio.dart';
import 'package:one_launcher/utils/auth/profile.dart';

class AccountInfoUtil {
  AccountInfoUtil(String minecraftAccessToken)
      : dio = Dio(
          BaseOptions(
            headers: {"Authorization": "Bearer $minecraftAccessToken"},
          ),
        );

  final Dio dio;

  Future<Profile> getProfile() async {
    //TODO: 解析皮肤
    const url = "https://api.minecraftservices.com/minecraft/profile";
    var response = await dio.get(url);
    return Profile.fromJson(response.data);
  }
}
