import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controller/auth_controller.dart';
import '../../controller/locale_controller.dart';
import '../../view/screen/auth_login_page.dart';
import '../../view/screen/auth_signup_page.dart';
import '../../view/screen/forgot_password_page.dart';
import '../../view/screen/access_denied_page.dart';
import '../../view/screen/admin_clinic_validation_page.dart';
import '../../view/screen/appointment_create_page.dart';
import '../../view/screen/appointment_list_page_v2.dart';
import '../../view/screen/cabinet_create_page.dart';
import '../../view/screen/cabinet_search_page.dart';
import '../../view/screen/cabinet_select_page.dart';
import '../../view/screen/consultation_page.dart';
import '../../view/screen/clinic_log_page.dart';
import '../../view/screen/home_page.dart';
import '../../view/screen/patient_list_page.dart';
import '../../view/screen/patient_create_page.dart';
import '../../view/screen/landing_page.dart';
import '../../view/screen/language_picker_page.dart';
import '../../view/screen/not_found_page.dart';
import '../../view/screen/profile_page.dart';
import '../../view/screen/settings_page.dart';
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
      final isProtected =
          state.matchedLocation.startsWith('/home') ||
          state.matchedLocation.startsWith('/cabinet') ||
          state.matchedLocation.startsWith('/patients') ||
          state.matchedLocation.startsWith('/appointments') ||
          state.matchedLocation.startsWith('/consultations') ||
          state.matchedLocation.startsWith('/logs') ||
          state.matchedLocation.startsWith('/settings') ||
          state.matchedLocation.startsWith('/admin');
      if (!isAuthed && isProtected) return '/auth/login';
      if (isAuthed && isAuthRoute) {
        if (AuthController.isPlatformAdmin) return '/admin/clinics';
        return '/cabinet/select';
      }
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
        path: '/auth/forgot',
        pageBuilder: (context, state) => const NoTransitionPage(child: ForgotPasswordPage()),
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
        pageBuilder: (context, state) {
          final pickerMode = state.uri.queryParameters['picker'] == '1';
          return NoTransitionPage(
            child: PatientListPage(pickerMode: pickerMode),
          );
        },
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
        path: '/appointments/list',
        pageBuilder: (context, state) => const NoTransitionPage(child: AppointmentListPageV2()),
      ),
      GoRoute(
        path: '/appointments/create',
        pageBuilder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          return NoTransitionPage(child: AppointmentCreatePage(initialPatient: patient));
        },
      ),
      GoRoute(
        path: '/consultations',
        pageBuilder: (context, state) {
          final patient = state.extra as Map<String, dynamic>?;
          return NoTransitionPage(child: ConsultationPage(initialPatient: patient));
        },
      ),
      GoRoute(
        path: '/logs/clinic',
        pageBuilder: (context, state) => const NoTransitionPage(child: ClinicLogPage()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
      ),
      GoRoute(
        path: '/admin/clinics',
        pageBuilder: (context, state) => const NoTransitionPage(child: AdminClinicValidationPage()),
      ),
      GoRoute(
        path: '/timeout',
        pageBuilder: (context, state) => const NoTransitionPage(child: TimeoutPage()),
      ),
    ],
  );
});
