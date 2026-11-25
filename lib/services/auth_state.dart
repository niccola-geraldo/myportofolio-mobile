import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._apiClient);

  final ApiClient _apiClient;
  String? _token;
  Future<void>? _pendingLogout;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;
    await (_pendingLogout ??= _revokeToken(current));
  }

  Future<void> _revokeToken(String current) async {
    try {
      await _apiClient.logout(token: current);
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;
    } finally {
      _pendingLogout = null;
      if (_token == current) {
        _token = null;
        notifyListeners();
      }
    }
  }
}
