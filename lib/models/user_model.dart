import '../app_config.dart';

class UserModel {
  final String email;
  final String password;
  final UserRole role;

  UserModel({required this.email, required this.password, required this.role});

  // Convertir Objeto a Mapa (para guardar en JSON)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'role': role.name, // Guardamos el nombre del enum ('admin' o 'user')
    };
  }

  // Convertir Mapa a Objeto (al leer de JSON)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      password: map['password'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
    );
  }
}
