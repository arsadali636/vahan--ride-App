/// Cross-cutting request constants.
///
/// Endpoint paths live in [ApiEndpoints] — this class only holds constants
/// shared by infrastructure that are not URLs.
class ApiConstants {
  ApiConstants._();

  /// Key on [RequestOptions.extra] that marks a request as public.
  ///
  /// When a RemoteDataSource sets this to `false`, [AuthInterceptor] does not
  /// attach an access token. The decision is made once per endpoint (at the
  /// data-source call site via `ApiClient(..., requiresAuth: false)`) instead
  /// of being repeated across features.
  static const String requiresAuthExtraKey = 'requires_auth';
}
