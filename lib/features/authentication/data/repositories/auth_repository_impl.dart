import 'package:meal_recommendation_app/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:meal_recommendation_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({
    required this._datasource
  });

  @override
  Future<AuthResponse> signUp({
    required String email, 
    required String password
  }) {
   return _datasource.signUp(
    email: email, 
    password: password
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email, 
    required String password
  }) {
    return _datasource.signIn(
      email: email, 
      password: password
    );
  }

  @override Future<void> resetPassword({ 
    required String email, 
  }) async { 
    await _datasource.resetPassword( 
      email: email, 
    ); 
  }

  @override
  Future<void> signOut() {
    return _datasource.signOut();
  }

  @override
  User? getCurrentUser() { 
    return _datasource.getCurrentUser();
  }


  @override
  String? getAccessToken() {
    return _datasource.getAccessToken();
  }

  @override
  Stream<AuthState> get authStateChanges {
    return _datasource.authStateChanges;
  }
}