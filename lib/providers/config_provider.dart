import 'package:flutter/foundation.dart';

class ConfigProvider extends ChangeNotifier {
  double velocidadVoz = 1.0;
  bool modoNoche   = false;
  bool modoOffline = false;

  void setVelocidadVoz(double v) {
    velocidadVoz = v;
    notifyListeners();
  }

  void toggleModoNoche() {
    modoNoche = !modoNoche;
    notifyListeners();
  }

  void toggleModoOffline() {
    modoOffline = !modoOffline;
    notifyListeners();
  }
}
