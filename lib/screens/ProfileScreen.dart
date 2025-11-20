import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  // Controladores
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final user = await UserStorage.getActiveSession();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  // --- VALIDACIÓN DE SEGURIDAD (Igual que en Registro) ---
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe contener al menos un número';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener una mayúscula';
    if (value == _oldPassController.text) return 'La nueva contraseña debe ser diferente';
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    // A. Validar contraseña anterior
    if (_oldPassController.text != _currentUser!.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña actual no es correcta"), backgroundColor: Colors.red),
      );
      return;
    }

    // B. Actualizar
    final updatedUser = UserModel(
      email: _currentUser!.email,
      password: _newPassController.text,
      role: _currentUser!.role,
    );

    setState(() => _isLoading = true);

    // C. Guardar y Salir
    await UserStorage.editUser(_currentUser!.email, updatedUser);
    await UserStorage.logout();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Contraseña actualizada! Inicia sesión nuevamente."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // --- PANELES DE INFORMACIÓN LEGAL ---
  void _showLegalInfo(String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Gris muy suave profesional
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN 1: DATOS DEL USUARIO ---
                  _buildSectionTitle("Información Personal"),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.indigo[50],
                            child: const Icon(Icons.person, size: 40, color: Colors.indigo),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Correo Institucional", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                Text(_currentUser?.email ?? "...", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(8)),
                                  child: Text("ROL: ${_currentUser?.role.name.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- SECCIÓN 2: SEGURIDAD ---
                  _buildSectionTitle("Seguridad de la Cuenta"),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _oldPassController,
                              obscureText: true,
                              decoration: _inputDecoration("Contraseña Actual", Icons.lock_outline),
                              validator: (v) => v!.isEmpty ? "Requerido" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _newPassController,
                              obscureText: true,
                              decoration: _inputDecoration("Nueva Contraseña", Icons.lock_reset),
                              validator: _validateNewPassword, // Validar seguridad
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("ACTUALIZAR CONTRASEÑA", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // --- SECCIÓN 3: INFORMACIÓN LEGAL ---
                  _buildSectionTitle("Información Legal"),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Column(
                      children: [
                        _buildLegalTile(
                          "Términos y Condiciones", 
                          Icons.description_outlined, 
                          () => _showLegalInfo("Términos de Uso", "1. Aceptación: Al usar esta app aceptas las normas de la universidad.\n\n2. Uso Responsable: No compartir tu contraseña con terceros.\n\n3. Rutas: Los horarios están sujetos a tráfico y clima.")
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildLegalTile(
                          "Política de Privacidad", 
                          Icons.privacy_tip_outlined, 
                          () => _showLegalInfo("Privacidad", "Tus datos (correo y ubicación) se usan exclusivamente para la logística de transporte universitario. No compartimos información con terceros.")
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildLegalTile(
                          "Acerca de la App", 
                          Icons.info_outline, 
                          () => showAboutDialog(
                            context: context,
                            applicationName: "App Rutas Universitarias",
                            applicationVersion: "1.0.0",
                            applicationIcon: const Icon(Icons.directions_bus, size: 50, color: Colors.indigo),
                            children: [
                              const Text("Desarrollado para el mejoramiento del transporte estudiantil."),
                              const SizedBox(height: 10),
                              const Text("© 2025 Universidad de La Guajira"),
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Center(child: Text("Versión 1.0.0 (Build 2025)", style: TextStyle(color: Colors.grey[400], fontSize: 12))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildLegalTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.indigo, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 1.5)),
      errorMaxLines: 2,
    );
  }
}