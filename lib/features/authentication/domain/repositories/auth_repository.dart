import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> resetPassword({ 
    required String email, 
  });

  Future<void> signOut();

  User? getCurrentUser();

  String? getAccessToken();

  Stream<AuthState> get authStateChanges;
}