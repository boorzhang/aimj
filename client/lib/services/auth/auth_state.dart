/// 鉴权状态 - 不可变
class AuthState {
  final bool loggedIn;
  final String? token;
  final UserProfile? user;

  const AuthState({this.loggedIn = false, this.token, this.user});

  AuthState copyWith({bool? loggedIn, String? token, UserProfile? user}) {
    return AuthState(
      loggedIn: loggedIn ?? this.loggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class UserProfile {
  final int id;
  final String phone;
  final String nickname;
  final String avatar;
  final int coins;

  const UserProfile({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatar = '',
    this.coins = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      phone: json['phone'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      coins: json['coins'] as int? ?? 0,
    );
  }

  UserProfile copyWith({int? coins, String? nickname}) {
    return UserProfile(
      id: id,
      phone: phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar,
      coins: coins ?? this.coins,
    );
  }
}
