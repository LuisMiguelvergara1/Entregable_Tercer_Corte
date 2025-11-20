import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import '../models/user_model.dart';
import '../models/user_storage.dart';
import '../app_config.dart'; // Para acceder al Enum UserRole

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  // Controla qué contraseñas son visibles (por seguridad visual)
  final Map<String, bool> _visiblePasswords = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await UserStorage.getAllUsersPublic();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  // --- ELIMINAR ---
  Future<void> _deleteUser(String email) async {
    await UserStorage.deleteUser(email);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario eliminado"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- EDITAR (NUEVO) ---
  void _showEditDialog(UserModel user) {
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController(text: user.password);
    UserRole selectedRole = user.role; // Rol actual

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editar Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  icon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 15),
              // Editar Password
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  icon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 15),
              // Editar Rol
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol asignado',
                  icon: Icon(Icons.security),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => selectedRole = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Crear objeto actualizado
              final updatedUser = UserModel(
                email: emailController.text.trim(),
                password: passwordController.text,
                role: selectedRole,
              );

              // Guardar cambios usando el email original como referencia
              await UserStorage.editUser(user.email, updatedUser);

              if (mounted) {
                Navigator.pop(ctx);
                _loadUsers(); // Recargar lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Datos actualizados"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gestión Total de Usuarios'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text("No hay usuarios registrados"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _users.length,
              itemBuilder: (ctx, i) {
                final user = _users[i];
                final isPasswordVisible =
                    _visiblePasswords[user.email] ?? false;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    child: ListTile(
                      // 1. ICONO DEL ROL
                      leading: CircleAvatar(
                        backgroundColor: user.role == UserRole.admin
                            ? Colors.deepOrange
                            : Colors.indigo,
                        child: Icon(
                          user.role == UserRole.admin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: Colors.white,
                        ),
                      ),

                      // 2. DATOS DEL USUARIO
                      title: Text(
                        user.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          // Badge de Rol
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: user.role == UserRole.admin
                                  ? Colors.orange[50]
                                  : Colors.indigo[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: user.role == UserRole.admin
                                    ? Colors.orange
                                    : Colors.indigo,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              user.role.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user.role == UserRole.admin
                                    ? Colors.deepOrange
                                    : Colors.indigo,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // --- MOSTRAR CONTRASEÑA ---
                          Row(
                            children: [
                              Icon(
                                isPasswordVisible
                                    ? Icons.lock_open
                                    : Icons.lock,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isPasswordVisible ? user.password : "••••••••",
                                style: TextStyle(
                                  color: isPasswordVisible
                                      ? Colors.black87
                                      : Colors.grey,
                                  fontFamily: 'Monospace',
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Botón ojito pequeño
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // Alternar visibilidad solo para este usuario
                                    _visiblePasswords[user.email] =
                                        !isPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // 3. BOTONES DE ACCIÓN (EDITAR / ELIMINAR)
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Editar
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(user),
                            tooltip: 'Modificar',
                          ),
                          // Eliminar
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(user.email),
                            tooltip: 'Borrar usuario',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('Se borrará permanentemente a: $email'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteUser(email);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
