import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/progreso_provider.dart';

class ProgresoSecundariaScreen extends StatelessWidget {
  const ProgresoSecundariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progreso = context.watch<ProgresoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildRachaCard(progreso),
                  const SizedBox(height: 20),
                  _buildMaterias(progreso),
                  const SizedBox(height: 20),
                  _buildCertificadoCard(progreso),
                  const SizedBox(height: 20),
                  _buildLogros(progreso),
                ]),
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
          'Mi progreso',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildRachaCard(ProgresoProvider progreso) {
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
            color: const Color(0xFF006056).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Color(0xFFFEAE2C), size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progreso.rachaDias} días de racha',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¡Sigue así! La constancia es la clave.',
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

  Widget _buildMaterias(ProgresoProvider progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avance por materia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...progreso.secundariaMaterias.map((m) {
          final pct = m.porcentaje;
          final done = m.temas.where((t) => t.completado).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.surfaceContainerHighest, width: 1.2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: m.estado == EstadoMateria.bloqueado
                              ? AppColors.surfaceContainerHighest
                              : m.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          m.estado == EstadoMateria.bloqueado
                              ? Icons.lock_rounded
                              : m.icon,
                          color: m.estado == EstadoMateria.bloqueado
                              ? AppColors.outline
                              : m.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.nombre,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: m.estado == EstadoMateria.bloqueado
                                ? AppColors.outline
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '$done/${m.temas.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: m.estado == EstadoMateria.bloqueado
                              ? AppColors.outline
                              : m.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        m.estado == EstadoMateria.bloqueado
                            ? AppColors.outline
                            : m.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCertificadoCard(ProgresoProvider progreso) {
    final totalTemas = progreso.secundariaMaterias
        .fold<int>(0, (sum, m) => sum + m.temas.length);
    final temasHechos = progreso.secundariaMaterias
        .fold<int>(0, (sum, m) => sum + m.temas.where((t) => t.completado).length);
    final faltan = totalTemas - temasHechos;
    final pct = totalTemas > 0 ? temasHechos / totalTemas : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.tertiaryFixed, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: AppColors.tertiary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certificado INEA',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  faltan > 0
                      ? 'Te faltan $faltan temas para completar secundaria'
                      : '¡Completaste la secundaria! 🎉',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.tertiaryFixed,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.tertiary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogros(ProgresoProvider progreso) {
    final temasHechos = progreso.secundariaMaterias
        .fold<int>(0, (sum, m) => sum + m.temas.where((t) => t.completado).length);

    final logros = [
      _Logro(
        icon: Icons.star_rounded,
        color: AppColors.secondaryContainer,
        titulo: 'Primer tema',
        desc: 'Completaste tu primer tema',
        desbloqueado: temasHechos >= 1,
      ),
      _Logro(
        icon: Icons.local_fire_department_rounded,
        color: Colors.orange,
        titulo: 'Racha de 3 días',
        desc: '3 días de estudio seguidos',
        desbloqueado: progreso.rachaDias >= 3,
      ),
      _Logro(
        icon: Icons.bolt_rounded,
        color: Colors.amber,
        titulo: '5 temas completos',
        desc: 'Completaste 5 temas',
        desbloqueado: temasHechos >= 5,
      ),
      _Logro(
        icon: Icons.menu_book_rounded,
        color: AppColors.primary,
        titulo: 'Primera materia',
        desc: 'Terminaste una materia completa',
        desbloqueado: progreso.secundariaMaterias
            .any((m) => m.porcentaje >= 1.0),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: logros.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _LogroCard(logro: logros[i]),
          ),
        ),
      ],
    );
  }
}

class _Logro {
  final IconData icon;
  final Color color;
  final String titulo;
  final String desc;
  final bool desbloqueado;

  const _Logro({
    required this.icon,
    required this.color,
    required this.titulo,
    required this.desc,
    required this.desbloqueado,
  });
}

class _LogroCard extends StatelessWidget {
  final _Logro logro;
  const _LogroCard({required this.logro});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: logro.desbloqueado
            ? logro.color.withValues(alpha: 0.12)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: logro.desbloqueado
              ? logro.color.withValues(alpha: 0.4)
              : AppColors.surfaceContainerHighest,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            logro.desbloqueado ? logro.icon : Icons.lock_rounded,
            color: logro.desbloqueado ? logro.color : AppColors.outline,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            logro.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: logro.desbloqueado
                  ? AppColors.onSurface
                  : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
