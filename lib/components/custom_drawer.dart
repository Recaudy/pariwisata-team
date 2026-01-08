import 'package:flutter/material.dart';
import 'package:project_uts_pariwisata/widget/chat_bot_ai.dart';
import 'package:project_uts_pariwisata/widget/welcome_page.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../login/login_screen.dart';
import '../widget/profile_page.dart';
import '../widget/cuaca_page.dart';

const Color primaryColor = Color(0xFF21899C);
const Color primaryDark = Color(0xFF1B6F7D);

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  void _navigateToProfile() {
    Navigator.pop(context);

    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InformasiProfil(user: _currentUser!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu.')),
      );
    }
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _isLoading
        ? 'Loading...'
        : (_currentUser?.name ?? 'Guest User');
    final email = _isLoading ? '' : (_currentUser?.email ?? 'Silakan Login');

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: primaryColor,
      child: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: _navigateToProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryDark,
                      backgroundImage:
                          (_currentUser?.photoUrl != null &&
                              _currentUser!.photoUrl!.isNotEmpty)
                          ? NetworkImage(_currentUser!.photoUrl!)
                                as ImageProvider
                          : null,
                      child:
                          (_currentUser?.photoUrl == null ||
                              _currentUser!.photoUrl!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: Colors.white30),
            _drawerItem(
              icon: Icons.map_rounded,
              title: 'Maps',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              },
            ),
            _drawerItem(
              icon: Icons.chat_bubble_outline,
              title: 'Assistant AI',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
            ),
            _drawerItem(
              icon: Icons.wb_sunny_outlined,
              title: 'Cuaca',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherPage()),
                );
              },
            ),

            const Spacer(),

            _drawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.white,
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: selected ? primaryDark : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        onTap: onTap,
      ),
    );
  }
}
