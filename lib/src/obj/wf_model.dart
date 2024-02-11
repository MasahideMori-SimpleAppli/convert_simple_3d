import 'package:flutter/services.dart';
import 'package:simple_3d/simple_3d.dart';

import '../../convert_simple_3d.dart';

/// (en) This is a structure for managing WFObj in .obj file units.
///
/// (ja) WFObjを.objファイル単位で管理するための構造体です。
class WFModel {
  List<WFObj> objects = [];
  List<Sp3dV3D> vertices = [];
  List<Offset> textureOffsets = [];
  List<Sp3dV3D> normals = [];
  List<WFMaterial> materials = [];
  List<Uint8List> images = [];

  /// (en)Load the obj file.
  /// Related mtl files must be in the same basePath.
  ///
  /// (ja) objファイルを読み込みます。
  /// 関連するmtlファイルは同じbasePath内に存在する必要があります。
  ///
  /// * [basePath] : e.g. assets/.
  /// * [objFileName] : e.g. sample.obj.
  /// * [mode] : Loading mode.
  static Future<WFModel> fromStr(
      String basePath, String objFileName, WFLoadingMode mode) async {
    final String objStr = await rootBundle.loadString(basePath + objFileName);
    WFModel r = WFModel();
    String? materialName;
    final List<String> lines = objStr.split("\n");
    for (String line in lines) {
      // コメント行または空行のスキップ
      if (line == "" || line.startsWith('#')) {
        continue;
      }
      // オブジェクトの定義
      if (line.startsWith("o ")) {
        r.objects.add(WFObj(line.substring(2)));
      } else if (line.startsWith("g ")) {
        final name = line.substring(2);
        if (r.objects.isEmpty) {
          r.objects.add(WFObj(name));
        }
        switch (mode) {
          case WFLoadingMode.resetVertexIndexesOnNewGroup:
            r.objects.last.groups.add(WFGroup(
                name,
                WFFaceIndexes.fromAllIndex(r.vertices.length,
                    r.textureOffsets.length, r.normals.length)));
            break;
          case WFLoadingMode.notResetVertexIndexesOnNewGroup:
            r.objects.last.groups
                .add(WFGroup(name, WFFaceIndexes.fromAllIndex(0, 0, 0)));
            break;
        }
      }
      // 追加のマテリアルファイル定義の指定の場合
      else if (line.startsWith("mtllib ")) {
        final String mtlName = line.substring(7);
        r.materials.addAll(await _mtlMapping(basePath, mtlName));
      }
      // 頂点座標
      else if (line.startsWith("v ")) {
        final List<String> values = line.substring(2).split(" ");
        r.vertices.add(Sp3dV3D(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // 法線ベクトル
      else if (line.startsWith("vn ")) {
        final List<String> values = line.substring(3).split(" ");
        r.normals.add(Sp3dV3D(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // テクスチャ座標の指定
      else if (line.startsWith("vt ")) {
        final List<String> values = line.substring(3).split(" ");
        r.textureOffsets
            .add(Offset(double.parse(values[0]), double.parse(values[1])));
      }
      // 次の行から適用するマテリアルの名前
      else if (line.startsWith("usemtl ")) {
        materialName = line.substring(7);
      }
      // 面の指定
      else if (line.startsWith("f ")) {
        final List<String> values = line.substring(2).split(" ");
        final List<WFFaceIndexes> faceIndexes = [];
        // OBJファイルのインデックスは1始まりなので0始まりに変換しておく。
        for (String v in values) {
          if (v.contains("/")) {
            // 頂点情報以外の情報も含まれるケース
            List<String> faceInfo = v.split("/");
            WFFaceIndexes mFI = WFFaceIndexes();
            for (int i = 0; i < faceInfo.length; i++) {
              final String fi = faceInfo[i];
              if (fi == "") {
                continue;
              }
              if (i == 0) {
                mFI.vertexIndex = int.parse(fi) - 1;
              } else if (i == 1) {
                mFI.textureIndex = int.parse(fi) - 1;
              } else {
                mFI.normalIndex = int.parse(fi) - 1;
              }
            }
            faceIndexes.add(mFI);
          } else {
            // 頂点情報のみが含まれるケース
            faceIndexes.add(WFFaceIndexes.fromVertexIndex(int.parse(v) - 1));
          }
        }
        if (r.objects.last.groups.isEmpty) {
          r.objects.last.groups.add(WFGroup(
              r.objects.last.name, WFFaceIndexes.fromAllIndex(0, 0, 0)));
        }
        r.objects.last.groups.last.faces
            .add(WFFace(materialName!, faceIndexes));
      }
    }
    return r;
  }

  /// (en) Reads and returns the internal settings of the mtl file.
  ///
  /// (ja) mtlファイルの内部設定を読み込んで返します。
  static Future<List<WFMaterial>> _mtlMapping(
      String basePath, String mtlFileName) async {
    final String mtlStr = await rootBundle.loadString(basePath + mtlFileName);
    List<WFMaterial> r = [];
    final List<String> sList = mtlStr.split('\n');
    List<String> buf = [];
    for (String l in sList) {
      // コメント行及び空行のスキップ
      if (l == "" || l.startsWith('#')) {
        continue;
      } else if (l.startsWith('newmtl')) {
        if (buf.isNotEmpty) {
          r.add(await WFMaterial.fromStr(basePath, buf));
          buf.clear();
        }
      }
      buf.add(l);
    }
    // 最後の要素の格納
    if (buf.isNotEmpty) {
      r.add(await WFMaterial.fromStr(basePath, buf));
      buf.clear();
    }
    return r;
  }
}

/// Vertex info.
class WFFaceIndexes {
  int vertexIndex = -1;
  int? textureIndex;
  int? normalIndex;

  WFFaceIndexes();

  /// Create only textureIndex.
  WFFaceIndexes.fromVertexIndex(this.vertexIndex);

  /// Create from all params.
  WFFaceIndexes.fromAllIndex(
      this.vertexIndex, this.textureIndex, this.normalIndex);
}

/// Face info.
class WFFace {
  String materialName;
  List<WFFaceIndexes> vertices;

  WFFace(this.materialName, this.vertices);

  /// convert to Sp3dFace
  Sp3dFace toSp3dFace(
      List<Sp3dMaterial> materials, WFFaceIndexes countRestartIndex) {
    List<int> vertexIndexes = [];
    String textureIndexes = "";
    for (WFFaceIndexes i in vertices) {
      vertexIndexes.add(i.vertexIndex - countRestartIndex.vertexIndex);
      if (i.textureIndex != null) {
        final int resumedIndex =
            i.textureIndex! - (countRestartIndex.textureIndex ?? 0);
        textureIndexes += "_$resumedIndex";
      }
    }
    int? materialIndex;
    for (int i = 0; i < materials.length; i++) {
      if (materials[i].option != null) {
        if (materials[i].option!.containsKey("wf_obj")) {
          if (materials[i].option!["wf_obj"] == materialName + textureIndexes) {
            materialIndex = i;
            break;
          }
        }
      }
    }
    return Sp3dFace(vertexIndexes, materialIndex);
  }
}

/// Group in WFObject.
class WFGroup {
  String name;
  WFFaceIndexes countRestartIndex;
  List<WFFace> faces = [];

  /// * [name] : Group name.
  /// * [countRestartIndex] : The length of each vertex information
  /// at the time this group was created.
  WFGroup(this.name, this.countRestartIndex);

  /// convert to Sp3dFragment
  Sp3dFragment toSp3dFragment(List<Sp3dMaterial> materials) {
    List<Sp3dFace> mFaces = [];
    for (WFFace i in faces) {
      mFaces.add(i.toSp3dFace(materials, countRestartIndex));
    }
    return Sp3dFragment(mFaces, name: name);
  }
}

/// Object data class.
class WFObj {
  String name;
  List<WFGroup> groups = [];

  /// * [name] : Object name.
  WFObj(this.name, {List<WFGroup>? groups}) {
    if (groups != null) {
      this.groups = groups;
    }
  }

  /// shallow copy.
  WFObj copy() {
    return WFObj(name, groups: [...groups]);
  }
}

enum WFLoadingMode {
  notResetVertexIndexesOnNewGroup,
  resetVertexIndexesOnNewGroup
}
