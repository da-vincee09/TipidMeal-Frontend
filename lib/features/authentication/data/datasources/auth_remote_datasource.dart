import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDatasource {

  final SupabaseClient _supabase;

  AuthRemoteDatasource({
    required this._supabase
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password
    );
  }

  Future<void> resetPassword({ 
    required String email, 
  }) { 
    return _supabase.auth.resetPasswordForEmail(email); 
  }
  
  Future<void> signOut() {
    return _supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  String? getAccessToken() {
    return _supabase.auth.currentSession?.accessToken;
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}