import 'package:go_router/go_router.dart';

import '../core/auth/auth_gate.dart';
import '../core/widgets/not_found_screen.dart';
import '../design_system/pages/design_system_preview_page.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/communities/presentation/pages/communities_page.dart';
import '../features/doctor_network/presentation/pages/doctor_public_profile_page.dart';
import '../features/doctor_network/presentation/pages/doctor_search_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/organizations/presentation/pages/organizations_page.dart';
import '../features/professional_identity/presentation/pages/doctor_profile_page.dart';
import '../features/professional_identity/presentation/pages/edit_profile_page.dart';
import '../features/professional_identity/presentation/pages/profile_completion_page.dart';

/// Central GoRouter configuration.
///
/// The router watches [AuthGate] so redirects react to auth state changes
/// without touching secure storage on every navigation. Unauthenticated
/// users are pushed to `/login`; authenticated users never see it.
class AppRouter {
  AppRouter({required AuthGate authGate}) {
    _router = GoRouter(
      initialLocation: rootRoute,
      refreshListenable: authGate,
      redirect: (context, state) => _redirect(authGate.value, state),
      routes: [
        GoRoute(
          path: rootRoute,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: loginRoute,
          name: 'login',
          builder: (context, state) => const AuthPage(),
        ),
        // TODO(design-system): remove once real screens land.
        GoRoute(
          path: DesignSystemPreviewPage.routePath,
          name: DesignSystemPreviewPage.routeName,
          builder: (context, state) => const DesignSystemPreviewPage(),
        ),
        GoRoute(
          path: profileRoute,
          name: 'profile',
          builder: (context, state) => const DoctorProfilePage(),
        ),
        GoRoute(
          path: completeProfileRoute,
          name: 'profile-complete',
          builder: (context, state) => const ProfileCompletionPage(),
        ),
        GoRoute(
          path: editProfileRoute,
          name: 'profile-edit',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: doctorNetworkRoute,
          name: 'network',
          builder: (context, state) => const DoctorSearchPage(),
        ),
        GoRoute(
          path: doctorPublicProfileRoute,
          name: 'doctor-profile',
          builder: (context, state) => DoctorPublicProfilePage(
            doctorId: state.pathParameters['doctorId'] ?? '',
          ),
        ),
        GoRoute(
          path: feedRoute,
          name: 'feed',
          builder: (context, state) => const FeedPage(),
        ),
        GoRoute(
          path: communitiesRoute,
          name: 'communities',
          builder: (context, state) => const CommunitiesPage(),
        ),
        GoRoute(
          path: organizationsRoute,
          name: 'organizations',
          builder: (context, state) => const OrganizationsPage(),
        ),
        // Feature routes are added here as they are implemented.
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  static const String rootRoute = '/';
  static const String loginRoute = '/login';

  /// Caller's doctor professional profile.
  static const String profileRoute = '/profile';

  /// First-time profile creation flow.
  static const String completeProfileRoute = '/profile/complete';

  /// Edit flow for the caller's professional profile.
  static const String editProfileRoute = '/profile/edit';

  /// Doctor discovery (search) screen.
  static const String doctorNetworkRoute = '/network';

  /// Public view of another doctor's professional profile. Path param
  /// `doctorId` is the backend profile id.
  static const String doctorPublicProfileRoute = '/doctor/:doctorId';

  /// Builds the public-profile route for a given [doctorId].
  static String doctorPublicProfilePath(String doctorId) =>
      '/doctor/$doctorId';

  /// Doctor-only professional feed (backend contract pending — see FeedPage).
  static const String feedRoute = '/feed';

  /// Doctor-only specialty communities (backend contract pending — see
  /// CommunitiesPage).
  static const String communitiesRoute = '/communities';

  /// Doctor-facing healthcare organization browsing (backend contract
  /// pending — see OrganizationsPage).
  static const String organizationsRoute = '/organizations';

  late final GoRouter _router;

  GoRouter get router => _router;

  static String? _redirect(AuthStatus status, GoRouterState state) {
    final onLogin = state.matchedLocation == loginRoute;
    if (status == AuthStatus.authenticated && onLogin) return rootRoute;
    if (status == AuthStatus.guest && !onLogin) return loginRoute;
    // AuthStatus.unknown: restore is in flight — do not redirect yet.
    return null;
  }
}
