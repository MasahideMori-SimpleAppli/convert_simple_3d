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

  /// (en) Returns the color converted to a hexadecimal #AARRGGBB string.
  ///
  /// (ja) Colorを16進数の#AARRGGBB形式のテキストに変換して返します。
  ///
  /// * [color] : The color you want to convert.
  static String colorToHexString(Color color) {
    return '#${(color.a * 255).round().toRadixString(16).padLeft(2, '0')}' // Alpha
            '${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}' // Red
            '${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}' // Green
            '${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}'
        .toUpperCase(); // Blue
  }
}
