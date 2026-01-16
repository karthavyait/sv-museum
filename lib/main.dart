import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'data/repositories/exhibit_repository.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/visitor/visitor_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuseumApp());
}

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viveka Anubhuti',
      theme: AppTheme.build(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ExhibitRepository _repository = ExhibitRepository();
  int _currentIndex = 0;
  bool _adminUnlocked = false;
  int _visitorRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _repository.ensureSeedData();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _visitorRefreshToken += 1;
      }
    });
  }

  void _unlockAdmin() {
    setState(() {
      _adminUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitor = VisitorHomeScreen(
      key: ValueKey(_visitorRefreshToken),
      repository: _repository,
    );

    final admin = _adminUnlocked
        ? AdminDashboardScreen(repository: _repository)
        : AdminLoginScreen(onAuthenticated: _unlockAdmin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viveka Anubhuti'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          visitor,
          admin,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Visitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_outline),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
