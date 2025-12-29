import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:project_uts_pariwisata/Admin/dashboard_admin.dart';
import '../widget/home_page.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import 'package:project_uts_pariwisata/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    String? result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  AdminDashboardPage()),
      );
    } else if (result == 'User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Gagal: $result'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF21899C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Stack(
              children: <Widget>[
            

                Positioned(
                  top: 8.0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height - 8.0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                           
                                const SizedBox(height: 16),
                                richText(23.12),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Continue with email for sign in App',
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                emailTextField(size),
                                const SizedBox(height: 8),
                                passwordTextField(size),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                signInButton(size),
                                const SizedBox(height: 16),
                                // buildContinueText(),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              
                                const SizedBox(height: 16),
                                buildFooter(size),
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
          ),
        ),
      ),
    );
  }



  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 23.12,
          color: Colors.white,
          letterSpacing: 1.999999953855673,
        ),
        children: const [
          TextSpan(
            text: 'LOGIN',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: 'PAGE',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFF4DA1B0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.mail_rounded, color: Colors.white70),
            const SizedBox(width: 16),

       
            const SizedBox(width: 16),

            Expanded(
              child: TextField(
                controller: _emailController,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your gmail address',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xFF4DA1B0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.lock, color: Colors.white70),
            const SizedBox(width: 16),

          
            const SizedBox(width: 16),

            Expanded(
              child: TextField(
                controller: _passwordController,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.visiblePassword,
                obscureText: isPasswordHidden,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signInButton(Size size) {
    return InkWell(
      onTap: _isLoading ? null : _login,
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: _isLoading
              ? const Color(0xFFF56B3F).withOpacity(0.5)
              : const Color(0xFFF56B3F),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }



  Widget buildFooter(Size size) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          );
        },
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.nunito(fontSize: 16.0, color: Colors.white),
            children: [
              TextSpan(
                text: 'Don’t have account? ',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: 'Sign up',
                style: GoogleFonts.nunito(
                  color: const Color(0xFFF9CA58),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
