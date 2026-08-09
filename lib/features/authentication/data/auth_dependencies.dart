import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:meal_recommendation_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:meal_recommendation_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref){
  return Supabase.instance.client;
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref){
  return AuthRemoteDatasource(
    supabase: ref.watch(supabaseClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref){
  return AuthRepositoryImpl(
    datasource: ref.watch(authRemoteDatasourceProvider),
  );
});