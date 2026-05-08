import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class MateriaSecundariaScreen extends StatelessWidget {
  final Materia? materia;
  const MateriaSecundariaScreen({super.key, this.materia});

  @override
  Widget build(BuildContext context) {
    final progreso = context.watch<ProgresoProvider>();
    final m = materia ?? progreso.secundariaMateriaActiva;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, m),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: m.temas.length,
                itemBuilder: (context, i) {
                  final estado = m.estadoTema(i);
                  final isLast = i == m.temas.length - 1;
                  return _TemaRow(
                    tema: m.temas[i],
                    estado: estado,
                    index: i + 1,
                    color: m.color,
                    isLast: isLast,
                    onTap: switch (estado) {
                      EstadoTema.bloqueado => () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Completa el tema anterior primero'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          ),
                      EstadoTema.completado => () => _mostrarDialogoRepasar(
                            context, m.temas[i], m),
                      EstadoTema.activo => () => context.push(
                            AppRoutes.secundariaActividad,
                            extra: {
                              'temaId': m.temas[i].id,
                              'tipo': m.temas[i].tipo,
                              'temaNombre': m.temas[i].titulo,
                              'materiaNombre': m.nombre,
                              'materiaId': m.id,
                            },
                          ),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.secundariaChat, extra: {
          'materiaId': m.id,
          'materiaNombre': m.nombre,
        }),
        backgroundColor: AppColors.secondaryContainer,
        foregroundColor: AppColors.onSecondaryContainer,
        icon: const Icon(Icons.chat_bubble_rounded),
        label: const Text('Preguntar', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Materia m) {
    final temasHechos = m.temas.where((t) => t.completado).length;

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
            onTap: () => context.pop(),
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
                  '$temasHechos de ${m.temas.length} temas completados',
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

  Future<void> _mostrarDialogoRepasar(
      BuildContext context, Tema tema, Materia m) async {
    final repasar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tema completado ✅'),
        content: Text('Ya completaste "${tema.titulo}". ¿Quieres repasarlo?'),
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
            child: const Text('Repasar'),
          ),
        ],
      ),
    );
    if (repasar == true && context.mounted) {
      context.push(AppRoutes.secundariaActividad, extra: {
        'temaId': tema.id,
        'tipo': tema.tipo,
        'temaNombre': tema.titulo,
        'materiaNombre': m.nombre,
        'materiaId': m.id,
      });
    }
  }
}

class _TemaRow extends StatelessWidget {
  final Tema tema;
  final EstadoTema estado;
  final int index;
  final Color color;
  final bool isLast;
  final VoidCallback onTap;

  const _TemaRow({
    required this.tema,
    required this.estado,
    required this.index,
    required this.color,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done   = estado == EstadoTema.completado;
    final active = estado == EstadoTema.activo;
    final locked = estado == EstadoTema.bloqueado;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connector column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done
                        ? AppColors.primary
                        : active
                            ? color
                            : AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : locked
                            ? const Icon(Icons.lock_rounded,
                                color: AppColors.outline, size: 14)
                            : Text(
                                '$index',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: active ? Colors.white : AppColors.outline,
                                ),
                              ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done
                          ? AppColors.primaryFixed
                          : AppColors.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Material(
                color: done
                    ? AppColors.primaryFixed.withValues(alpha: 0.3)
                    : active
                        ? color.withValues(alpha: 0.08)
                        : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: done
                            ? AppColors.primaryFixed
                            : active
                                ? color.withValues(alpha: 0.4)
                                : AppColors.surfaceContainerHighest,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tema.titulo,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: locked
                                      ? AppColors.outline
                                      : AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    _tipoIcon(tema.tipo),
                                    size: 13,
                                    color: locked
                                        ? AppColors.outline
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    done
                                        ? 'Completado'
                                        : active
                                            ? 'Toca para comenzar'
                                            : 'Bloqueado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: done
                                          ? AppColors.primary
                                          : active
                                              ? color
                                              : AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (active)
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: color, size: 16),
                        if (done)
                          const Icon(Icons.star_rounded,
                              color: AppColors.secondaryContainer, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _tipoIcon(String tipo) {
    return switch (tipo) {
      'escritura' => Icons.edit_rounded,
      'opcion'    => Icons.quiz_rounded,
      _           => Icons.menu_book_rounded,
    };
  }
}
