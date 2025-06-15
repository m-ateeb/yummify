  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'firebase_options.dart';
  import 'router/app_router.dart';
  import 'core/theme/app_theme.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'home_screen.dart';
  import 'features/cookbook/presentation/screens/cookbook_screen.dart';
  import 'features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
  import 'features/user/presentation/screens/profile_screen.dart';
  import 'features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show FirebaseMessaging;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_native_splash/android.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'features/cookbook/presentation/screens/cookbook_screen.dart';
import 'features/calorietracker/presentation/screens/calorie_tracker_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import './core/services/notification_service.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    // Apply system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true, cacheSizeBytes: 10485760);
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
  await ensureUserInFirestore();
  await MobileAds.instance.initialize(); // Must call before running app
  await NotificationService.initializeLocalNotifications();
  await NotificationService.initializeFCM();

    runApp(ProviderScope(child: MyApp()));
  }

  Future<void> ensureUserInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      // New user: set all fields
      await userDoc.set({
        'uid': user.uid,
        'id': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'avatarUrl': user.photoURL,
        'role': 'user',
        'memberSince': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      // Existing user: update missing fields only
      Map<String, dynamic> updates = {};
      if (!doc.data()!.containsKey('role')) updates['role'] = 'user';
      if (!doc.data()!.containsKey('lastUpdated')) {
        updates['lastUpdated'] = FieldValue.serverTimestamp();
      }

      if (updates.isNotEmpty) {
        await userDoc.update(updates);
      }
    }
  }

  class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Yummify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // If the auth state is still loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Check if the user is logged in
            if (snapshot.hasData && snapshot.data != null) {
              // User is logged in, show the main navigation screen
              return const MainNavigationScreen();
            } else {
              // User is not logged in, show the login screen
              return const LoginScreen();
            }
          },
        ),
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          // Apply top-level font to the entire app
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      );
    }
  }

  class MainNavigationScreen extends StatefulWidget {
    const MainNavigationScreen({Key? key}) : super(key: key);

    @override
    State<MainNavigationScreen> createState() => _MainNavigationScreenState();
  }

  class _MainNavigationScreenState extends State<MainNavigationScreen>
      with SingleTickerProviderStateMixin {
    int _currentIndex = 0;
    late PageController _pageController;

    final List<Widget> _screens = [
      const HomeScreen(),
      const CookbookScreen(),
      const CalorieTrackerScreen(),
      const ProfileScreen(),
    ];

    @override
    void initState() {
      super.initState();
      _pageController = PageController(initialPage: _currentIndex);
    }

    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) {
                      setState(() => _currentIndex = index);
                      _pageController.jumpToPage(index);
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.book_outlined),
                        selectedIcon: Icon(Icons.book),
                        label: 'Cookbook',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.local_fire_department_outlined),
                        selectedIcon: Icon(Icons.local_fire_department),
                        label: 'Calories',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
