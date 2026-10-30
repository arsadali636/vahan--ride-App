import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/app_dropdown.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/entities/otp_purpose.dart';
import '../../domain/usecases/password_login_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Sign-in screen: password login, OTP login and account registration.
///
/// Talks only to [AuthBloc]. Successful authentication flips [AuthGate], which
/// makes the router redirect away from this page; failures surface as a
/// SnackBar.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static const String _phonePattern = r'^[6-9]\d{9}$';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _AuthForms(phonePattern: _phonePattern),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Hosts the mode switch (Login / Register) and the active form.
class _AuthForms extends StatefulWidget {
  const _AuthForms({required this.phonePattern});

  final String phonePattern;

  @override
  State<_AuthForms> createState() => _AuthFormsState();
}

class _AuthFormsState extends State<_AuthForms> {
  bool _isRegister = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('MedNexus', style: AppTypography.headingMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _isRegister
              ? 'Create your account to get started.'
              : 'Sign in to continue.',
          style: AppTypography.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Login')),
            ButtonSegment(value: true, label: Text('Register')),
          ],
          selected: {_isRegister},
          onSelectionChanged: (selection) {
            setState(() => _isRegister = selection.first);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_isRegister)
          _RegisterForm(phonePattern: widget.phonePattern)
        else
          _LoginForm(phonePattern: widget.phonePattern),
      ],
    );
  }
}

/// Phone + password sign-in with an optional OTP flow.
class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.phonePattern});

  final String phonePattern;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  UserRole _userType = UserRole.doctor;
  bool _signingIn = false;
  bool _otpMode = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  String? _devOtp;
  String? _otpPhoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _otpPhoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Enter your phone number';
    if (!RegExp(widget.phonePattern).hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _signingIn = true);
    context.read<AuthBloc>().add(
      PasswordLoginSubmitted(
        PasswordLoginParams(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          userType: _userType,
        ),
      ),
    );
  }

  void _sendOtp() {
    final phone = _otpPhoneController.text.trim();
    if (!RegExp(widget.phonePattern).hasMatch(phone)) {
      setState(() => _otpPhoneError = 'Enter a valid 10-digit phone number');
      return;
    }
    setState(() {
      _sendingOtp = true;
      _devOtp = null;
      _otpPhoneError = null;
    });
    context.read<AuthBloc>().add(
      OtpRequested(SendOtpParams(phone: phone, purpose: OtpPurpose.login)),
    );
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;
    setState(() => _verifyingOtp = true);
    context.read<AuthBloc>().add(
      OtpVerificationSubmitted(
        VerifyOtpParams(phone: _otpPhoneController.text.trim(), otp: otp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          setState(() {
            _sendingOtp = false;
            _otpMode = true;
            _devOtp = state.result.otp;
          });
        }
        if (state is AuthAuthenticated || state is AuthError) {
          setState(() {
            _signingIn = false;
            _sendingOtp = false;
            _verifyingOtp = false;
          });
        }
      },
      child: Form(
        key: _formKey,
        child: _otpMode ? _buildOtpStep() : _buildPasswordStep(),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Phone number',
          hint: '10-digit mobile number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: _validatePhone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Password',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter your password';
            if (value.length < 4) {
              return 'Password must be at least 4 characters';
            }
            return null;
          },
          onSubmitted: (_) => _signIn(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppDropdown<UserRole>(
          items: const [UserRole.doctor, UserRole.hospital],
          initialValue: _userType,
          label: 'Account type',
          labelBuilder: (role) => role.displayName,
          onChanged: (role) {
            if (role != null) setState(() => _userType = role);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Sign in',
          fullWidth: true,
          isLoading: _signingIn,
          onPressed: _signIn,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlineButton(
          label: 'Continue with OTP',
          fullWidth: true,
          onPressed: () => setState(() => _otpMode = true),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    final devHint = _devOtp;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Phone number',
          hint: '10-digit mobile number',
          controller: _otpPhoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          error: _otpPhoneError,
          onChanged: (_) {
            if (_otpPhoneError != null) {
              setState(() => _otpPhoneError = null);
            }
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (devHint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Development build — your OTP is: $devHint',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        AppTextField(
          label: 'One-time password',
          hint: '6-digit code',
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) {
            final otp = value?.trim() ?? '';
            return otp.length == 6 ? null : 'Enter the 6-digit code';
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Verify & sign in',
          fullWidth: true,
          isLoading: _verifyingOtp,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlineButton(
          label: _devOtp == null ? 'Send OTP' : 'Resend OTP',
          fullWidth: true,
          isLoading: _sendingOtp,
          onPressed: _sendOtp,
        ),
        TextButton(
          onPressed: () => setState(() {
            _otpMode = false;
            _devOtp = null;
          }),
          child: const Text('Back to password login'),
        ),
      ],
    );
  }
}

/// Registration form (doctor / hospital account).
class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.phonePattern});

  final String phonePattern;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _userType = UserRole.doctor;
  bool _submitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    context.read<AuthBloc>().add(
      RegisterSubmitted(
        RegisterParams(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          userType: _userType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthError) {
          setState(() => _submitting = false);
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'First name',
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Enter your first name'
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: 'Last name',
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Enter your last name'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Phone number',
              hint: '10-digit mobile number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your phone number';
                }
                if (!RegExp(widget.phonePattern).hasMatch(value)) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Email (optional)',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final email = value.trim();
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9.!#$%&'
                  "'"
                  r'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
                );
                if (!emailRegex.hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Password',
              helper: 'Minimum 8 characters',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) => (value == null || value.length < 8)
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<UserRole>(
              items: const [UserRole.doctor, UserRole.hospital],
              initialValue: _userType,
              label: 'Account type',
              labelBuilder: (role) => role.displayName,
              onChanged: (role) {
                if (role != null) setState(() => _userType = role);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Create account',
              fullWidth: true,
              isLoading: _submitting,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}
