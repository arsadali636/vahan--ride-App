import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'app/dependency_injection.dart';
import 'app/environment_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.initialize(environmentConfig: EnvironmentConfig.fromDartDefines());

  await DependencyInjection.init();

  final authBloc = DependencyInjection.get<AuthBloc>();
  final router = DependencyInjection.get<GoRouter>();

  runApp(MedNexusApp(router: router, authBloc: authBloc));
}
