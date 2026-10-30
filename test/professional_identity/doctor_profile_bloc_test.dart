import 'package:flutter_test/flutter_test.dart';

import 'package:doc_connect_app/core/errors/failures.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_experience.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_experience_draft.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_photo.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_profile.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_profile_draft.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_qualification.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_qualification_draft.dart';
import 'package:doc_connect_app/features/professional_identity/domain/entities/doctor_registration_draft.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/add_registration_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/create_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_experience_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/delete_qualification_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/get_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_experiences_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_qualifications_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/list_registrations_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/update_doctor_profile_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/domain/usecases/upload_profile_photo_usecase.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/bloc/doctor_profile_bloc.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/bloc/doctor_profile_event.dart';
import 'package:doc_connect_app/features/professional_identity/presentation/bloc/doctor_profile_state.dart';

import '../helpers/fake_doctor_profile_repository.dart';
import '../helpers/fake_session_service.dart';

const _draft = DoctorProfileDraft(firstName: 'Ada', lastName: 'Lovelace');

/// Waits for a terminal status (loaded / success / failure), skipping the
/// intermediate `loading`/`creating`/`updating`/`uploadingPhoto`/`refreshing`
/// states emitted at the start of a handler.
Future<DoctorProfileState> _awaitStatus(
  DoctorProfileBloc bloc,
  void Function() trigger,
) async {
  final done = bloc.stream
      .firstWhere(
        (s) =>
            s.status == DoctorProfileStatus.loaded ||
            s.status == DoctorProfileStatus.success ||
            s.status == DoctorProfileStatus.failure,
      )
      .timeout(const Duration(seconds: 5));
  trigger();
  return done;
}

