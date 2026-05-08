import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/usuario_provider.dart';
import '../../../providers/progreso_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario  = context.watch<UsuarioProvider>();
    final progreso = context.watch<ProgresoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, usuario, progreso)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildModuloCard(progreso),
                  const SizedBox(height: 24),
                  _buildMateriasGrid(context, progreso),
                  const SizedBox(height: 24),
                  _buildContinuarBtn(context, progreso),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UsuarioProvider usuario, ProgresoProvider progreso) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar tutora
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryFixed, width: 2),
            ),
            child: ClipOval(
              child: Image.asset('assets/images/ProfeFeliz.jpeg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${usuario.nombre}! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Nivel Primaria · ${usuario.diasActivo} días activo',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Racha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.onSecondaryContainer, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${progreso.rachaDias}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Módulo actual ─────────────────────────────────────────────
  Widget _buildModuloCard(ProgresoProvider progreso) {
    final pct = (progreso.progresoGeneral * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006056), Color(0xFF1A7A6E)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Módulo 2 de 6',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Comunicación y Lenguaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso.progresoGeneral,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid de materias ──────────────────────────────────────────
  Widget _buildMateriasGrid(BuildContext context, ProgresoProvider progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus materias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: progreso.materias.map((m) {
            return _MateriaCard(
              materia: m,
              onTap: m.estado == EstadoMateria.bloqueado
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa la materia anterior primero'),
                          duration: Duration(seconds: 2),
                        ),
                      )
                  : () => context.push(AppRoutes.primariaMaterias, extra: m),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Botón continuar ───────────────────────────────────────────
  Widget _buildContinuarBtn(BuildContext context, ProgresoProvider progreso) {
    final materia = progreso.materiaActiva;
    final tema = materia.temaActivo;
    final label = tema != null ? tema.titulo : 'Repasa lo aprendido';
    final ruta = tema?.tipo == 'mate'
        ? AppRoutes.primariaActividadMate
        : AppRoutes.primariaActividadLectura;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => context.push(ruta),
        icon: const Icon(Icons.play_circle_rounded, size: 28),
        label: Text('Continuar: $label', overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 4,
        ),
      ),
    );
  }
}

// ── Tarjeta de materia ────────────────────────────────────────────
class _MateriaCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onTap;

  const _MateriaCard({required this.materia, required this.onTap});

  Color get _bgColor {
    switch (materia.estado) {
      case EstadoMateria.enCurso:   return materia.color.withValues(alpha: 0.1);
      case EstadoMateria.siguiente: return AppColors.secondaryFixed.withValues(alpha: 0.3);
      case EstadoMateria.bloqueado: return AppColors.surfaceContainer;
    }
  }

  Color get _borderColor {
    switch (materia.estado) {
      case EstadoMateria.enCurso:   return materia.color.withValues(alpha: 0.4);
      case EstadoMateria.siguiente: return AppColors.secondaryFixed;
      case EstadoMateria.bloqueado: return AppColors.surfaceContainerHighest;
    }
  }

  String get _etiqueta {
    switch (materia.estado) {
      case EstadoMateria.enCurso:   return 'En curso';
      case EstadoMateria.siguiente: return 'Siguiente';
      case EstadoMateria.bloqueado: return 'Bloqueado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = materia.estado == EstadoMateria.bloqueado;
    return Material(
      color: _bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: locked
                          ? AppColors.surfaceContainerHighest
                          : materia.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      locked ? Icons.lock_rounded : materia.icon,
                      color: locked ? AppColors.outline : materia.color,
                      size: 22,
                    ),
                  ),
                  Text(
                    '${(materia.porcentaje * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: locked ? AppColors.outline : materia.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                materia.nombre,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: locked ? AppColors.outline : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.surfaceContainerHighest
                      : materia.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _etiqueta,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: locked ? AppColors.outline : materia.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
