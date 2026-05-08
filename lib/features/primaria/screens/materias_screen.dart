import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class MateriasScreen extends StatelessWidget {
  final Materia? materia;
  const MateriasScreen({super.key, this.materia});

  @override
  Widget build(BuildContext context) {
    final progreso = context.watch<ProgresoProvider>();
    final m = materia ?? progreso.materias.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, m),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: m.temas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final estado = m.estadoTema(i);
                  return _TemaCard(
                    tema: m.temas[i],
                    estado: estado,
                    index: i + 1,
                    color: m.color,
                    onTap: estado == EstadoTema.bloqueado
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completa el tema anterior primero'),
                                duration: Duration(seconds: 2),
                              ),
                            )
                        : estado == EstadoTema.completado
                            ? null
                            : () {
                                final ruta = m.temas[i].tipo == 'mate'
                                    ? AppRoutes.primariaActividadMate
                                    : AppRoutes.primariaActividadLectura;
                                context.push(ruta, extra: m.temas[i].id);
                              },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Materia m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(m.icon, color: m.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${(m.porcentaje * 100).toInt()}% completado',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemaCard extends StatelessWidget {
  final Tema tema;
  final EstadoTema estado;
  final int index;
  final Color color;
  final VoidCallback? onTap;

  const _TemaCard({
    required this.tema,
    required this.estado,
    required this.index,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked    = estado == EstadoTema.bloqueado;
    final done      = estado == EstadoTema.completado;
    final active    = estado == EstadoTema.activo;

    Color bgColor = AppColors.surfaceContainerLowest;
    Color borderColor = AppColors.surfaceVariant;
    if (active) {
      bgColor = color.withValues(alpha: 0.07);
      borderColor = color.withValues(alpha: 0.4);
    } else if (done) {
      bgColor = AppColors.primaryFixed.withValues(alpha: 0.3);
      borderColor = AppColors.primaryFixed;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Número / ícono de estado
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primary
                      : locked
                          ? AppColors.surfaceContainerHighest
                          : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 22)
                      : locked
                          ? const Icon(Icons.lock_rounded,
                              color: AppColors.outline, size: 20)
                          : Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tema.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: locked
                            ? AppColors.outline
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      done ? 'Completado' : active ? 'Toca para comenzar' : 'Bloqueado',
                      style: TextStyle(
                        fontSize: 12,
                        color: done
                            ? AppColors.primary
                            : locked
                                ? AppColors.outline
                                : color,
                      ),
                    ),
                  ],
                ),
              ),
              if (active)
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
              if (done)
                const Icon(Icons.star_rounded,
                    color: AppColors.secondaryContainer, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
