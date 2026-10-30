/// Centralized API endpoint paths.
///
/// These values mirror the FastAPI OpenAPI contract
/// (http://65.1.134.1/api/docs) and must stay in sync with the backend. No
/// hostnames are hardcoded here — the host comes from `EnvironmentConfig`.
///
/// Every feature's data source references these constants instead of
/// scattering path strings. Feature blocks are added as features are
/// implemented (PHASE 1 → 7).
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth (PHASE 1) ────────────────────────────────────────────────────────

  /// `POST /api/v1/auth/register/` — create a doctor or hospital account.
  static const String authRegister = '/api/v1/auth/register/';

  /// `POST /api/v1/auth/login/` — password login (public).
  static const String authLogin = '/api/v1/auth/login/';

  /// `POST /api/v1/auth/send-otp/` — request a one-time password (public).
  static const String authSendOtp = '/api/v1/auth/send-otp/';

  /// `POST /api/v1/auth/verify-otp/` — exchange an OTP for tokens (public).
  static const String authVerifyOtp = '/api/v1/auth/verify-otp/';

  /// `POST /api/v1/auth/refresh/` — exchange a refresh token (public).
  ///
  /// Also used by the refresh interceptor to identify the refresh request so
  /// it is never retried (and never triggers a refresh loop).
  static const String authRefresh = '/api/v1/auth/refresh/';

  /// `POST /api/v1/auth/logout/` — revoke the current session (authenticated).
  static const String authLogout = '/api/v1/auth/logout/';

  // ── Doctor profile (PHASE 2) ───────────────────────────────────────────────

  /// `POST /api/v1/doctors/profile/` — create the caller's doctor profile
  /// (authenticated).
  static const String doctorProfileCreate = '/api/v1/doctors/profile/';

  /// `GET`/`PATCH /api/v1/doctors/profile/me/` — read or update the caller's
  /// doctor profile (authenticated).
  static const String doctorProfileMe = '/api/v1/doctors/profile/me/';

  // ── Doctor professional profile (PHASE 6) ──────────────────────────────────

  /// `GET /api/v1/doctors/profile/{doctor_id}/` — public profile by id.
  static const String doctorProfileByIdPrefix = '/api/v1/doctors/profile/';

  /// `GET`/`POST /api/v1/doctors/profile/me/qualifications/` — list/add
  /// qualifications (authenticated).
  static const String doctorQualifications =
      '/api/v1/doctors/profile/me/qualifications/';

  /// `DELETE /api/v1/doctors/profile/me/qualifications/{qualification_id}/`
  /// (authenticated). 404 is expected when the id does not exist.
  static const String doctorQualificationByIdPrefix =
      '/api/v1/doctors/profile/me/qualifications/';

  /// `GET`/`POST /api/v1/doctors/profile/me/registrations/` — list/add
  /// registrations (authenticated).
  static const String doctorRegistrations =
      '/api/v1/doctors/profile/me/registrations/';

  /// `GET`/`POST /api/v1/doctors/profile/me/experiences/` — list/add work
  /// experience entries (authenticated).
  static const String doctorExperiences =
      '/api/v1/doctors/profile/me/experiences/';

  /// `DELETE /api/v1/doctors/profile/me/experiences/{exp_id}/` (authenticated,
  /// 204 on success).
  static const String doctorExperienceByIdPrefix =
      '/api/v1/doctors/profile/me/experiences/';

  /// `POST /api/v1/doctors/profile/me/photo/` — upload a profile photo
  /// (multipart, field name `file`).
  static const String doctorPhotoUpload = '/api/v1/doctors/profile/me/photo/';

  // ── Home dashboard (PHASE 3) ─────────────────────────────────────────────

  /// `GET /api/v1/feed/home/` — home dashboard: stats, urgent jobs,
  /// suggested doctors and unread counts (authenticated).
  static const String feedHome = '/api/v1/feed/home/';

  // ── Feed (PHASE 3) ────────────────────────────────────────────────────────

  /// `GET /api/v1/feed/` — paginated feed posts (authenticated).
  static const String feed = '/api/v1/feed/';

  /// `POST /api/v1/feed/posts/` — create a new feed post (multipart, authenticated).
  static const String feedPosts = '/api/v1/feed/posts/';

  /// Builds `POST /api/v1/feed/posts/{post_id}/like/` — toggle like on a post.
  static String feedPostLikeById(String postId) =>
      '/api/v1/feed/posts/$postId/like/';

  // ── Doctor network (PHASE 7) ───────────────────────────────────────────────

  /// `GET /api/v1/doctors/search/` — search discoverable doctors
  /// (authenticated). Paginated via `page` / `page_size` query parameters.
  static const String doctorSearch = '/api/v1/doctors/search/';

  /// Builds `GET /api/v1/doctors/profile/{doctor_id}/`.
  static String doctorProfileById(String doctorId) =>
      '$doctorProfileByIdPrefix$doctorId/';

  /// Builds `DELETE /api/v1/doctors/profile/me/qualifications/{id}/`.
  static String doctorQualificationById(String qualificationId) =>
      '$doctorQualificationByIdPrefix$qualificationId/';

  /// Builds `DELETE /api/v1/doctors/profile/me/experiences/{id}/`.
  static String doctorExperienceById(String experienceId) =>
      '$doctorExperienceByIdPrefix$experienceId/';

  // ── Feed posts CRUD ────────────────────────────────────────────────────────

  /// `PUT /api/v1/feed/posts/{postId}/` — edit a post.
  static const String editPost = '/api/v1/feed/posts';

  /// `DELETE /api/v1/feed/posts/{postId}/` — delete a post.
  static const String deletePost = '/api/v1/feed/posts';

  // ── Feed comments ──────────────────────────────────────────────────────────

  /// `GET /api/v1/feed/posts/{postId}/comments/` — get comments on a post.
  static const String getComments = '/api/v1/feed/posts';

  /// `POST /api/v1/feed/posts/{postId}/comments/` — post a comment on a post.
  static const String postComment = '/api/v1/feed/posts';

  /// `POST /api/v1/feed/comments/{commentId}/reply/` — reply to a comment.
  static const String replyComment = '/api/v1/feed/comments';

  /// `PUT /api/v1/feed/comments/{commentId}/` — edit a comment.
  static const String editComment = '/api/v1/feed/comments';

  /// `DELETE /api/v1/feed/comments/{commentId}/` — delete a comment.
  static const String deleteComment = '/api/v1/feed/comments';
}
