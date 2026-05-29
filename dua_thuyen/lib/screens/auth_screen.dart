import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _nameFieldKey = GlobalKey();
  final _emailFieldKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmFieldKey = GlobalKey();
  final _loginEmailFieldKey = GlobalKey();
  final _loginPasswordFieldKey = GlobalKey();

  bool isLogin = true;
  bool _loading = false;
  bool _submitted = false;
  bool _rememberMe = true;
  bool _hideLoginPassword = true;
  bool _hideRegisterPassword = true;
  bool _hideConfirmPassword = true;
  final Map<String, String> _serverErrors = <String, String>{};
  final Map<String, String> _fieldErrors = <String, String>{};

  static const Size _baseSize = Size(390, 844);

  @override
  void initState() {
    super.initState();
  }

  void _switchAuthMode(bool loginMode) {
    if (isLogin == loginMode) return;
    setState(() {
      isLogin = loginMode;
      _submitted = false;
      _serverErrors.clear();
      _fieldErrors.clear();
      _formKey.currentState?.reset();
    });
  }

  bool _validateInputs() {
    final errors = <String, String>{};
    if (isLogin) {
      if (_loginEmailCtrl.text.trim().isEmpty) {
        errors['loginEmail'] = 'Khong duoc de trong';
      }
      if (_loginPasswordCtrl.text.trim().isEmpty) {
        errors['loginPassword'] = 'Khong duoc de trong';
      }
    } else {
      if (_nameCtrl.text.trim().isEmpty) {
        errors['name'] = 'Khong duoc de trong';
      }
      if (_emailCtrl.text.trim().isEmpty) {
        errors['email'] = 'Khong duoc de trong';
      }
      final password = _passwordCtrl.text.trim();
      if (password.isEmpty) {
        errors['password'] = 'Khong duoc de trong';
      } else if (password.length < 4) {
        errors['password'] = 'Mat khau phai tren 4 ky tu';
      }
      final confirm = _confirmCtrl.text.trim();
      if (confirm.isEmpty) {
        errors['confirm'] = 'Khong duoc de trong';
      } else if (confirm != password) {
        errors['confirm'] = 'Xac nhan mat khau khong khop';
      }
    }

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  void _clearFieldError(String key) {
    if (!_fieldErrors.containsKey(key)) return;
    setState(() {
      _fieldErrors.remove(key);
    });
  }

  String? _requiredValidator(String? value) {
    if (!_submitted) return null;
    if (value == null || value.trim().isEmpty) return 'Trường này bắt buộc';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (!_submitted) return null;
    if (value == null || value.isEmpty) return 'Trường này bắt buộc';
    if (value.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    if (!RegExp(r'\d').hasMatch(value)) return 'Mật khẩu cần có số';
    return null;
  }

  String? _confirmValidator(String? value) {
    if (!_submitted) return null;
    if (value == null || value.isEmpty) return 'Trường này bắt buộc';
    if (value != _passwordCtrl.text) return 'Mật khẩu không khớp';
    return null;
  }

  Future<void> submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _submitted = true;
      _serverErrors.clear();
      _fieldErrors.clear();
    });

    if (!_validateInputs()) {
      setState(() => _loading = false);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      if (isLogin) {
        final res = await AuthService.login(
          _loginEmailCtrl.text,
          _loginPasswordCtrl.text,
        );
        if (res['ok'] == true) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng nhập thành công',
                style: TextStyle(color: Color(0xFFFFF0C2)),
              ),
              backgroundColor: Color(0xFF5D4037),
            ),
          );
          if (mounted) {
            final displayName = (res['name'] ?? _loginEmailCtrl.text)
                .toString();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen(name: displayName)),
            );
          }
        } else {
          setState(() {
            _fieldErrors['loginPassword'] = 'Tai khoan hoac mat khau chua chinh xac';
          });
        }
      } else {
        final res = await AuthService.register(
          _nameCtrl.text,
          _emailCtrl.text,
          _passwordCtrl.text,
        );
        if (res['ok'] == true) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thành công',
                style: TextStyle(color: Color(0xFFFFF0C2)),
              ),
              backgroundColor: Color(0xFF5D4037),
            ),
          );
          if (mounted) {
            setState(() {
              isLogin = true;
              _submitted = false;
              _serverErrors.clear();
              _fieldErrors.clear();
              _loginEmailCtrl.text = _emailCtrl.text.trim();
              _loginPasswordCtrl.clear();
              _nameCtrl.clear();
              _emailCtrl.clear();
              _passwordCtrl.clear();
              _confirmCtrl.clear();
              _hideLoginPassword = true;
              _hideRegisterPassword = true;
              _hideConfirmPassword = true;
            });
          }
        } else {
          final body = res['body'];
          final message = body is Map && body['error'] != null
              ? body['error'].toString()
              : 'Đăng ký thất bại';
          setState(() {
            if (message.toLowerCase().contains('ton tai')) {
              _fieldErrors['email'] = 'Tai khoan da ton tai';
            } else {
              _serverErrors['general'] = message;
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _scrollCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = (constraints.maxWidth / _baseSize.width).clamp(
            0.0,
            constraints.maxHeight / _baseSize.height,
          );
          return Stack(
            children: [
              const Positioned.fill(child: _GeneratedStadiumBackground()),
              SingleChildScrollView(
                controller: _scrollCtrl,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: _baseSize.width,
                        height: _baseSize.height,
                        child: _AuthCanvas(
                          isLogin: isLogin,
                          loading: _loading,
                          rememberMe: _rememberMe,
                          hasValidationErrors:
                              _fieldErrors.isNotEmpty ||
                              _serverErrors['general'] != null,
                          formKey: _formKey,
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          passwordCtrl: _passwordCtrl,
                          confirmCtrl: _confirmCtrl,
                          loginEmailCtrl: _loginEmailCtrl,
                          loginPasswordCtrl: _loginPasswordCtrl,
                          hideLoginPassword: _hideLoginPassword,
                          hideRegisterPassword: _hideRegisterPassword,
                          hideConfirmPassword: _hideConfirmPassword,
                          nameFocus: _nameFocus,
                          emailFocus: _emailFocus,
                          passwordFocus: _passwordFocus,
                          confirmFocus: _confirmFocus,
                          loginEmailFocus: _loginEmailFocus,
                          loginPasswordFocus: _loginPasswordFocus,
                          nameFieldKey: _nameFieldKey,
                          emailFieldKey: _emailFieldKey,
                          passwordFieldKey: _passwordFieldKey,
                          confirmFieldKey: _confirmFieldKey,
                          loginEmailFieldKey: _loginEmailFieldKey,
                          loginPasswordFieldKey: _loginPasswordFieldKey,
                          serverError: _serverErrors['general'],
                          loginEmailError: _fieldErrors['loginEmail'],
                          loginPasswordError: _fieldErrors['loginPassword'],
                          nameError: _fieldErrors['name'],
                          emailError: _fieldErrors['email'],
                          passwordError: _fieldErrors['password'],
                          confirmError: _fieldErrors['confirm'],
                          onRememberChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                          onLoginEmailInteracted: () =>
                              _clearFieldError('loginEmail'),
                          onLoginPasswordInteracted: () =>
                              _clearFieldError('loginPassword'),
                          onNameInteracted: () => _clearFieldError('name'),
                          onEmailInteracted: () => _clearFieldError('email'),
                          onPasswordInteracted: () =>
                              _clearFieldError('password'),
                          onConfirmInteracted: () =>
                              _clearFieldError('confirm'),
                          onSubmit: submit,
                          onToggleMode: _switchAuthMode,
                          onToggleLoginPassword: () => setState(
                            () => _hideLoginPassword = !_hideLoginPassword,
                          ),
                          onToggleRegisterPassword: () => setState(
                            () =>
                                _hideRegisterPassword = !_hideRegisterPassword,
                          ),
                          onToggleConfirmPassword: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          requiredValidator: _requiredValidator,
                          passwordValidator: _passwordValidator,
                          confirmValidator: _confirmValidator,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuthCanvas extends StatelessWidget {
  const _AuthCanvas({
    required this.isLogin,
    required this.loading,
    required this.rememberMe,
    required this.hasValidationErrors,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.loginEmailCtrl,
    required this.loginPasswordCtrl,
    required this.hideLoginPassword,
    required this.hideRegisterPassword,
    required this.hideConfirmPassword,
    required this.nameFocus,
    required this.emailFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.loginEmailFocus,
    required this.loginPasswordFocus,
    required this.nameFieldKey,
    required this.emailFieldKey,
    required this.passwordFieldKey,
    required this.confirmFieldKey,
    required this.loginEmailFieldKey,
    required this.loginPasswordFieldKey,
    required this.serverError,
    required this.loginEmailError,
    required this.loginPasswordError,
    required this.nameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmError,
    required this.onRememberChanged,
    required this.onLoginEmailInteracted,
    required this.onLoginPasswordInteracted,
    required this.onNameInteracted,
    required this.onEmailInteracted,
    required this.onPasswordInteracted,
    required this.onConfirmInteracted,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onToggleLoginPassword,
    required this.onToggleRegisterPassword,
    required this.onToggleConfirmPassword,
    required this.requiredValidator,
    required this.passwordValidator,
    required this.confirmValidator,
  });

  final bool isLogin;
  final bool loading;
  final bool rememberMe;
  final bool hasValidationErrors;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final TextEditingController loginEmailCtrl;
  final TextEditingController loginPasswordCtrl;
  final bool hideLoginPassword;
  final bool hideRegisterPassword;
  final bool hideConfirmPassword;
  final FocusNode nameFocus;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;
  final FocusNode loginEmailFocus;
  final FocusNode loginPasswordFocus;
  final GlobalKey nameFieldKey;
  final GlobalKey emailFieldKey;
  final GlobalKey passwordFieldKey;
  final GlobalKey confirmFieldKey;
  final GlobalKey loginEmailFieldKey;
  final GlobalKey loginPasswordFieldKey;
  final String? serverError;
  final String? loginEmailError;
  final String? loginPasswordError;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLoginEmailInteracted;
  final VoidCallback onLoginPasswordInteracted;
  final VoidCallback onNameInteracted;
  final VoidCallback onEmailInteracted;
  final VoidCallback onPasswordInteracted;
  final VoidCallback onConfirmInteracted;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onToggleMode;
  final VoidCallback onToggleLoginPassword;
  final VoidCallback onToggleRegisterPassword;
  final VoidCallback onToggleConfirmPassword;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> passwordValidator;
  final FormFieldValidator<String> confirmValidator;

  @override
  Widget build(BuildContext context) {
    final panelTop = isLogin ? 190.0 : 185.0;
    final basePanelHeight = isLogin ? 530.0 : 560.0;
    final panelHeight = basePanelHeight + (hasValidationErrors ? 90.0 : 0.0);
    const panelLeft = 57.0;
    const panelWidth = 276.0;
    final panelCanvasTop = panelTop + 4;
    final panelBorderLeft = panelLeft + 5;
    final panelBorderTop = panelCanvasTop + 5;
    final panelBorderRight = panelLeft + panelWidth - 5;
    const topCornerWidth = 92.0;
    const topCornerHeight = 92.0;
    const topCornerLift = 13.0;
    const topCornersOuterInset = 13.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 36,
          top: 56,
          width: 318,
          height: 106,
          child: _TitleBanner(
            isLogin ? 'Thiên Mã Bất Bại' : 'ĐĂNG KÝ TÀI KHOẢN',
            isLogin,
          ),
        ),
        Positioned(
          left: panelLeft,
          top: panelCanvasTop,
          width: panelWidth,
          height: panelHeight - 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _PanelTexture(),
              CustomPaint(painter: _PanelPainter()),
            ],
          ),
        ),
        // Top decorative horses (left + right), drawn above panel to avoid hiding.
        Positioned(
          left: panelBorderLeft - topCornersOuterInset,
          top: panelBorderTop - topCornerLift,
          width: (panelBorderRight - panelBorderLeft) + (topCornersOuterInset * 2),
          height: topCornerHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: topCornerWidth,
                height: topCornerHeight,
                child: Image.asset(
                  'assets/images/thien_ma_horse_corner_generated.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                width: topCornerWidth,
                height: topCornerHeight,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: Image.asset(
                    'assets/images/thien_ma_horse_corner_generated.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        _corner(
          left: panelLeft - 17,
          top: panelTop + panelHeight - 112,
          flipX: false,
          flipY: false,
        ),
        _corner(
          left: panelLeft + panelWidth - 107,
          top: panelTop + panelHeight - 112,
          flipX: true,
          flipY: false,
        ),
        Positioned(
          left: isLogin ? 143 : 148,
          top: isLogin ? 232 : 230,
          width: isLogin ? 106 : 96,
          height: isLogin ? 106 : 96,
          child: Image.asset(
            'assets/images/thien_ma_pegasus_generated.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 82,
          top: isLogin ? 347 : 315,
          width: 226,
          child: Form(
            key: formKey,
            child: isLogin ? _loginForm() : _registerForm(),
          ),
        ),
      ],
    );
  }

  Widget _corner({
    required double left,
    required double top,
    required bool flipX,
    required bool flipY,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: 124,
      height: 124,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(flipX ? -1 : 1, flipY ? -1 : 1, 1),
        child: Image.asset(
          'assets/images/thien_ma_corner_compact_generated.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const _GoldLabel('TÀI KHOẢN'),
        _FantasyInput(
          key: loginEmailFieldKey,
          controller: loginEmailCtrl,
          focusNode: loginEmailFocus,
          errorText: loginEmailError,
          onInteracted: onLoginEmailInteracted,
          hint: 'Nhập tên tài khoản...',
          icon: Icons.key_rounded,
          validator: requiredValidator,
        ),
        const SizedBox(height: 20),
        const _GoldLabel('MẬT KHẨU'),
        _FantasyInput(
          key: loginPasswordFieldKey,
          controller: loginPasswordCtrl,
          focusNode: loginPasswordFocus,
          errorText: loginPasswordError,
          onInteracted: onLoginPasswordInteracted,
          hint: 'Nhập mật khẩu...',
          icon: Icons.lock_rounded,
          obscure: hideLoginPassword,
          showPasswordToggle: true,
          onToggleObscure: onToggleLoginPassword,
          validator: requiredValidator,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('Quên mật khẩu?', style: _smallWhiteText(fontSize: 14)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Checkbox(
                value: rememberMe,
                onChanged: onRememberChanged,
                activeColor: const Color(0xFFF4D486),
                checkColor: const Color(0xFF33200F),
                side: const BorderSide(color: Color(0xFFF4D486), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('Ghi nhớ tôi', style: _smallWhiteText(fontSize: 19)),
          ],
        ),
        if (serverError != null) _ErrorText(serverError!),
        const SizedBox(height: 18),
        _FantasyButton(
          text: 'ĐĂNG NHẬP',
          loading: loading,
          large: true,
          onTap: onSubmit,
        ),
        const SizedBox(height: 14),
        _FantasyButton(
          text: 'ĐĂNG KÝ NGAY',
          loading: false,
          large: false,
          onTap: () => onToggleMode(false),
        ),
      ],
    );
  }

  Widget _registerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GoldLabel('TÊN NHÂN VẬT'),
        _FantasyInput(
          key: nameFieldKey,
          controller: nameCtrl,
          focusNode: nameFocus,
          errorText: nameError,
          onInteracted: onNameInteracted,
          hint: 'Nhập tên nhân vật (3-12 ký tự)...',
          icon: Icons.workspace_premium_rounded,
          validator: requiredValidator,
        ),
        const SizedBox(height: 11),
        const _GoldLabel('TÊN TÀI KHOẢN'),
        _FantasyInput(
          key: emailFieldKey,
          controller: emailCtrl,
          focusNode: emailFocus,
          errorText: emailError,
          onInteracted: onEmailInteracted,
          hint: 'Nhập tên tài khoản (tối thiểu 5 ký tự)...',
          icon: Icons.key_rounded,
          validator: requiredValidator,
        ),
        const SizedBox(height: 11),
        const _GoldLabel('MẬT KHẨU'),
        _FantasyInput(
          key: passwordFieldKey,
          controller: passwordCtrl,
          focusNode: passwordFocus,
          errorText: passwordError,
          onInteracted: onPasswordInteracted,
          hint: 'Nhập mật khẩu (tối thiểu 8 ký tự, có số)...',
          icon: Icons.lock_rounded,
          obscure: hideRegisterPassword,
          showPasswordToggle: true,
          onToggleObscure: onToggleRegisterPassword,
          validator: passwordValidator,
        ),
        const SizedBox(height: 11),
        const _GoldLabel('XÁC NHẬN MẬT KHẨU'),
        _FantasyInput(
          key: confirmFieldKey,
          controller: confirmCtrl,
          focusNode: confirmFocus,
          errorText: confirmError,
          onInteracted: onConfirmInteracted,
          hint: 'Nhập lại mật khẩu để xác nhận...',
          icon: Icons.lock_person_rounded,
          obscure: hideConfirmPassword,
          showPasswordToggle: true,
          onToggleObscure: onToggleConfirmPassword,
          validator: confirmValidator,
        ),
        if (serverError != null) _ErrorText(serverError!),
        const SizedBox(height: 16),
        _FantasyButton(
          text: 'HOÀN TẤT ĐĂNG KÝ',
          loading: loading,
          large: true,
          onTap: onSubmit,
        ),
        const SizedBox(height: 15),
        _FantasyButton(
          text: 'HỦY BỎ',
          loading: false,
          large: false,
          onTap: () => onToggleMode(true),
        ),
      ],
    );
  }

  TextStyle _smallWhiteText({required double fontSize}) {
    return GoogleFonts.fredoka(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      shadows: const [
        Shadow(color: Colors.black, blurRadius: 5, offset: Offset(1, 1)),
      ],
    );
  }
}

class _GeneratedStadiumBackground extends StatelessWidget {
  const _GeneratedStadiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/thien_ma_stadium_generated.png',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.1),
                const Color(0xFF07121E).withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.9),
              ],
              stops: const [0, 0.62, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBanner extends StatelessWidget {
  const _TitleBanner(this.title, this.cursive);

  final String title;
  final bool cursive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/thien_ma_title_frame_generated.png',
          fit: BoxFit.fill,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(46, 28, 46, 31),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: cursive
                    ? GoogleFonts.playball(
                        color: const Color(0xFFFFE5A0),
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF3A160B),
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          ),
                          Shadow(color: Color(0xFFFFF2C2), blurRadius: 8),
                        ],
                      )
                    : GoogleFonts.fredoka(
                        color: const Color(0xFFFFE5A0),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF3A160B),
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          ),
                          Shadow(color: Color(0xFFFFF2C2), blurRadius: 6),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelTexture extends StatelessWidget {
  const _PanelTexture();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/thien_ma_board_texture.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A1623).withValues(alpha: 0.62),
                  const Color(0xFF050C14).withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldLabel extends StatelessWidget {
  const _GoldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.fredoka(
          color: const Color(0xFFEBC77E),
          fontSize: 19,
          fontWeight: FontWeight.w900,
          height: 1,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 2)),
          ],
        ),
      ),
    );
  }
}

