import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../controller/locale_controller.dart';
import '../../view/screen/auth_login_page.dart';
import '../../view/screen/auth_signup_page.dart';
import '../../view/screen/access_denied_page.dart';
import '../../view/screen/cabinet_create_page.dart';
import '../../view/screen/cabinet_search_page.dart';
import '../../view/screen/cabinet_select_page.dart';
import '../../view/screen/home_page.dart';
import '../../view/screen/patient_list_page.dart';
import '../../view/screen/patient_create_page.dart';
import '../../view/screen/landing_page.dart';
import '../../view/screen/language_picker_page.dart';
import '../../view/screen/not_found_page.dart';
import '../../view/screen/timeout_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: LocaleController.instance.hasSelection ? '/' : '/language',
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (context, state) {
      final hasSelection = LocaleController.instance.hasSelection;
      final isOnLanguage = state.matchedLocation == '/language';
      if (!hasSelection && !isOnLanguage) return '/language';
      if (hasSelection && isOnLanguage) return '/';

      final isAuthed = AuthController.globalUserId != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isProtected = state.matchedLocation.startsWith('/home') ||
          state.matchedLocation.startsWith('/cabinet') ||
          state.matchedLocation.startsWith('/patients');
      if (!isAuthed && isProtected) return '/auth/login';
      if (isAuthed && isAuthRoute) return '/cabinet/select';
      return null;
    },
    routes: [
      GoRoute(
        path: '/language',
        pageBuilder: (context, state) => const NoTransitionPage(child: LanguagePickerPage()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const NoTransitionPage(child: LandingPage()),
      ),
      GoRoute(path: '/auth', redirect: (context, state) => '/auth/login'),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: AuthLoginPage()),
      ),
      GoRoute(
        path: '/auth/signup',
        pageBuilder: (context, state) => const NoTransitionPage(child: AuthSignupPage()),
      ),
      GoRoute(
        path: '/access-denied',
        pageBuilder: (context, state) => const NoTransitionPage(child: AccessDeniedPage()),
      ),
      GoRoute(
        path: '/cabinet/search',
        pageBuilder: (context, state) => const NoTransitionPage(child: CabinetSearchPage()),
      ),
      GoRoute(
        path: '/cabinet/create',
        pageBuilder: (context, state) => const NoTransitionPage(child: CabinetCreatePage()),
      ),
      GoRoute(
        path: '/cabinet/select',
        pageBuilder: (context, state) => const NoTransitionPage(child: CabinetSelectPage()),
      ),
      GoRoute(
        path: '/patients/list',
        pageBuilder: (context, state) => const NoTransitionPage(child: PatientListPage()),
      ),
      GoRoute(
        path: '/patients/create',
        pageBuilder: (context, state) => const NoTransitionPage(child: PatientCreatePage()),
      ),
      GoRoute(
        path: '/patients/edit',
        pageBuilder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          return NoTransitionPage(child: PatientCreatePage(patient: patient));
        },
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: '/timeout',
        pageBuilder: (context, state) => const NoTransitionPage(child: TimeoutPage()),
      ),
    ],
  );
});
