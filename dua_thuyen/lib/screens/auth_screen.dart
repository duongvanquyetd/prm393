import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/audio_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool loading = false;
  bool hidePassword = true;

  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Future.microtask(() {
      GameAudioService.instance.ensureBackgroundMusic();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final name = nameCtrl.text.trim();
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (!isLogin && name.isEmpty) {
      showMessage('Vui lòng nhập tên người dùng');
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      showMessage('Vui lòng nhập đầy đủ tài khoản và mật khẩu');
      return;
    }

    if (password.length < 4) {
      showMessage('Mật khẩu tối thiểu 4 ký tự');
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        final res = await AuthService.login(username, password);

        if (res['ok'] == true && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                userId: res['userId'] as int,
                initialMoney: (res['price'] as num).toInt(),
                landscapeMode: false,
              ),
            ),
          );
        } else {
          showMessage('Tài khoản hoặc mật khẩu không đúng');
        }
      } else {
        final res = await AuthService.register(name, username, password);

        if (res['ok'] == true) {
          if (!mounted) return;

          setState(() {
            isLogin = true;
            hidePassword = true;
            nameCtrl.clear();
            passwordCtrl.clear();
          });

          showMessage('Đăng ký thành công, hãy đăng nhập');
        } else {
          showMessage('Đăng ký thất bại hoặc tài khoản đã tồn tại');
        }
      }
    } catch (e) {
      showMessage('Có lỗi xảy ra, vui lòng thử lại');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange,
              ),
              SizedBox(width: 8),
              Text('Thông báo'),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void switchMode() {
    setState(() {
      isLogin = !isLogin;
      hidePassword = true;
      nameCtrl.clear();
      usernameCtrl.clear();
      passwordCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/duong_dua.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Text(
                      'Thiên mã bất bại',
                      style: GoogleFonts.fredoka(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xffffd54f),
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isLogin ? 'Vào đường đua ngay!' : 'Tạo tay đua mới',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xffffcc66).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xff5d3212),
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            isLogin
                                ? 'assets/images/ngua_do_1.png'
                                : 'assets/images/ngua_xanh_la_cay_1.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 14),

                          Text(
                            isLogin ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ',
                            style: GoogleFonts.fredoka(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xff3b2412),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (!isLogin) ...[
                            _RaceInput(
                              controller: nameCtrl,
                              label: 'Tên người dùng',
                              hint: 'Ví dụ: user1',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 14),
                          ],

                          _RaceInput(
                            controller: usernameCtrl,
                            label: 'Tên đăng nhập',
                            hint: 'Nhập tên đăng nhập',
                            icon: Icons.sports_motorsports,
                          ),

                          const SizedBox(height: 14),

                          _RaceInput(
                            controller: passwordCtrl,
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu',
                            icon: Icons.lock,
                            obscure: hidePassword,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xff5d3212),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: loading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffffb300),
                                foregroundColor: Colors.black,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Color(0xff4a280d),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                                  : Text(
                                isLogin ? 'BẮT ĐẦU ĐUA' : 'TẠO TÀI KHOẢN',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: loading ? null : switchMode,
                            child: Text(
                              isLogin
                                  ? 'Chưa có tài khoản? Đăng ký ngay'
                                  : 'Đã có tài khoản? Đăng nhập',
                              style: GoogleFonts.fredoka(
                                color: const Color(0xff3b2412),
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _RaceInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.fredoka(
            color: const Color(0xff3b2412),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.fredoka(
            color: const Color(0xff2a1708),
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xff5d3212)),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xfffff3c4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xff6b3a14),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xffff9800),
                width: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}