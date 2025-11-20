import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class UserStorage {
  static const String _usersKey =
      'list_users_data'; // Clave para la lista de todos los usuarios
  static const String _sessionKey =
      'active_session'; // Clave para saber si hay alguien logueado

  // --- OBTENER TODOS LOS USUARIOS (Público) ---
  static Future<List<UserModel>> getAllUsersPublic() async {
    final prefs = await SharedPreferences.getInstance();
    return _getAllUsers(prefs);
  }

  // --- ELIMINAR USUARIO ---
  static Future<void> deleteUser(String emailToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    List<UserModel> users = await _getAllUsers(prefs);

    // Filtramos la lista quitando el que tenga ese email
    users.removeWhere((u) => u.email == emailToDelete);

    // Guardamos la lista actualizada
    List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  // --- NUEVO: EDITAR USUARIO (ESTA ES LA FUNCIÓN QUE FALTABA) ---
  static Future<void> editUser(
    String originalEmail,
    UserModel updatedUser,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<UserModel> users = await _getAllUsers(prefs);

    // 1. Buscamos el índice del usuario usando su email original
    final index = users.indexWhere((u) => u.email == originalEmail);

    if (index != -1) {
      // 2. Reemplazamos el usuario viejo con el nuevo (con contraseña/rol editado)
      users[index] = updatedUser;

      // 3. Guardamos la lista actualizada en el teléfono
      List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
      await prefs.setStringList(_usersKey, usersJson);
    }
  }

  // --- REGISTRO ---
  static Future<bool> registerUser(UserModel newUser) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Obtener lista actual
    List<UserModel> users = await _getAllUsers(prefs);

    // 2. Validar si el correo ya existe
    if (users.any((u) => u.email == newUser.email)) {
      return false; // El usuario ya existe
    }

    // 3. Agregar nuevo usuario y guardar
    users.add(newUser);

    // Convertimos la lista de objetos a una lista de JSON Strings
    List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
    await prefs.setStringList(_usersKey, usersJson);

    return true;
  }

  // --- LOGIN ---
  static Future<UserModel?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    List<UserModel> users = await _getAllUsers(prefs);

    try {
      // Buscamos un usuario que coincida en email y contraseña
      final user = users.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      // Si lo encontramos, guardamos la sesión activa
      await _saveSession(user);
      return user;
    } catch (e) {
      return null; // No se encontró usuario
    }
  }

  // --- PERSISTENCIA DE SESIÓN ---
  static Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // Guardamos los datos del usuario logueado actualmente
    await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
  }

  static Future<UserModel?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_sessionKey);

    if (userJson == null) return null;

    return UserModel.fromMap(jsonDecode(userJson));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // --- UTILIDAD PRIVADA ---
  static Future<List<UserModel>> _getAllUsers(SharedPreferences prefs) async {
    final List<String>? usersJson = prefs.getStringList(_usersKey);
    if (usersJson == null) return [];

    return usersJson.map((str) => UserModel.fromMap(jsonDecode(str))).toList();
  }
}
