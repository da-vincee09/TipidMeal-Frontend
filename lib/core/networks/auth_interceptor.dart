import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
 
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
 
    handler.next(options);
  }
}