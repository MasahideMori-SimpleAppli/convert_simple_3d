import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';

import '../../convert_simple_3d.dart';

///
/// (en) This is a class for handling mtl files (material files).
///
/// (ja) mtlファイル（マテリアルファイル）を扱うためのクラスです。
///
class WFMaterial {
  // マテリアル名。
  String name;

  // アンビエント色。環境光の色。
  Color? ka;

  // ディフューズ色。所謂色はこれ。
  Color? kd;

  // スペキュラ色。鏡面反射光の色。黒(0,0,0)だと無効となる。
  Color? ks;

  // 0～1000の範囲で定義される、鏡面反射の重み。
  double? ns;

  // 透過度。Trかどちらかを使う。1.0が不透明。0.0が透明。
  double? d;

  // 反転した透過度。0.0が不透明。1.0が透明。
  double? tr;

  // 表面の光学密度。所謂屈折率。
  double? ni;

  // マテリアルとしての画像。
  Uint8List? image;

  // 以降は比較的基本的なものではないパラメータ。
  // マテリアルの光沢。0~3で指定される。
  int? illum;

  /// Constructor
  WFMaterial(this.name,
      {this.ka,
      this.kd,
      this.ks,
      this.ns,
      this.d,
      this.tr,
      this.ni,
      this.image,
      this.illum});

  /// 画像ファイルを読み込みます。
  static Future<Uint8List> _readFileBytes(String filePath) async {
    ByteData bd = await rootBundle.load(filePath);
    return bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
  }

  /// Stringデータからこのクラスを生成します。
  /// データは.mtlファイルの各マテリアル要素を分解したものを渡す必要があります。
  /// また、画像ファイルは.mtlファイルと同じディレクトリに配置する必要があります。
  static Future<WFMaterial> fromStr(String basePath, List<String> lines) async {
    Map<String, dynamic> mtl = {};
    List<String> e = [
      'newmtl',
      'Ka',
      'Kd',
      'Ks',
      'Ns',
      'd',
      'Tr',
      'Ni',
      'map_Kd',
      'illum'
    ];
    for (String line in lines) {
      if (line.startsWith('${e[0]} ')) {
        mtl[e[0]] = line.split(' ')[1];
      }
      // Color系
      else if (line.startsWith('${e[1]} ')) {
        mtl[e[1]] = UtilColorForSp3dConverter.toRGBAd(
            double.parse(line.split(' ')[1]),
            double.parse(line.split(' ')[2]),
            double.parse(line.split(' ')[3]));
      } else if (line.startsWith('${e[2]} ')) {
        mtl[e[2]] = UtilColorForSp3dConverter.toRGBAd(
            double.parse(line.split(' ')[1]),
            double.parse(line.split(' ')[2]),
            double.parse(line.split(' ')[3]));
      } else if (line.startsWith('${e[3]} ')) {
        mtl[e[3]] = UtilColorForSp3dConverter.toRGBAd(
            double.parse(line.split(' ')[1]),
            double.parse(line.split(' ')[2]),
            double.parse(line.split(' ')[3]));
      }
      // double系
      else if (line.startsWith('${e[4]} ')) {
        mtl[e[4]] = double.parse(line.split(' ')[1]);
      } else if (line.startsWith('${e[5]} ')) {
        mtl[e[5]] = double.parse(line.split(' ')[1]);
      } else if (line.startsWith('${e[6]} ')) {
        mtl[e[6]] = double.parse(line.split(' ')[1]);
      } else if (line.startsWith('${e[7]} ')) {
        mtl[e[7]] = double.parse(line.split(' ')[1]);
      }
      // 画像データ
      else if (line.startsWith('${e[8]} ')) {
        try {
          mtl[e[8]] = await _readFileBytes(line.split(' ')[1]);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      // 光沢の指定
      else if (line.startsWith('${e[9]} ')) {
        mtl[e[9]] = int.parse(line.split(' ')[1]);
      }
    }
    return WFMaterial(
      mtl[e[0]],
      ka: mtl.containsKey(e[1]) ? mtl[e[1]] : null,
      kd: mtl.containsKey(e[2]) ? mtl[e[2]] : null,
      ks: mtl.containsKey(e[3]) ? mtl[e[3]] : null,
      ns: mtl.containsKey(e[4]) ? mtl[e[4]] : null,
      d: mtl.containsKey(e[5]) ? mtl[e[5]] : null,
      tr: mtl.containsKey(e[6]) ? mtl[e[6]] : null,
      ni: mtl.containsKey(e[7]) ? mtl[e[7]] : null,
      image: mtl.containsKey(e[8]) ? mtl[e[8]] : null,
      illum: mtl.containsKey(e[9]) ? mtl[e[9]] : null,
    );
  }

  /// (en) Converts to a list of Sp3dMaterials
  /// with conversion-specific information in options.
  ///
  /// (ja) optionに変換専用の情報を持ったSp3dMaterialのリストに変換します。
  List<Sp3dMaterial> toSp3dMaterial(WFModel model) {
    List<Sp3dMaterial> r = [];
    final imageIndex = image != null ? model.images.indexOf(image!) : null;
    // このマテリアルに関係のあるFaceのみを抜き出す。
    List<WFFace> facesOfUseMyMaterial = [];
    Map<WFFace, WFGroup> parentGroup = {};
    for (WFObj i in model.objects) {
      for (WFGroup j in i.groups) {
        for (WFFace k in j.faces) {
          if (k.materialName == name) {
            facesOfUseMyMaterial.add(k);
            parentGroup[k] = j;
          }
        }
      }
    }
    // テクスチャ座標の違い毎にマテリアルを作成して格納。
    for (WFFace i in facesOfUseMyMaterial) {
      List<Offset> offsets = [];
      String textureIndexes = "";
      for (WFFaceIndexes j in i.vertices) {
        if (j.textureIndex != null) {
          final int resumedIndex = j.textureIndex! -
              (parentGroup[i]!.countRestartIndex.textureIndex ?? 0);
          offsets.add(model.textureOffsets[resumedIndex]);
          textureIndexes += "_$resumedIndex";
        }
      }
      r.add(Sp3dMaterial(kd ?? Colors.black, true, 0, kd ?? Colors.black,
          imageIndex: imageIndex,
          textureCoordinates: image != null ? offsets : null,
          name: name,
          // 変換専用情報
          option: {
            "ka": ka?.value.toRadixString(16),
            "ks": ks?.value.toRadixString(16),
            "ns": ns,
            "d": d,
            "tr": tr,
            "ni": ni,
            "illum": illum,
            // 変換時のみ必要な情報
            "wf_obj": name + textureIndexes
          }));
    }
    return r;
  }
}
