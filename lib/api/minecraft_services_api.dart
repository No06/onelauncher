import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/models/account/skin/online_skin.dart';
import 'package:one_launcher/models/json_map.dart';

part 'minecraft_services_api.g.dart';

class MinecraftServicesApi {
  MinecraftServicesApi(String mcAccessToken)
      : dio = createDio(
          BaseOptions(
            baseUrl: "https://api.minecraftservices.com",
            headers: {"Authorization": "Bearer $mcAccessToken"},
          ),
        );

  final Dio dio;

  Future<Profile> requestProfile({CancelToken? cancelToken}) async {
    const path = "/minecraft/profile";
    final response = await dio.get<JsonMap>(path, cancelToken: cancelToken);
    final respData = response.data;
    if (respData == null) {
      throw Exception("请求失败");
    }
    return Profile.fromJson(respData);
  }
}

@JsonSerializable(includeIfNull: false, createToJson: false)
class Profile {
  Profile(this.id, this.name, this.skins);

  factory Profile.fromJson(JsonMap json) => _$ProfileFromJson(json);

  final String id;
  final String name;
  final List<OnlineSkin> skins;
}
