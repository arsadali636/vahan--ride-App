/// Purpose of an OTP request. Wire values must match the backend contract
/// (`OTPRequest.purpose`): LOGIN, REGISTER, RESET_PASSWORD.
enum OtpPurpose {
  login('LOGIN'),
  register('REGISTER'),
  resetPassword('RESET_PASSWORD');

  const OtpPurpose(this.wire);

  /// Exact value sent to the backend.
  final String wire;

  static OtpPurpose fromWire(String value) {
    return OtpPurpose.values.firstWhere(
      (purpose) => purpose.wire == value,
      orElse: () => OtpPurpose.login,
    );
  }
}
