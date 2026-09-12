/// Backend wire values for a doctor profile's verification state.
enum DoctorVerificationStatus {
  unverified,
  verified,
  pending,
  rejected;

  static DoctorVerificationStatus fromWire(String? value) {
    switch (value?.toUpperCase()) {
      case 'VERIFIED':
        return DoctorVerificationStatus.verified;
      case 'PENDING':
        return DoctorVerificationStatus.pending;
      case 'REJECTED':
        return DoctorVerificationStatus.rejected;
      case 'UNVERIFIED':
      default:
        return DoctorVerificationStatus.unverified;
    }
  }
}
