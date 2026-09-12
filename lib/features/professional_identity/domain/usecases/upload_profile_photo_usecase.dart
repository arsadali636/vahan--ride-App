import '../repositories/doctor_profile_repository.dart';

/// Uploads the caller's profile photo.
///
/// Returns the backend's `photo_file_id` when it is echoed in the response;
/// `null` otherwise.
class UploadProfilePhoto {
  final DoctorProfileRepository repository;

  UploadProfilePhoto(this.repository);

  Future<String?> call({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) {
    return repository.uploadProfilePhoto(
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
  }
}
