import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/online_skin.dart';
import 'package:one_launcher/models/json_map.dart';
part 'profile.g.dart';

@JsonSerializable(includeIfNull: false, createFactory: true)
class Profile {
  Profile(this.id, this.name, this.skins);

  final String id;
  final String name;
  final List<OnlineSkin> skins;

  //capes
  factory Profile.fromJson(JsonMap json) => _$ProfileFromJson(json);
}
