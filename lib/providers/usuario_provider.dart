import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider extends ChangeNotifier {
  String nombre = 'Estudiante';
  String nivel  = '';   // '' | 'alfabetizacion' | 'primaria' | 'secundaria'
  DateTime? fechaInicio;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    nombre = prefs.getString('nombre') ?? 'Estudiante';
    nivel  = prefs.getString('nivel')  ?? '';
    final ms = prefs.getInt('fechaInicio');
    if (ms != null) fechaInicio = DateTime.fromMillisecondsSinceEpoch(ms);
    notifyListeners();
  }

  Future<void> guardarNivel(String nuevoNivel) async {
    nivel = nuevoNivel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nivel', nivel);
    if (fechaInicio == null) {
      fechaInicio = DateTime.now();
      await prefs.setInt('fechaInicio', fechaInicio!.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  Future<void> limpiarNivel() async {
    nivel = '';
    fechaInicio = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nivel');
    await prefs.remove('fechaInicio');
    notifyListeners();
  }

  int get diasActivo {
    if (fechaInicio == null) return 1;
    return DateTime.now().difference(fechaInicio!).inDays + 1;
  }
}
