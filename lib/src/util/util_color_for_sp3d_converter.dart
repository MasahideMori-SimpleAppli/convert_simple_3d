import 'dart:ui';

/// (en) The color utility.
///
/// (ja)カラー周りのユーティリティです。
class UtilColorForSp3dConverter {
  /// (en) Converts a double value specified between 0 and 1 to RGBA.
  ///
  /// (ja) 0～1で指定したdouble値をRGBAに変換します。
  ///
  /// [r] : red.
  /// [g] : green.
  /// [b] : blue.
  /// [o] : opacity.
  /// Returns Color obj.
  static Color toRGBAd(double r, double g, double b, {double o = 1}) {
    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), o);
  }
}
