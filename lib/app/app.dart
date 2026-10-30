import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'app_config.dart';
import 'app_theme.dart';

/// Root widget of the MedNexus application.
class MedNexusApp extends StatelessWidget {
  const MedNexusApp({super.key, required this.router, required this.authBloc});

  final GoRouter router;
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: AppConfig.instance.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
