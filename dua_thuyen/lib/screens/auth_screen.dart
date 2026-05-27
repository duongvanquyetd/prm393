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
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  // Controllers for registration form
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  // Separate controllers for login form to avoid cross-population
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  final Set<String> _activeEditingFields = <String>{};
  // Server-side field errors, keys: 'username', 'password', 'general'
  Map<String, String> _serverErrors = {};

  // A highly advanced single-step matrix filter that tints the dragon emblem into
  // a solid, high-contrast dark brown color (RGB = 62, 39, 35) while preserving its exact transparent shape.
  // This completely eliminates any black smudges or rendering glitches from nested ColorFiltered widgets!
  static const ColorFilter brownCarvingFilter = ColorFilter.matrix(<double>[
    0.0, 0.0, 0.0, 0.0, 62.0,  // R: force R to 62 (dark brown)
    0.0, 0.0, 0.0, 0.0, 39.0,  // G: force G to 39
    0.0, 0.0, 0.0, 0.0, 35.0,  // B: force B to 35
    3.8, 3.8, 3.8, 0.0, -110.0, // A: Alpha mask based on original image brightness
  ]);

  void toggle() {
    setState(() {
      isLogin = !isLogin;
      _serverErrors.clear();
    });
  }

  void _switchAuthMode(bool loginMode) {
    if (isLogin == loginMode) return;
    setState(() {
      isLogin = loginMode;
      _serverErrors.clear();
      _submitted = false;
      _activeEditingFields.clear();
    });
  }

  void _resetAllFieldsToInitialState({required bool loginMode}) {
    setState(() {
      isLogin = loginMode;
      _loading = false;
      _submitted = false;
      _activeEditingFields.clear();
      _serverErrors.clear();

      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _loginEmailCtrl.clear();
      _loginPasswordCtrl.clear();
      _confirmCtrl.clear();

      _formKey.currentState?.reset();
    });
  }

  void _onFieldTap(String field) {
    setState(() {
      _activeEditingFields.add(field);
      _serverErrors.remove(field);
      _serverErrors.remove('general');
    });
  }

  void _onFieldChanged(String field, String _) {
    if (_activeEditingFields.remove(field)) {
      setState(() {});
    }
    if (_submitted) {
      _formKey.currentState?.validate();
    }
  }

  String? _requiredValidator(String field, String? v) {
    if (!_submitted || _activeEditingFields.contains(field)) return null;
    if (v == null || v.isEmpty) return 'Trường này bắt buộc';
    return null;
  }

  String? _registerPasswordValidator(String? v) {
    const field = 'register-password';
    if (!_submitted || _activeEditingFields.contains(field)) return null;
    if (v == null || v.isEmpty) return 'Trường này bắt buộc';
    if (v.length < 5) return 'Mật khẩu tối thiểu 5 ký tự';
    return null;
  }

  String? _confirmPasswordValidator(String? v) {
    const field = 'register-confirm-password';
    if (!_submitted || _activeEditingFields.contains(field)) return null;
    if (v == null || v.isEmpty) return 'Trường này bắt buộc';
    if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
    return null;
  }

  Future<void> submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _submitted = true;
      _activeEditingFields.clear();
      _serverErrors.clear();
    });
    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (isLogin) {
        final res = await AuthService.login(_loginEmailCtrl.text, _loginPasswordCtrl.text);
        if (res is Map && res['ok'] == true) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công', style: TextStyle(color: Color(0xFFFFF0C2))),
              backgroundColor: Color(0xFF5D4037),
            ),
          );
          // Navigate to Home screen and replace the auth screen.
          if (mounted) {
            final displayName = (res['name'] ?? _loginEmailCtrl.text).toString();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomeScreen(name: displayName)),
            );
          }
        } else {
          // Try show specific server message
          _serverErrors.clear();
          if (res is Map && res['body'] != null) {
            final body = res['body'];
            if (body is Map && body['error'] != null) {
              final err = body['error'].toString();
              if (err.toLowerCase().contains('invalid')) {
                _serverErrors['general'] = 'Tài khoản hoặc mật khẩu chưa chính xác';
              } else {
                _serverErrors['general'] = err;
              }
            } else {
              _serverErrors['general'] = body.toString();
            }
          } else {
            _serverErrors['general'] = 'Đăng nhập thất bại';
          }
          setState(() {});
        }
      } else {
        // Clear server errors before register
        _serverErrors.clear();
        final res = await AuthService.register(_nameCtrl.text, _emailCtrl.text, _passwordCtrl.text);
        if (res is Map && res['ok'] == true) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công', style: TextStyle(color: Color(0xFFFFF0C2))),
              backgroundColor: Color(0xFF5D4037),
            ),
          );
          if (mounted) {
            _resetAllFieldsToInitialState(loginMode: true);
          }
        } else {
          // Show detailed server error under the relevant field(s)
          if (res is Map) {
            final body = res['body'];
            if (body is Map && body['error'] != null) {
              final err = body['error'].toString();
              // Map common server messages to fields
              if (err.toLowerCase().contains('exists') || err.toLowerCase().contains('user')) {
                _serverErrors['username'] = 'Tài khoản đã tồn tại';
              } else if (err.toLowerCase().contains('missing')) {
                _serverErrors['general'] = err;
              } else {
                _serverErrors['general'] = err;
              }
            } else {
              _serverErrors['general'] = body.toString();
            }
          } else {
            _serverErrors['general'] = 'Đăng ký thất bại';
          }
          setState(() {});
        }
        // If registration succeeded, prefer navigating to Home with the character name
        if (res is Map && res['ok'] == true) {
          if (mounted) {
            final displayName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (res['name']?.toString() ?? _emailCtrl.text);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(name: displayName)));
          }
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
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // 1. Beautiful generated 2D cartoon game landscape background (100% clean, no text, no loading bar!)
          Positioned.fill(
            child: Image.asset(
              'assets/images/dua_thuyen_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Extremely light cyan vignette overlay to preserve the brightness of the background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE0F7FA).withValues(alpha: 0.05),
                    const Color(0xFF0F2537).withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // 2. Main content scrollable area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Vertical stacked 3D metallic cartoon game logo "ĐUA THUYỀN RỒNG" in Bungee/Fredoka Font
                    _buildGameLogo(),
                    const SizedBox(height: 18),
                    // Light beige cartoon wooden card board with gold borders and colorful feathers
                    _buildCartoonCard(width),
                    const SizedBox(height: 24),
                    // Footer details
                    _buildFooterTerms(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _build3DText('ĐUA', fontSize: 46, letterSpacing: -2.0),
        Transform.translate(
          offset: const Offset(0, -12),
          child: _build3DText('THUYỀN', fontSize: 52, letterSpacing: -3.0),
        ),
        Transform.translate(
          offset: const Offset(0, -24),
          child: _build3DText('RỒNG', fontSize: 56, letterSpacing: -2.0),
        ),
      ],
    );
  }

  Widget _build3DText(String text, {required double fontSize, double letterSpacing = -1.5}) {
    const outlineColor = Color(0xFF4E260A); // Deep chocolate brown

    final List<Widget> layers = [];

    // 1. Extreme background thick outline shadow (deep 3D base)
    layers.add(
      Transform.translate(
        offset: const Offset(2.0, 8.0),
        child: Text(
          text,
          style: GoogleFonts.lilitaOne(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 14.0
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor.withValues(alpha: 0.45),
          ),
        ),
      ),
    );

    // 2. Thick outline shadow (solid)
    layers.add(
      Transform.translate(
        offset: const Offset(1.5, 6.0),
        child: Text(
          text,
          style: GoogleFonts.lilitaOne(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12.0
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
          ),
        ),
      ),
    );

    // 3. 3D Extrusion block - loop of multiple fill layers going from back to front
    const int extrusionSteps = 6;
    for (int i = extrusionSteps; i >= 1; i--) {
      final double dx = (i / extrusionSteps) * 1.5;
      final double dy = (i / extrusionSteps) * 6.0;
      layers.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Text(
            text,
            style: GoogleFonts.lilitaOne(
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 8.0
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..color = outlineColor,
            ),
          ),
        ),
      );
      layers.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Text(
            text,
            style: GoogleFonts.lilitaOne(
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              color: outlineColor,
            ),
          ),
        ),
      );
    }

    // 4. Main clean outer border at y=0, x=0
    layers.add(
      Text(
        text,
        style: GoogleFonts.lilitaOne(
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = outlineColor,
        ),
      ),
    );

    // 5. Front Gradient text
    layers.add(
      ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Color(0xFFFFFEE0), // Top: light cream yellow
              Color(0xFFFFD54F), // Middle top: warm gold
              Color(0xFFFF8F00), // Middle bottom: rich amber
              Color(0xFFD84315), // Bottom: deep red-orange
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);
        },
        child: Text(
          text,
          style: GoogleFonts.lilitaOne(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            color: Colors.white,
          ),
        ),
      ),
    );

    // 6. Subtle inner white highlight / glint (offset 1px up and left)
    layers.add(
      Transform.translate(
        offset: const Offset(-0.5, -0.5),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.80),
                Colors.white.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: Text(
            text,
            style: GoogleFonts.lilitaOne(
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = Colors.white,
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: layers,
    );
  }

  Widget _buildCartoonCard(double screenWidth) {
    final cardWidth = screenWidth < 400 ? screenWidth * 0.92 : 380.0;
    final activeTabWidth = (cardWidth - 40.0) / 2.0;

    return SizedBox(
      width: cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A. Light Wood Plank Card Body stained in friendly cartoon beige.
          // Stained with 90% opacity cream color overlay using BlendMode.srcOver to make the wood plank
          // cracks very soft and light brown, ensuring they never look like strikethroughs behind labels!
          Container(
            margin: const EdgeInsets.only(top: 40), // Spacing for top overlapping tabs
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: const AssetImage('assets/images/wood_board_texture.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFFFFF9E6).withValues(alpha: 0.90), // Blend 90% solid cream over wood
                  BlendMode.srcOver,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15), // Gold outer glow
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45), // Shadow
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CustomPaint(
              painter: GameBoardPainter(),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      if (isLogin) ...[
                        // LOGIN FORM
                        _buildLabel('Tên đăng nhập', icon: Icons.person),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('login-username'),
                          controller: _loginEmailCtrl,
                          hint: 'Nhập tên đăng nhập',
                          icon: Icons.person,
                          validator: (v) => _requiredValidator('login-username', v),
                          onFieldTap: () => _onFieldTap('login-username'),
                          onFieldChanged: (v) => _onFieldChanged('login-username', v),
                          errorText: _serverErrors['username'],
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Mật khẩu', icon: Icons.key),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('login-password'),
                          controller: _loginPasswordCtrl,
                          hint: 'Mật khẩu',
                          obscure: true,
                          isPasswordField: true,
                          validator: (v) => _requiredValidator('login-password', v),
                          onFieldTap: () => _onFieldTap('login-password'),
                          onFieldChanged: (v) => _onFieldChanged('login-password', v),
                          errorText: _serverErrors['password'],
                        ),
                      ] else ...[
                        // REGISTER FORM (Styled identically and beautifully matching login)
                        _buildLabel('Tên nhân vật', icon: Icons.stars),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('register-character-name'),
                          controller: _nameCtrl,
                          hint: 'Nhập tên nhân vật',
                          icon: Icons.person,
                          validator: (v) => _requiredValidator('register-character-name', v),
                          onFieldTap: () => _onFieldTap('register-character-name'),
                          onFieldChanged: (v) => _onFieldChanged('register-character-name', v),
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Tên đăng nhập', icon: Icons.person),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('register-username'),
                          controller: _emailCtrl,
                          hint: 'Nhập tên đăng nhập',
                          icon: Icons.person,
                          validator: (v) => _requiredValidator('register-username', v),
                          onFieldTap: () => _onFieldTap('register-username'),
                          onFieldChanged: (v) => _onFieldChanged('register-username', v),
                          errorText: _serverErrors['username'],
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Mật khẩu', icon: Icons.key),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('register-password'),
                          controller: _passwordCtrl,
                          hint: 'Nhập mật khẩu',
                          obscure: true,
                          isPasswordField: true,
                          validator: _registerPasswordValidator,
                          onFieldTap: () => _onFieldTap('register-password'),
                          onFieldChanged: (v) => _onFieldChanged('register-password', v),
                        ),
                        const SizedBox(height: 14),
                        _buildLabel('Nhập lại mật khẩu', icon: Icons.key_off),
                        const SizedBox(height: 4),
                        CustomTextField(
                          key: const ValueKey('register-confirm-password'),
                          controller: _confirmCtrl,
                          hint: 'Nhập lại mật khẩu',
                          obscure: true,
                          isConfirmPasswordField: true,
                          validator: _confirmPasswordValidator,
                          onFieldTap: () => _onFieldTap('register-confirm-password'),
                          onFieldChanged: (v) => _onFieldChanged('register-confirm-password', v),
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (_serverErrors['general'] != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _serverErrors['general']!,
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 12),
                      // Forgot password link (only for login view)
                      if (isLogin) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chức năng đang phát triển', style: TextStyle(color: Color(0xFFFFF0C2))),
                                  backgroundColor: Color(0xFF5D4037),
                                ),
                              );
                            },
                            child: Text(
                              'Quên mật khẩu?',
                              style: GoogleFonts.fredoka(
                                color: const Color(0xFF5D4037),
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Gold/Orange gradient cartoon submit button "VÀO GAME!" or "ĐĂNG KÝ!"
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // B. Overlapping Tabs with precise alignment
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _buildTab('ĐĂNG NHẬP', isLogin, () {
                  _switchAuthMode(true);
                }),
                const SizedBox(width: 8),
                _buildTab('ĐĂNG KÝ', !isLogin, () {
                  _switchAuthMode(false);
                }),
              ],
            ),
          ),

          // C. Colorful Feathers flanking the active tab. Drawn organically via CustomPainter!
          // This completely solves the messy box/overlapping issue!
          Positioned(
            top: -12,
            left: isLogin ? 2 : activeTabWidth + 6,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(20, 48),
                painter: FeatherPainter(isLeft: true),
              ),
            ),
          ),
          Positioned(
            top: -12,
            left: isLogin ? activeTabWidth - 22 : cardWidth - 22,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(20, 48),
                painter: FeatherPainter(isLeft: false),
              ),
            ),
          ),

          // D. Cute filled water droplets scattered on the board corners (clean, filled blue, no hollow circles!)
          Positioned(
            top: 48,
            left: 16,
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF29B6F6).withValues(alpha: 0.85),
              size: 14,
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF29B6F6).withValues(alpha: 0.85),
              size: 14,
            ),
          ),
          Positioned(
            bottom: 14,
            left: 14,
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF29B6F6).withValues(alpha: 0.85),
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          color: icon == Icons.key || icon == Icons.key_off ? const Color(0xFFFFB300) : const Color(0xFFFF9800),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.fredoka(
            color: const Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFF6E6) : const Color(0xFF8D6E63),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            border: Border.all(
              color: isActive ? const Color(0xFFFFB300) : const Color(0xFF5D4037),
              width: isActive ? 2.2 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, -3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                color: isActive ? const Color(0xFF5D4037) : const Color(0xFFD7CCC8),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
                shadows: isActive
                    ? [
                        const Shadow(
                          color: Colors.white,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedScale(
      scale: _loading ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _loading ? null : submit,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF59D),
                  Color(0xFFFFB300),
                  Color(0xFFE65100),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFD84315), width: 2.2),
            ),
            child: _loading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(right: 8),
                        child: ColorFiltered(
                          colorFilter: brownCarvingFilter,
                          child: Image.asset(
                            'assets/images/dragon_emblem.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      _buildButtonText(isLogin ? 'VÀO GAME!' : 'ĐĂNG KÝ!'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonText(String text) {
    return Stack(
      children: [
        // Outline shadow back layer
        Text(
          text,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5.0
              ..color = const Color(0xFF3E2723),
          ),
        ),
        // Front white text
        Text(
          text,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterTerms() {
    return Text.rich(
      TextSpan(
        text: 'Bằng cách đăng ký, bạn đồng ý với ',
        style: GoogleFonts.fredoka(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, shadows: [
          const Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
        ]),
        children: [
          TextSpan(
            text: 'Điều khoản',
            style: const TextStyle(
              color: Color(0xFFFFF9C4),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: ' và '),
          TextSpan(
            text: 'Điều kiện',
            style: const TextStyle(
              color: Color(0xFFFFF9C4),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool isPasswordField;
  final bool isConfirmPasswordField;
  final String? errorText;
  final VoidCallback? onFieldTap;
  final ValueChanged<String>? onFieldChanged;
  final IconData? icon;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.isPasswordField = false,
    this.isConfirmPasswordField = false,
    this.errorText,
    this.onFieldTap,
    this.onFieldChanged,
    this.icon,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      _obscureText = widget.obscure;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5), // Light warm cream background y chang mẫu
        borderRadius: BorderRadius.circular(24), // Highly rounded
        border: Border.all(
          color: _isFocused ? const Color(0xFFFFB300) : const Color(0xFF5D4037), // Gold on focus, brown on enabled
          width: 2.2, // Thick border
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscureText,
        onTap: widget.onFieldTap,
        onChanged: widget.onFieldChanged,
        style: GoogleFonts.fredoka(color: const Color(0xFF5D4037), fontSize: 16, fontWeight: FontWeight.bold),
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.fredoka(color: const Color(0xFF8D6E63), fontSize: 14.5, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          errorText: widget.errorText,
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: widget.icon == Icons.key ? const Color(0xFFFFB300) : const Color(0xFF8D6E63),
                  size: 20,
                )
              : null,
          suffixIcon: widget.isPasswordField || widget.isConfirmPasswordField
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF8D6E63),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class GameBoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paintOuter = Paint()
      ..color = const Color(0xFF5D4037) // Outer double thick brown border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final paintInner = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: 0.4) // Inner gold border accent line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw outer frame
    final outerRRect = RRect.fromRectAndRadius(rect.deflate(2.0), const Radius.circular(20));
    canvas.drawRRect(outerRRect, paintOuter);

    // Draw inner border accent
    final innerRRect = RRect.fromRectAndRadius(rect.deflate(6.0), const Radius.circular(16));
    canvas.drawRRect(innerRRect, paintInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw beautiful organic, rounded feathers fanning out gracefully flanking the active tab!
// This completely fixes the messy rectangular box overlapping glitch.
class FeatherPainter extends CustomPainter {
  final bool isLeft;

  FeatherPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFBA68C8), // Purple
      const Color(0xFF81C784), // Green
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF64B5F6), // Blue
      const Color(0xFFF06292), // Pink
    ];

    final borderPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Fan out 5 organic feather wings symmetrically
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.save();

      // Translate to joint origin point
      canvas.translate(isLeft ? size.width * 0.2 : size.width * 0.8, size.height * 0.7);

      // Rotate organically
      final double progress = i / (colors.length - 1); // 0.0 to 1.0
      final double baseAngle = isLeft ? -0.55 : 0.55;
      final double rotation = baseAngle + (isLeft ? 1.05 : -1.05) * progress;

      canvas.rotate(rotation);

      // Draw smooth, organic feather leaf shape (perfectly rounded top, tapered bottom)
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-7, -8, -7, -20, 0, -24)
        ..cubicTo(7, -20, 7, -8, 0, 0)
        ..close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
