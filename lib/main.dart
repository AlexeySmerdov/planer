import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/tags_management_screen.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create providers and run app immediately
  final taskProvider = TaskProvider();
  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();
  
  runApp(MyApp(
    taskProvider: taskProvider,
    authProvider: authProvider,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final TaskProvider taskProvider;
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;

  const MyApp({
    super.key,
    required this.taskProvider,
    required this.authProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Task Planner',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C5CE7),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C5CE7),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2D3436),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            routes: {
              '/tags_management': (context) => const TagsManagementScreen(),
            },
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return const HomeScreen();
                } else {
                  return const AuthScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
} 