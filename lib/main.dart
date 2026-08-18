import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_recommendation_app/app/app.dart';
import 'package:meal_recommendation_app/features/grocery_list/data/grocery_checklist_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: 'assets/.env',
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: TipidMealApp(),
    ),
  );

  // Fire-and-forget — don't block first frame on this.
  GroceryChecklistStorage.cleanupOldWeeks();
}