import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/usuario_provider.dart';
import '../../../providers/progreso_provider.dart';

class HomeSecundariaScreen extends StatelessWidget {
  const HomeSecundariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario  = context.watch<UsuarioProvider>();
    final progreso = context.watch<ProgresoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(usuario, progreso),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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

  Widget _buildHeader(UsuarioProvider usuario, ProgresoProvider progreso) {
    final pct = (progreso.progresoSecundaria * 100).toInt();

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
          // Circular progress
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progreso.progresoSecundaria,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Center(
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
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
                  'Secundaria · ${usuario.diasActivo} días activo',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Racha badge
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

  Widget _buildMateriasGrid(BuildContext context, ProgresoProvider progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 14),
          child: Text(
            'Tus materias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: progreso.secundariaMaterias.map((m) {
            final locked = m.estado == EstadoMateria.bloqueado;
            return _MateriaCard(
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
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinuarBtn(BuildContext context, ProgresoProvider progreso) {
    final materia = progreso.secundariaMateriaActiva;
    final tema = materia.temaActivo;
    final label = tema?.titulo ?? 'Repasa lo aprendido';

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          if (tema != null) {
            context.push(AppRoutes.secundariaActividad, extra: {
              'temaId': tema.id,
              'tipo': tema.tipo,
              'temaNombre': tema.titulo,
              'materiaNombre': materia.nombre,
              'materiaId': materia.id,
            });
          }
        },
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

class _MateriaCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onTap;

  const _MateriaCard({required this.materia, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = materia.estado == EstadoMateria.bloqueado;
    final pct = (materia.porcentaje * 100).toInt();

    final bgColor = locked
        ? AppColors.surfaceContainer
        : materia.color.withValues(alpha: 0.1);
    final borderColor = locked
        ? AppColors.surfaceContainerHighest
        : materia.color.withValues(alpha: 0.4);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: locked
                          ? AppColors.surfaceContainerHighest
                          : materia.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      locked ? Icons.lock_rounded : materia.icon,
                      color: locked ? AppColors.outline : materia.color,
                      size: 20,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 12,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: locked ? AppColors.outline : AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: materia.porcentaje,
                  minHeight: 5,
                  backgroundColor: locked
                      ? AppColors.surfaceContainerHighest
                      : materia.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    locked ? AppColors.outline : materia.color,
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
