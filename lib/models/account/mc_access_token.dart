import 'package:one_launcher/utils/auth/mc_auth.dart';
import 'package:one_launcher/utils/seconds_since_epoch.dart';

class MinecraftAccessToken {
  MinecraftAccessToken({
    required String accessToken,
    required String refreshToken,
    required int notAfter,
  })  : _accessToken = accessToken,
        _refreshToken = refreshToken,
        _notAfter = notAfter;

  String _accessToken;
  int _notAfter; // accessToken 过期时间戳
  String _refreshToken; // MicrosoftRefreshToken

  /// 使用前需调用 [isExpired] 检查有效性
  ///
  /// 密钥过期后应先执行 [refreshAccessToken] 再获取密钥
  String get accessToken => _accessToken;

  String get refreshToken => _refreshToken;

  int get notAfter => _notAfter;

  bool get isExpired => secondsSinceEpoch >= notAfter;

  Future<void> refreshAccessToken() async {
    final response = await MinecraftAuth.loginWithRefreshToken(refreshToken);
    _accessToken = response.accessToken;
    _notAfter = validityToExpiredTime(response.expiresIn);
  }

  // +60 提早一分钟过期
  static int validityToExpiredTime(int expiresIn) =>
      secondsSinceEpoch - 60 + expiresIn;
}
