import 'package:flutter/material.dart';

// --- IMPORTACIONES RELATIVAS (Funcionan siempre) ---
import 'screens/LoginScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/RouteStatusScreen.dart';
import 'screens/Chat_Screen.dart';
import 'screens/Admin_Panel_Screen.dart';
import 'screens/ProfileScreen.dart'; // Asegúrate de haber creado este archivo
import 'models/user_storage.dart';
import 'models/user_model.dart';
import 'app_config.dart'; // Para UserRole

// Definición de rutas
const String loginRoute = '/login';
const String homeRoute = '/home';
const String registerRoute = '/register';
const String routeStatusRoute = '/route_status';
const String chatRoute = '/chat';
const String adminPanelRoute = '/admin_panel';
const String profileRoute = '/profile';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Rutas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Cambiado a Indigo para combinar con tu diseño
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      // USAMOS 'home' CON UN VERIFICADOR DE SESIÓN
      home: const AuthCheck(),
      routes: {
        loginRoute: (context) => const LoginScreen(),
        homeRoute: (context) => const HomeScreen(),
        registerRoute: (context) => const RegisterScreen(),
        routeStatusRoute: (context) => const RouteStatusScreen(),
        chatRoute: (context) => const ChatScreen(),
        adminPanelRoute: (context) => const AdminPanelScreen(),
        profileRoute: (context) => const ProfileScreen(),
      },
    );
  }
}

/// Widget que decide si mostrar Login o Home al iniciar la app
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: UserStorage.getActiveSession(), // Pregunta si hay sesión guardada
      builder: (context, snapshot) {
        // 1. Cargando...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay usuario, vamos directo al Home (Wrapper necesario para pasar argumentos)
        if (snapshot.hasData && snapshot.data != null) {
          return HomeWrapper(role: snapshot.data!.role);
        }

        // 3. Si no, vamos al Login
        return const LoginScreen();
      },
    );
  }
}

/// Pequeño wrapper para iniciar el Home correctamente
class HomeWrapper extends StatefulWidget {
  final UserRole role;
  const HomeWrapper({super.key, required this.role});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  @override
  void initState() {
    super.initState();
    // Navegar al Home real después de que se construya el frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        homeRoute,
        arguments: widget.role,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga momentánea mientras redirige
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}