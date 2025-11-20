import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import '../models/user_storage.dart';


// --- MODELO DE RUTA (Sin cambios en la estructura de datos) ---
class RouteItem {
  String name;
  String status;

  RouteItem({required this.name, required this.status});

  Map<String, dynamic> toMap() => {'name': name, 'status': status};

  factory RouteItem.fromMap(Map<String, dynamic> map) {
    return RouteItem(name: map['name'], status: map['status']);
  }
}

class RouteStatusScreen extends StatefulWidget {
  const RouteStatusScreen({super.key});

  @override
  State<RouteStatusScreen> createState() => _RouteStatusScreenState();
}

class _RouteStatusScreenState extends State<RouteStatusScreen> {
  static const String _routesListKey = 'routes_list_data_v2';
  
  List<RouteItem> _routes = [];
  bool _isAdmin = false;
  bool _isLoading = true;

  // --- IMÁGENES DECORATIVAS (Se asignan automáticamente para que se vea Pro) ---
  final List<String> _busImages = [
    'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?q=80&w=500&auto=format&fit=crop', // Bus amarillo
    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=500&auto=format&fit=crop', // Bus moderno
    'https://images.unsplash.com/photo-1494515843206-f3117d3f51b7?q=80&w=500&auto=format&fit=crop', // Bus ciudad
    'https://images.unsplash.com/photo-1562620761-3283b9f87649?q=80&w=500&auto=format&fit=crop', // Parada
  ];

  // --- ESTADOS PREDEFINIDOS ---
  final List<Map<String, dynamic>> _statusOptions = [
    {'text': 'A Tiempo', 'color': Colors.green, 'icon': Icons.check_circle, 'bg': Colors.green.shade50},
    {'text': 'En Camino', 'color': Colors.blue, 'icon': Icons.directions_bus, 'bg': Colors.blue.shade50},
    {'text': 'Retrasado', 'color': Colors.orange, 'icon': Icons.access_time_filled, 'bg': Colors.orange.shade50},
    {'text': 'Lleno', 'color': Colors.redAccent, 'icon': Icons.group_off, 'bg': Colors.red.shade50},
    {'text': 'Fuera de Servicio', 'color': Colors.grey, 'icon': Icons.block, 'bg': Colors.grey.shade200},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routesJson = prefs.getString(_routesListKey);
    List<RouteItem> loadedRoutes = [];
    
    if (routesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(routesJson);
        loadedRoutes = decoded.map((item) => RouteItem.fromMap(item)).toList();
      } catch (e) {
        print("Error: $e");
      }
    }

    final session = await UserStorage.getActiveSession();
    final bool isAdminUser = (session != null && session.role == UserRole.admin);

    if (mounted) {
      setState(() {
        _routes = loadedRoutes;
        _isAdmin = isAdminUser;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_routes.map((r) => r.toMap()).toList());
    await prefs.setString(_routesListKey, encoded);
  }

  // --- LÓGICA VISUAL ---
  Map<String, dynamic> _getVisuals(String status) {
    return _statusOptions.firstWhere(
      (opt) => opt['text'] == status,
      orElse: () => {'color': Colors.indigo, 'icon': Icons.info, 'bg': Colors.indigo.shade50},
    );
  }

  // --- DIALOGO DE EDICIÓN ---
  void _showRouteDialog({RouteItem? route, int? index}) {
    final nameController = TextEditingController(text: route?.name ?? '');
    final ValueNotifier<String> statusNotifier = ValueNotifier<String>(route?.status ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route == null ? 'Nueva Ruta' : 'Administrar Ruta', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 20),
            
            // Nombre
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Ruta / Placa',
                prefixIcon: const Icon(Icons.directions_bus_filled),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100]
              ),
            ),
            const SizedBox(height: 20),
            
            // Chips de Estado
            const Text("Estado Actual:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _statusOptions.map((option) {
                return GestureDetector(
                  onTap: () => statusNotifier.value = option['text'],
                  child: ValueListenableBuilder<String>(
                    valueListenable: statusNotifier,
                    builder: (context, val, _) {
                      final isSelected = val == option['text'];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? option['color'] : Colors.white,
                          border: Border.all(color: isSelected ? option['color'] : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(option['icon'], size: 16, 
                                color: isSelected ? Colors.white : option['color']),
                            const SizedBox(width: 5),
                            Text(option['text'], 
                                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            
            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) return;
                  setState(() {
                    if (route == null) {
                      _routes.add(RouteItem(name: nameController.text, status: statusNotifier.value.isEmpty ? 'En Camino' : statusNotifier.value));
                    } else {
                      _routes[index!].name = nameController.text;
                      _routes[index].status = statusNotifier.value;
                    }
                  });
                  _saveRoutes();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _deleteRoute(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: const Text('Esta ruta desaparecerá del listado.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() => _routes.removeAt(index));
              _saveRoutes();
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Color de fondo muy suave
      appBar: AppBar(
        title: const Text('Estado de Rutas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: _isAdmin 
        ? FloatingActionButton.extended(
            onPressed: () => _showRouteDialog(),
            label: const Text('Nueva Ruta'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.deepOrange,
          )
        : null,
      
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _routes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('https://cdn-icons-png.flaticon.com/512/3063/3063822.png', width: 150, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("No hay rutas activas", style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                final visual = _getVisuals(route.status);
                // Seleccionamos una imagen basada en el índice para que varíe pero sea constante
                final imageUrl = _busImages[index % _busImages.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 110, // Altura fija para diseño profesional
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.indigo.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 1. IMAGEN DEL BUS (Lado Izquierdo)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(width: 100, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey)));
                          },
                          errorBuilder: (context, error, stackTrace) => Container(width: 100, color: Colors.grey[300], child: const Icon(Icons.directions_bus)),
                        ),
                      ),

                      // 2. INFORMACIÓN
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Nombre
                              Text(
                                route.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D3436)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              
                              // Estado con Diseño Visual
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: visual['bg'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(visual['icon'], size: 14, color: visual['color']),
                                    const SizedBox(width: 6),
                                    Text(
                                      route.status.toUpperCase(),
                                      style: TextStyle(
                                        color: visual['color'],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // 3. BOTONES ADMIN (Si aplica)
                      if (_isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                                onPressed: () => _showRouteDialog(route: route, index: index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
                                onPressed: () => _deleteRoute(index),
                              ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
                        )
                    ],
                  ),
                );
              },
            ),
    );
  }
}