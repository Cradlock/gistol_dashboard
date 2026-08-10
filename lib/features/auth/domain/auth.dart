
import 'package:gistol_dashboard/core/api/domain.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/auth/domain/user.dart';






class RefreshRequest implements ToJsonable {
    final String _refresh_token;
    

    const RefreshRequest({required this._refresh_token});

    @override
    Map<String,dynamic> toJson(){ 
      return {
        "refresh_token":_refresh_token
      };
    }


}

class RefreshResponse {
    final String _access_token;
    final String _refresh_token;

    String get access_token => _access_token;
    String get refresh_token => _refresh_token;

    RefreshResponse({required this._access_token,required this._refresh_token});

    factory RefreshResponse.fromJson(Map<String,dynamic>? json) {
      if (json == null || !json.containsKey('access_token') || !json.containsKey('refresh_token')) {
        throw const ServerTroubleException();
      }

      return RefreshResponse(
        access_token: json["access_token"],
        refresh_token: json["refresh_token"]
      );
    }
}


class AuthSignRequest implements ToJsonable {
  final String _username;
  final String _password;

  AuthSignRequest({required this._username,required this._password});
    
  @override
  Map<String,dynamic> toJson(){ 
      return {
        "code":_username,
        "password":_password
      };
    }

 

}




class AuthSignResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthSignResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSignResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null ||
        !json.containsKey('access_token') ||
        !json.containsKey('refresh_token') ||
        !json.containsKey('user')) {
      throw const ServerTroubleException();
    }

    return AuthSignResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>?),
    );
  }
}
