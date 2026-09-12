/// Application user roles. Wire values must match the backend contract
/// (`RegisterRequest.user_type`): DOCTOR, HOSPITAL_ADMIN, HOSPITAL_HR.
enum UserRole {
  doctor('DOCTOR'),
  hospital('HOSPITAL_ADMIN'),
  hospitalHr('HOSPITAL_HR');

  const UserRole(this.wire);

  /// Exact value sent to the backend.
  final String wire;

  static UserRole fromWire(String value) {
    return UserRole.values.firstWhere(
      (role) => role.wire == value,
      orElse: () => UserRole.doctor,
    );
  }
}

extension UserRoleX on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.hospital:
        return 'Hospital Institution';
      case UserRole.hospitalHr:
        return 'Hospital HR / Recruiter';
    }
  }
}
