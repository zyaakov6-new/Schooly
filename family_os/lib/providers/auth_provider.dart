import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

// Core Firebase service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});

// Current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Family ID from prefs/Firestore
final familyIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getString(AppConstants.keyFamilyId);
  if (cached != null) return cached;

  final service = ref.watch(firebaseServiceProvider);
  final id = await service.getUserFamilyId(user.uid);

  if (id != null) {
    await prefs.setString(AppConstants.keyFamilyId, id);
  }
  return id;
});

// Theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, int>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<int> {
  ThemeModeNotifier() : super(0) {
    _load();
  }

  // 0 = system, 1 = light, 2 = dark
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(AppConstants.keyThemeMode) ?? 0;
  }

  Future<void> setMode(int mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyThemeMode, mode);
  }
}

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(AppConstants.defaultLanguage) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
  }

  Future<void> setLocale(String locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, locale);
  }
}

// Onboarding state
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
});
