import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/usuario_provider.dart';
import '../../../providers/progreso_provider.dart';
import '../../../providers/config_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>();
    final progreso = context.watch<ProgresoProvider>();
    final config = context.watch<ConfigProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarCard(usuario, progreso),
                    const SizedBox(height: 24),
                    _buildEstadisticasCard(usuario, progreso),
                    const SizedBox(height: 24),
                    _buildAjustes(context, config),
                    const SizedBox(height: 24),
                    _buildAcciones(context, usuario),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      color: AppColors.surface,
      child: const Center(
        child: Text(
          'Mi perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(UsuarioProvider usuario, ProgresoProvider progreso) {
    final nivelLabel = switch (usuario.nivel) {
      'primaria'     => 'Primaria',
      'secundaria'   => 'Secundaria',
      'alfabetizacion' => 'Alfabetización',
      _              => 'Sin nivel',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    nivelLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(progreso.progresoGeneral * 100).toInt()}% completado',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasCard(UsuarioProvider usuario, ProgresoProvider progreso) {
    final temasCompletados = progreso.materias
        .fold<int>(0, (s, m) => s + m.temas.where((t) => t.completado).length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis estadísticas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.secondaryContainer,
                value: '${progreso.rachaDias}',
                label: 'días racha',
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.star_rounded,
                color: AppColors.tertiary,
                value: '$temasCompletados',
                label: 'temas hechos',
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
                value: '${usuario.diasActivo}',
                label: 'días activo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAjustes(BuildContext context, ConfigProvider config) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajustes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Velocidad de voz
          Row(
            children: [
              const Icon(Icons.record_voice_over_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Velocidad de voz',
                  style: TextStyle(fontSize: 15, color: AppColors.onSurface),
                ),
              ),
              Text(
                '${config.velocidadVoz.toStringAsFixed(1)}×',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: config.velocidadVoz,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            activeColor: AppColors.primary,
            onChanged: (v) => context.read<ConfigProvider>().setVelocidadVoz(v),
          ),
          const Divider(height: 24),
          // Modo noche
          Row(
            children: [
              const Icon(Icons.dark_mode_rounded,
                  color: AppColors.onSurfaceVariant, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Modo noche',
                  style: TextStyle(fontSize: 15, color: AppColors.onSurface),
                ),
              ),
              Switch(
                value: config.modoNoche,
                activeColor: AppColors.primary,
                onChanged: (_) => context.read<ConfigProvider>().toggleModoNoche(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Modo offline
          Row(
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: AppColors.onSurfaceVariant, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Modo sin conexión',
                  style: TextStyle(fontSize: 15, color: AppColors.onSurface),
                ),
              ),
              Switch(
                value: config.modoOffline,
                activeColor: AppColors.primary,
                onChanged: (_) => context.read<ConfigProvider>().toggleModoOffline(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcciones(BuildContext context, UsuarioProvider usuario) {
    return Column(
      children: [
        // Contactar a mi asesor
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.tutor),
            icon: const Icon(Icons.smart_toy_rounded),
            label: const Text('Contactar a mi tutora AprendIA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cambiar nivel
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () => _confirmarCambioNivel(context, usuario),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Cambiar nivel educativo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarCambioNivel(
      BuildContext context, UsuarioProvider usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cambiar nivel?'),
        content: const Text(
          'Si cambias de nivel, tu progreso actual se mantendrá guardado. '
          'Podrás seleccionar un nuevo nivel educativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await usuario.limpiarNivel();
      if (context.mounted) context.go(AppRoutes.onboarding);
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