void main() {
  late FakeSessionService session;
  late FakeDoctorProfileRepository repository;
  late DoctorProfileBloc bloc;

  DoctorProfileBloc build() {
    return DoctorProfileBloc(
      sessionService: session,
      getDoctorProfile: GetDoctorProfile(repository),
      createDoctorProfile: CreateDoctorProfile(repository),
      updateDoctorProfile: UpdateDoctorProfile(repository),
      uploadProfilePhoto: UploadProfilePhoto(repository),
      listQualifications: ListQualifications(repository),
      addQualification: AddQualification(repository),
      deleteQualification: DeleteQualification(repository),
      listRegistrations: ListRegistrations(repository),
      addRegistration: AddRegistration(repository),
      listExperiences: ListExperiences(repository),
      addExperience: AddExperience(repository),
      deleteExperience: DeleteExperience(repository),
    );
  }

  setUp(() {
    session = FakeSessionService();
    repository = FakeDoctorProfileRepository();
    bloc = build();
  });

  tearDown(() => bloc.close());

  group('load', () {
    test('emits loaded with profile, sub-resources and session flag', () async {
      session.saveProfileCreated(true);
      repository.qualifications = [
        const DoctorQualification(
          id: 'q-1',
          degree: 'MBBS',
          institution: 'GMC',
          year: 2012,
        ),
      ];
      repository.experiences = const [
        DoctorExperience(role: 'Resident', hospitalName: 'City Hospital'),
      ];

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileLoadRequested()),
      );

      expect(state.status, DoctorProfileStatus.loaded);
      expect(state.profile?.id, 'p-1');
      expect(state.profileCreated, isTrue);
      expect(state.qualifications.single.degree, 'MBBS');
      expect(state.experiences.single.role, 'Resident');
      expect(state.failure, isNull);
    });

    test('degrades sub-resource failures to empty lists', () async {
      repository.listQualificationFailure = ServerFailure('boom');
      repository.listExperienceFailure = ServerFailure('boom');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileLoadRequested()),
      );

      expect(state.status, DoctorProfileStatus.loaded);
      expect(state.profile?.id, 'p-1');
      expect(state.qualifications, isEmpty);
      expect(state.experiences, isEmpty);
    });

    test('404 profile keeps needsCompletion active', () async {
      repository.getFailure = NotFoundFailure('no profile');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileLoadRequested()),
      );

      expect(state.status, DoctorProfileStatus.loaded);
      expect(state.profile, isNull);
      expect(state.profileCreated, isFalse);
      expect(state.needsCompletion, isTrue);
    });

    test('other failures surface as failure status', () async {
      repository.getFailure = ServerFailure('boom');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileLoadRequested()),
      );

      expect(state.status, DoctorProfileStatus.failure);
      expect(state.failure, isA<ServerFailure>());
      expect(state.profile, isNull);
    });
  });

  group('create', () {
    test('saves profile_created and emits success', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileCreateRequested(_draft)),
      );

      expect(state.status, DoctorProfileStatus.success);
      expect(state.profileCreated, isTrue);
      expect(state.message, 'Profile created');
      expect(await session.getProfileCreated(), isTrue);
    });

    test('maps failure to failure status without marking created', () async {
      repository.getFailure = ValidationFailure('bad');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileCreateRequested(_draft)),
      );

      expect(state.status, DoctorProfileStatus.failure);
      expect(state.failure, isA<ValidationFailure>());
      expect(await session.getProfileCreated(), isFalse);
    });
  });

  group('update', () {
    test('emits success with the updated profile', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileUpdateRequested(_draft)),
      );

      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Profile updated');
      expect(state.profile?.id, 'p-1');
    });

    test('maps failure to failure status', () async {
      repository.getFailure = ServerFailure('boom');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileUpdateRequested(_draft)),
      );

      expect(state.status, DoctorProfileStatus.failure);
      expect(state.failure, isA<ServerFailure>());
    });
  });

  group('photo upload', () {
    test('uploads then refreshes the profile', () async {
      const photo = DoctorPhoto(
        bytes: [1, 2, 3],
        filename: 'a.png',
        contentType: 'image/png',
      );

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfilePhotoUploadRequested(photo)),
      );

      expect(repository.uploadCalls, 1);
      expect(repository.getCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Photo uploaded');
    });

    test('maps failure to failure status', () async {
      repository.getFailure = ServerFailure('boom');

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(
          const DoctorProfilePhotoUploadRequested(
            DoctorPhoto(
              bytes: [1],
              filename: 'a.png',
              contentType: 'image/png',
            ),
          ),
        ),
      );

      expect(state.status, DoctorProfileStatus.failure);
      expect(state.failure, isA<ServerFailure>());
    });
  });

  group('sub-resource mutations', () {
    test('addQualification refreshes the list', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(
          const AddQualificationRequested(
            DoctorQualificationDraft(
              degree: 'MBBS',
              institution: 'GMC',
              year: 2012,
            ),
          ),
        ),
      );

      expect(repository.addQualificationCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Qualification added');
    });

    test('deleteQualification refreshes the list', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DeleteQualificationRequested('q-1')),
      );

      expect(repository.deleteQualificationCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Qualification removed');
    });

    test('addRegistration refreshes the list', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(
          const AddRegistrationRequested(
            DoctorRegistrationDraft(
              councilId: 'MCI',
              registrationNumber: 'MCI-1',
              registrationYear: 2013,
            ),
          ),
        ),
      );

      expect(repository.addRegistrationCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Registration added');
    });

    test('addExperience refreshes the list', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(
          const AddExperienceRequested(
            DoctorExperienceDraft(
              role: 'Resident',
              hospitalName: 'City Hospital',
            ),
          ),
        ),
      );

      expect(repository.addExperienceCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Experience added');
    });

    test('deleteExperience refreshes the list', () async {
      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DeleteExperienceRequested('e-1')),
      );

      expect(repository.deleteExperienceCalls, 1);
      expect(state.status, DoctorProfileStatus.success);
      expect(state.message, 'Experience removed');
    });
  });

  group('refresh', () {
    test('refreshes the profile and sub-resources', () async {
      await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileLoadRequested()),
      );
      final initialGets = repository.getCalls;

      final state = await _awaitStatus(
        bloc,
        () => bloc.add(const DoctorProfileRefreshRequested()),
      );

      expect(repository.getCalls, initialGets + 1);
      expect(state.status, DoctorProfileStatus.loaded);
      expect(state.profile?.id, 'p-1');
    });
  });

  group('state helpers', () {
    test('needsCompletion is false once a profile exists', () {
      expect(bloc.state.needsCompletion, isTrue);

      bloc.emit(
        const DoctorProfileState(
          profile: DoctorProfile(
            id: 'p-1',
            userId: 'u-1',
            firstName: 'Ada',
            lastName: 'Lovelace',
            fullName: 'Ada Lovelace',
          ),
        ),
      );

      expect(bloc.state.needsCompletion, isFalse);
    });

    test('hasProfile requires a non-empty first name', () {
      expect(
        const DoctorProfileState()
            .copyWith(
              profile: const DoctorProfile(
                id: 'p-1',
                userId: 'u-1',
                firstName: '',
                lastName: '',
                fullName: '',
              ),
            )
            .hasProfile,
        isFalse,
      );
    });
  });
}
