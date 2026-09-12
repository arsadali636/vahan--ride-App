import 'package:equatable/equatable.dart';

/// In-memory profile photo selected by the user, ready to upload.
///
/// Bytes and content type come from the image picker (`XFile`); the blob is
/// streamed to `POST /api/v1/doctors/profile/me/photo/` as multipart `file`.
class DoctorPhoto extends Equatable {
  final List<int> bytes;
  final String filename;
  final String contentType;

  const DoctorPhoto({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  @override
  List<Object?> get props => [bytes, filename, contentType];
}
