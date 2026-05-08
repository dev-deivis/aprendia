import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'alfa_home_tab.dart';
import 'alfa_progreso_tab.dart';
import 'alfa_perfil_tab.dart';

class AlfaShell extends StatefulWidget {
  final int initialTab;
  const AlfaShell({super.key, this.initialTab = 0});

  @override
  State<AlfaShell> createState() => _AlfaShellState();
}

class _AlfaShellState extends State<AlfaShell> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _goTo(int tab) {
    if (tab != _currentTab) setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: IndexedStack(
        index: _currentTab,
        children: [
          AlfaHomeTab(onNavigate: _goTo),
          AlfaProgresoTab(onNavigate: _goTo),
          AlfaPerfilTab(onNavigate: _goTo),
        ],
      ),
      bottomNavigationBar: _AlfaBottomNav(
        currentIndex: _currentTab,
        onTap: _goTo,
      ),
    );
  }
}

class _AlfaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _AlfaBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.trending_up_rounded,
                label: 'Progreso',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
