import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart'; 
import '../services/auth_service.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  // Controllers dari SignupScreen
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Role HANYA diatur di sini, tidak ada interaksi UI.
  String _selectedRole = 'User'; // Default role disetel otomatis ke 'User'

  bool _isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Signup
  void _signup() async {
    // Menghilangkan fokus keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true; // Tampilkan spinner
    });

    String? result = await _authService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole, // Mengirim 'User' secara otomatis
    );

    setState(() {
      _isLoading = false; // Sembunyikan spinner
    });

    if (result == null) {
      // Signup berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup Berhasil! Silakan Login.'),
          backgroundColor: Color(0xFF00AD8F),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Signup gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup Gagal: $result'),
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
                // Desain latar belakang kiri
               

                // UI konten
                Positioned(
                  top: 8.0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bagian logo
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

                          // Form pendaftaran (Nama, Email, Password)
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                nameTextField(size),
                                const SizedBox(height: 8),
                                emailTextField(size),
                                const SizedBox(height: 8),
                                passwordTextField(size),
                                // Menambah jarak karena roleDropdown dihapus
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),

                          // Tombol Sign up
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                signUpButton(size),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),

                          // Footer: sudah punya akun? Login
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [buildFooter(size)],
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
            text: 'SIGNUP',
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

  // Widget baru untuk nama
  Widget nameTextField(Size size) {
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
            const Icon(Icons.person, color: Colors.white70),
            const SizedBox(width: 16),
      
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _nameController,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.name,
                style: GoogleFonts.inter(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
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

  // Widget emailTextField diadaptasi
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

  // Widget passwordTextField diadaptasi
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


  // Widget signUpButton diadaptasi
  Widget signUpButton(Size size) {
    return InkWell(
      onTap: _isLoading ? null : _signup,
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
                'Sign Up',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Widget buildFooter diadaptasi untuk navigasi ke LoginScreen
  Widget buildFooter(Size size) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.nunito(fontSize: 16.0, color: Colors.white),
            children: [
              TextSpan(
                text: 'Already have an account? ',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: 'Login', // Diubah menjadi Login
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
