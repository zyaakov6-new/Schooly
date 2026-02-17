class AppConstants {
  // App info
  static const String appName = 'FamilyOS';
  static const String appVersion = '1.0.0';

  // Firebase collections
  static const String familiesCollection = 'families';
  static const String childrenCollection = 'children';
  static const String eventsCollection = 'events';
  static const String tasksCollection = 'tasks';
  static const String inboxCollection = 'inbox';
  static const String usersCollection = 'users';

  // Shared preferences keys
  static const String keyFamilyId = 'familyId';
  static const String keyUserId = 'userId';
  static const String keyThemeMode = 'themeMode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingDone = 'onboardingDone';
  static const String keyNotificationsEnabled = 'notificationsEnabled';

  // Deep link scheme
  static const String deepLinkScheme = 'familyos';
  static const String deepLinkJoinPath = 'join';

  // Invite code length
  static const int inviteCodeLength = 6;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Pagination
  static const int pageSize = 20;

  // Shimmer
  static const int shimmerItemCount = 5;

  // Notification channels
  static const String channelDailyId = 'daily_summary';
  static const String channelReminderId = 'reminders';
  static const String channelTaskId = 'tasks';

  // Supported locales
  static const List<String> supportedLanguages = ['he', 'en'];
  static const String defaultLanguage = 'he';

  // Max limits
  static const int maxChildren = 8;
  static const int maxFamilyMembers = 10;
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String createFamily = '/auth/create-family';
  static const String addChild = '/auth/add-child';
  static const String dashboard = '/home';
  static const String calendar = '/calendar';
  static const String tasks = '/tasks';
  static const String kids = '/kids';
  static const String profile = '/profile';
  static const String childDetail = '/kids/:id';
  static const String addEvent = '/events/add';
  static const String addTask = '/tasks/add';
  static const String inbox = '/inbox';
  static const String settings = '/settings';
  static const String familySettings = '/settings/family';
  static const String joinFamily = '/join/:code';
}
