import 'package:flutter/material.dart';
import 'package:mi_app/main.dart';
import 'package:mi_app/models/user_storage.dart';
import '../app_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- LÓGICA ---
  void _logout(BuildContext context) async {
    await UserStorage.logout();
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Recuperar datos del rol
    final UserRole userRole = ModalRoute.of(context)!.settings.arguments as UserRole;
    final String roleName = userRole.name.toUpperCase();
    final bool isAdmin = userRole == UserRole.admin;

    return Scaffold(
      extendBodyBehindAppBar: true, // Para que la imagen suba hasta la barra de estado
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Barra transparente
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Cerrar Sesión",
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // CAPA 1: IMAGEN DE FONDO (Cámbiala por tu imagen local o url)
          Positioned.fill(
            child: Image.network(
              'https://laguajirahoy.com/wp-content/uploads/2015/09/Unas-rutas-de-transportes-ha-dispuesto-la-Universidad-de-La-Guajira.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // CAPA 2: FILTRO OSCURO (Para que se lea el texto)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0A1E3C).withOpacity(0.85), // Azul oscuro muy elegante
            ),
          ),

          // CAPA 3: EFECTO MECUADRICULADO (GRID)
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(), // Usamos el pintor personalizado de abajo
            ),
          ),

          // CAPA 4: CONTENIDO REAL
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ENCABEZADO
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.school,
                          size: 35,
                          color: const Color(0xFF0A1E3C),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            roleName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text(
                    "PANEL DE CONTROL",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- TARJETAS DE MENÚ ---
                  
                  // 1. Mi Perfil
                  _buildProCard(
                    context,
                    title: 'Mi Perfil',
                    subtitle: 'Datos y Seguridad',
                    icon: Icons.account_circle,
                    color1: Colors.purple.shade400,
                    color2: Colors.purple.shade700,
                    route: profileRoute,
                  ),

                  // 2. Estado de Rutas
                  _buildProCard(
                    context,
                    title: 'Estado de Rutas',
                    subtitle: 'Monitoreo en tiempo real',
                    icon: Icons.directions_bus,
                    color1: Colors.blue.shade400,
                    color2: Colors.blue.shade800,
                    route: routeStatusRoute,
                  ),

                  // 3. Chat Global
                  _buildProCard(
                    context,
                    title: 'Chat Global',
                    subtitle: 'Comunidad Universitaria',
                    icon: Icons.forum,
                    color1: Colors.teal.shade400,
                    color2: Colors.teal.shade700,
                    route: chatRoute,
                  ),

                  // 4. Panel Admin (Solo si es Admin)
                  if (isAdmin)
                    _buildProCard(
                      context,
                      title: 'Administración',
                      subtitle: 'Gestión de Usuarios',
                      icon: Icons.settings_applications,
                      color1: Colors.orange.shade400,
                      color2: Colors.deepOrange.shade700,
                      route: adminPanelRoute,
                    ),

                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '© 2025 Universidad de La Guajira',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TARJETA PROFESIONAL (Con gradiente) ---
  Widget _buildProCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CLASE PARA DIBUJAR EL MECUADRICULADO (GRID) ---
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05) // Color de la línea muy sutil
      ..strokeWidth = 1;

    const double step = 40; // Tamaño de cada cuadro

    // Líneas verticales
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}