class _FantasyInput extends StatelessWidget {
  const _FantasyInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.validator,
    this.errorText,
    this.onInteracted,
    this.obscure = false,
    this.showPasswordToggle = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final String? errorText;
  final bool obscure;
  final bool showPasswordToggle;
  final VoidCallback? onToggleObscure;
  final FormFieldValidator<String> validator;
  final VoidCallback? onInteracted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 39,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _InputPainter())),
              Positioned(
                left: 9,
                top: 5,
                width: 29,
                height: 29,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF916233), Color(0xFF3C2110)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: const Color(0xFFF5D17B), size: 18),
                ),
              ),
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                onTap: onInteracted,
                onChanged: (_) => onInteracted?.call(),
                validator: validator,
                obscureText: obscure,
                cursorColor: const Color(0xFF3B210F),
                style: GoogleFonts.fredoka(
                  color: const Color(0xFF321C0C),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.fredoka(
                    color: const Color(0xFF5D3B20).withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  contentPadding: EdgeInsets.fromLTRB(
                    52,
                    8,
                    showPasswordToggle ? 44 : 12,
                    8,
                  ),
                  suffixIcon: showPasswordToggle
                      ? IconButton(
                          onPressed: onToggleObscure,
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                          color: const Color(0xFF6A431F),
                          splashRadius: 18,
                        )
                      : null,
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.fredoka(
                color: const Color(0xFFFF8E8E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                shadows: const [Shadow(color: Colors.black, blurRadius: 3)],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FantasyButton extends StatelessWidget {
  const _FantasyButton({
    required this.text,
    required this.loading,
    required this.large,
    required this.onTap,
  });

  final String text;
  final bool loading;
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: CustomPaint(
          painter: _ButtonPainter(large: large),
          child: SizedBox(
            width: large ? 226 : 166,
            height: large ? 54 : 41,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF6A2C16),
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        style: GoogleFonts.fredoka(
                          color: large
                              ? const Color(0xFF783719)
                              : const Color(0xFFFFE8B7),
                          fontSize: large ? 23 : 18,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: large
                                  ? const Color(0xFFFFF6C8)
                                  : Colors.black,
                              blurRadius: large ? 4 : 3,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            color: const Color(0xFFFFD2C8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}

class _PanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final panel = RRect.fromRectAndRadius(
      rect.deflate(5),
      const Radius.circular(16),
    );
    canvas.drawShadow(Path()..addRRect(panel), Colors.black, 9, true);
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFE7BD66),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(12), const Radius.circular(12)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF6A431F),
    );
    final gemPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFE9B5), Color(0xFFB3142B)],
      ).createShader(Rect.fromCircle(center: rect.center, radius: 10));
    _gem(canvas, Offset(size.width / 2, 6), gemPaint);
    _gem(canvas, Offset(size.width / 2, size.height - 6), gemPaint);
    _gem(canvas, Offset(6, size.height / 2), gemPaint);
    _gem(canvas, Offset(size.width - 6, size.height / 2), gemPaint);
  }

  void _gem(Canvas canvas, Offset center, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - 7)
      ..lineTo(center.dx + 7, center.dy)
      ..lineTo(center.dx, center.dy + 7)
      ..lineTo(center.dx - 7, center.dy)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFFFD986),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InputPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(2);
    final path = Path()
      ..moveTo(r.left + 18, r.top)
      ..lineTo(r.right - 18, r.top)
      ..quadraticBezierTo(r.right, r.top, r.right, r.center.dy)
      ..quadraticBezierTo(r.right, r.bottom, r.right - 18, r.bottom)
      ..lineTo(r.left + 18, r.bottom)
      ..quadraticBezierTo(r.left, r.bottom, r.left, r.center.dy)
      ..quadraticBezierTo(r.left, r.top, r.left + 18, r.top)
      ..close();
    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFF0A8), Color(0xFFD69A43), Color(0xFFFFE99D)],
          stops: [0, 0.52, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(r),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF4D2B11),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ButtonPainter extends CustomPainter {
  const _ButtonPainter({required this.large});

  final bool large;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..moveTo(18, 0)
      ..lineTo(size.width - 18, 0)
      ..quadraticBezierTo(size.width, 0, size.width, size.height / 2)
      ..quadraticBezierTo(size.width, size.height, size.width - 18, size.height)
      ..lineTo(18, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height / 2)
      ..quadraticBezierTo(0, 0, 18, 0)
      ..close();
    canvas.drawShadow(
      path,
      large ? const Color(0xFFFF4217) : Colors.black,
      large ? 9 : 5,
      true,
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: large
              ? const [Color(0xFFFFF2B0), Color(0xFFE08C45), Color(0xFFFFE69A)]
              : const [Color(0xFF8E5A2F), Color(0xFF4B2414), Color(0xFFA86B35)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFD986),
    );
  }

  @override
  bool shouldRepaint(covariant _ButtonPainter oldDelegate) =>
      oldDelegate.large != large;
}







