import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_storage.dart';
import '../app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clave de administrador
  static const String _adminSecretCode = "RUTAS2025";

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController();

  bool _wantsToBeAdmin = false;
  bool _isLoading = false;
  String? _errorMessage;

  // --- VALIDACIONES PERSONALIZADAS ---

  // 1. Validar solo Gmail
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    // Verificamos si termina en @gmail.com (ignorando espacios)
    if (!value.trim().toLowerCase().endsWith('@gmail.com')) {
      return 'Solo se permiten correos @gmail.com';
    }
    return null;
  }

  // 2. Validar Contraseña Fuerte
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[0-9]')))
      return 'Debe contener al menos un número';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener una mayúscula';
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden.';
        _isLoading = false;
      });
      return;
    }

    // Lógica de Admin
    UserRole finalRole = UserRole.user;
    if (_wantsToBeAdmin) {
      if (_adminCodeController.text.trim() != _adminSecretCode) {
        setState(() {
          _errorMessage = 'Código de administrador incorrecto.';
          _isLoading = false;
        });
        return;
      }
      finalRole = UserRole.admin;
    }

    final newUser = UserModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: finalRole,
    );

    final success = await UserStorage.registerUser(newUser);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Este correo ya está registrado.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/university_background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.indigo),
            ),
          ),
          // Filtro oscuro
          Positioned.fill(
            child: Container(color: const Color(0xFF0A1E3C).withOpacity(0.9)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/university_logo.png',
                    height: 90,
                    color: Colors.white,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Email con validación Gmail
                          _buildTextField(
                            _emailController,
                            'Correo (@gmail.com)',
                            Icons.email,
                            false,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 15),

                          // Campo Password con validación fuerte
                          _buildTextField(
                            _passwordController,
                            'Contraseña',
                            Icons.lock,
                            true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 15),

                          // Confirmar Password
                          _buildTextField(
                            _confirmPasswordController,
                            'Confirmar',
                            Icons.lock_outline,
                            true,
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Requerido';
                              if (val != _passwordController.text)
                                return 'No coinciden';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          SwitchListTile(
                            title: const Text(
                              "Soy Administrativo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: _wantsToBeAdmin,
                            activeColor: Colors.deepOrange,
                            onChanged: (val) =>
                                setState(() => _wantsToBeAdmin = val),
                          ),
                          if (_wantsToBeAdmin)
                            _buildTextField(
                              _adminCodeController,
                              'Código Secreto',
                              Icons.vpn_key,
                              true,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Requerido para admin'
                                  : null,
                            ),

                          const SizedBox(height: 20),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'REGISTRARSE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Volver al Login",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
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

  // Helper modificado para aceptar validadores personalizados
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorMaxLines: 2, // Permite que el error ocupe 2 líneas si es largo
      ),
      // Si pasamos un validador específico lo usa, si no, usa uno por defecto
      validator:
          validator ??
          (val) => (val == null || val.isEmpty) ? 'Requerido' : null,
    );
  }
}
