import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class MateriasSecundariaScreen extends StatelessWidget {
  const MateriasSecundariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progreso = context.watch<ProgresoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: progreso.secundariaMaterias.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final m = progreso.secundariaMaterias[i];
                  final locked = m.estado == EstadoMateria.bloqueado;
                  return _MateriaListCard(
                    materia: m,
                    onTap: locked
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completa las materias anteriores primero 💛'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            )
                        : () => context.push(AppRoutes.secundariaMateria, extra: m),
                  );
                },
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
          'Mis materias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MateriaListCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onTap;

  const _MateriaListCard({required this.materia, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = materia.estado == EstadoMateria.bloqueado;
    final pct = (materia.porcentaje * 100).toInt();
    final temasHechos = materia.temas.where((t) => t.completado).length;

    return Material(
      color: locked
          ? AppColors.surfaceContainer
          : materia.color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: locked
                  ? AppColors.surfaceContainerHighest
                  : materia.color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: locked
                      ? AppColors.surfaceContainerHighest
                      : materia.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  locked ? Icons.lock_rounded : materia.icon,
                  color: locked ? AppColors.outline : materia.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materia.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: locked ? AppColors.outline : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locked
                          ? 'Bloqueado'
                          : '$temasHechos de ${materia.temas.length} temas completados',
                      style: TextStyle(
                        fontSize: 12,
                        color: locked ? AppColors.outline : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: materia.porcentaje,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          locked ? AppColors.outline : materia.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: locked ? AppColors.outline : materia.color,
                    ),
                  ),
                  if (!locked)
                    Icon(Icons.chevron_right_rounded,
                        color: materia.color, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
