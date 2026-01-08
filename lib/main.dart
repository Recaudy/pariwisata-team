import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'login/login_screen.dart';
import 'widget/home_page.dart';
import 'widget/wisata_tab_view_page.dart';
import 'widget/profile_page.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';

const Color mainColor = Color(0xFF21899C);
const Color subColor = Color(0xFFE6F4F6);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://roiijvdtvibojxdbqdqk.supabase.co',
    anonKey: 'sb_publishable_Z9P1AeHVKFKOEETum3_T0Q_m7_-f4Wg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pariwisata App',
      theme: ThemeData(
        scaffoldBackgroundColor: subColor,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: mainColor,
          unselectedItemColor: Colors.grey,
          elevation: 10,
        ),
      ),
      home: const LoginScreen(),
      routes: {'/main': (context) => const MainScreen()},
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isFetching = true;

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
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(
        backgroundColor: subColor,
        body: Center(child: CircularProgressIndicator(color: mainColor)),
      );
    }

    final userToShow =
        _currentUser ??
        UserModel(
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
          name: 'Guest',
          email: FirebaseAuth.instance.currentUser?.email ?? '',
          role: 'User',
          photoUrl: '',
        );

    final List<Widget> pages = [
      const HomePageWidget(),
      const WisataTabViewPage(),
      InformasiProfil(user: userToShow),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: mainColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore, color: mainColor),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: mainColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
