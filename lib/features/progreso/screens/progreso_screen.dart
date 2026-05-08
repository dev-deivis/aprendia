import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/progreso_provider.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRachaCard(progreso.rachaDias),
                    const SizedBox(height: 24),
                    _buildProgresoPorMateria(progreso),
                    const SizedBox(height: 24),
                    _buildLogros(progreso),
                    const SizedBox(height: 24),
                    _buildContinuarBtn(context),
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

  Widget _buildRachaCard(int dias) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryContainer,
            AppColors.secondaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryContainer.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dias días seguidos',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const Text(
                '¡Sigue así, vas muy bien!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoPorMateria(ProgresoProvider progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progreso por materia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        ...progreso.materias.map((m) {
          final pct = (m.porcentaje * 100).toInt();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(m.icon, color: m.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        m.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: m.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: m.porcentaje,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(m.color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLogros(ProgresoProvider progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mis logros',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: progreso.logros.map((l) {
            final activo = l['activo'] as bool;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: activo
                      ? AppColors.primaryFixed.withValues(alpha: 0.35)
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activo
                        ? AppColors.primaryFixed
                        : AppColors.surfaceContainerHighest,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      l['icon'] as IconData,
                      color: activo ? AppColors.primary : AppColors.outline,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l['titulo'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: activo ? AppColors.primary : AppColors.outline,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinuarBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.home),
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Seguir aprendiendo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 3,
        ),
      ),
    );
  }
}
