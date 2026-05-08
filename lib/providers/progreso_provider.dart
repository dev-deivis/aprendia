import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum EstadoMateria { enCurso, siguiente, bloqueado }
enum EstadoTema    { completado, activo, bloqueado }

class Tema {
  final String id;
  final String titulo;
  final String tipo; // 'lectura' | 'mate'
  bool completado;

  Tema(this.id, this.titulo, this.tipo, {this.completado = false});
}

class Materia {
  final String   id;
  final String   nombre;
  final IconData icon;
  final Color    color;
  final List<Tema> temas;

  Materia({
    required this.id,
    required this.nombre,
    required this.icon,
    required this.color,
    required this.temas,
  });

  double get porcentaje => temas.isEmpty
      ? 0
      : temas.where((t) => t.completado).length / temas.length;

  EstadoMateria get estado {
    if (porcentaje == 0) return EstadoMateria.bloqueado;
    if (porcentaje == 1.0) return EstadoMateria.siguiente;
    return EstadoMateria.enCurso;
  }

  EstadoTema estadoTema(int index) {
    if (temas[index].completado) return EstadoTema.completado;
    // Activo si todos los anteriores están completados
    final prevDone = index == 0 || temas[index - 1].completado;
    return prevDone ? EstadoTema.activo : EstadoTema.bloqueado;
  }

  Tema? get temaActivo {
    for (int i = 0; i < temas.length; i++) {
      if (estadoTema(i) == EstadoTema.activo) return temas[i];
    }
    return null;
  }
}

class ProgresoProvider extends ChangeNotifier {
  int rachaDias = 5;

