/// 账号登录信息
class AccountLoginInfo {
  const AccountLoginInfo({
    required this.username,
    required this.uuid,
    this.accessToken = "",
  });

  static const String userType = "msa";

  final String username;
  final String uuid;
  final String accessToken;
}