  // ── Materias Secundaria ────────────────────────────────────────
  final List<Materia> secundariaMaterias = [
    Materia(
      id: 'sec_esp',
      nombre: 'Español',
      icon: Icons.menu_book_rounded,
      color: AppColors.primary,
      temas: [
        Tema('se1', 'Lectura y comprensión', 'lectura', completado: true),
        Tema('se2', 'Escritura de párrafos', 'escritura'),
        Tema('se3', 'Gramática básica', 'opcion'),
        Tema('se4', 'Ortografía', 'lectura'),
        Tema('se5', 'Redacción libre', 'escritura'),
      ],
    ),
    Materia(
      id: 'sec_mat',
      nombre: 'Matemáticas',
      icon: Icons.calculate_rounded,
      color: AppColors.secondary,
      temas: [
        Tema('sm1', 'Álgebra básica', 'opcion', completado: true),
        Tema('sm2', 'Ecuaciones', 'opcion', completado: true),
        Tema('sm3', 'Geometría', 'opcion'),
        Tema('sm4', 'Estadística', 'opcion'),
        Tema('sm5', 'Proporciones', 'opcion'),
      ],
    ),
    Materia(
      id: 'sec_cn',
      nombre: 'Ciencias',
      icon: Icons.science_rounded,
      color: AppColors.tertiary,
      temas: [
        Tema('scn1', 'El cuerpo humano', 'lectura'),
        Tema('scn2', 'Ecosistemas', 'lectura'),
        Tema('scn3', 'Química básica', 'opcion'),
        Tema('scn4', 'Física elemental', 'opcion'),
        Tema('scn5', 'Salud y nutrición', 'lectura'),
      ],
    ),
    Materia(
      id: 'sec_his',
      nombre: 'Historia',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF795548),
      temas: [
        Tema('sh1', 'Prehispánico', 'lectura'),
        Tema('sh2', 'La Colonia', 'lectura'),
        Tema('sh3', 'Independencia', 'lectura'),
        Tema('sh4', 'Revolución', 'lectura'),
        Tema('sh5', 'México contemporáneo', 'lectura'),
      ],
    ),
    Materia(
      id: 'sec_geo',
      nombre: 'Geografía',
      icon: Icons.public_rounded,
      color: const Color(0xFF00897B),
      temas: [
        Tema('sg1', 'México y sus regiones', 'opcion'),
        Tema('sg2', 'Climas de México', 'opcion'),
        Tema('sg3', 'Recursos naturales', 'lectura'),
        Tema('sg4', 'América Latina', 'opcion'),
        Tema('sg5', 'El mundo', 'opcion'),
      ],
    ),
    Materia(
      id: 'sec_fc',
      nombre: 'Form. Cívica',
      icon: Icons.groups_rounded,
      color: const Color(0xFF3949AB),
      temas: [
        Tema('sfc1', 'Derechos humanos', 'lectura'),
        Tema('sfc2', 'Democracia', 'opcion'),
        Tema('sfc3', 'Cultura de paz', 'lectura'),
        Tema('sfc4', 'Leyes básicas', 'opcion'),
        Tema('sfc5', 'Ciudadanía activa', 'escritura'),
      ],
    ),
  ];

  final List<Materia> materias = [
    Materia(
      id: 'lengua',
      nombre: 'Lengua',
      icon: Icons.menu_book_rounded,
      color: AppColors.primary,
      temas: [
        Tema('l1', 'Lectura comprensiva', 'lectura', completado: true),
        Tema('l2', 'Escritura básica',    'lectura', completado: true),
        Tema('l3', 'El agua y la vida',   'lectura', completado: true),
        Tema('l4', 'Gramática sencilla',  'lectura'),
        Tema('l5', 'Redacción simple',    'lectura'),
      ],
    ),
    Materia(
      id: 'matematicas',
      nombre: 'Matemáticas',
      icon: Icons.calculate_rounded,
      color: AppColors.secondary,
      temas: [
        Tema('m1', 'Suma y resta',      'mate', completado: true),
        Tema('m2', 'Multiplicación',    'mate', completado: true),
        Tema('m3', 'División básica',   'mate'),
        Tema('m4', 'Fracciones',        'mate'),
        Tema('m5', 'Problemas mixtos',  'mate'),
      ],
    ),
    Materia(
      id: 'ciencias',
      nombre: 'Ciencias',
      icon: Icons.science_rounded,
      color: AppColors.tertiary,
      temas: [
        Tema('c1', 'El cuerpo humano',   'lectura', completado: true),
        Tema('c2', 'Plantas y animales', 'lectura'),
        Tema('c3', 'El agua',            'lectura'),
        Tema('c4', 'El universo',        'lectura'),
        Tema('c5', 'Medio ambiente',     'lectura'),
      ],
    ),
    Materia(
      id: 'historia',
      nombre: 'Historia',
      icon: Icons.account_balance_rounded,
      color: AppColors.onSurfaceVariant,
      temas: [
        Tema('h1', 'México antiguo',     'lectura'),
        Tema('h2', 'La colonia',         'lectura'),
        Tema('h3', 'Independencia',      'lectura'),
        Tema('h4', 'Revolución',         'lectura'),
        Tema('h5', 'México moderno',     'lectura'),
      ],
    ),
  ];

  final List<Map<String, dynamic>> logros = [
    {'titulo': '5 días seguidos',  'icon': Icons.local_fire_department_rounded, 'activo': true},
    {'titulo': 'Primera lección',  'icon': Icons.star_rounded,                  'activo': true},
    {'titulo': 'Racha perfecta',   'icon': Icons.emoji_events_rounded,          'activo': false},
  ];

  Materia get materiaActiva =>
      materias.firstWhere((m) => m.estado == EstadoMateria.enCurso,
          orElse: () => materias.first);

  Materia get secundariaMateriaActiva =>
      secundariaMaterias.firstWhere((m) => m.estado == EstadoMateria.enCurso,
          orElse: () => secundariaMaterias.first);

  double get progresoGeneral {
    final total = materias.fold<int>(0, (s, m) => s + m.temas.length);
    final done  = materias.fold<int>(0, (s, m) => s + m.temas.where((t) => t.completado).length);
    return total == 0 ? 0 : done / total;
  }

  double get progresoSecundaria {
    final all = secundariaMaterias;
    final total = all.fold<int>(0, (s, m) => s + m.temas.length);
    final done  = all.fold<int>(0, (s, m) => s + m.temas.where((t) => t.completado).length);
    return total == 0 ? 0 : done / total;
  }

  void completarTema(String id) {
    for (final lista in [materias, secundariaMaterias]) {
      for (final m in lista) {
        for (final t in m.temas) {
          if (t.id == id && !t.completado) {
            t.completado = true;
            notifyListeners();
            return;
          }
        }
      }
    }
  }
}
