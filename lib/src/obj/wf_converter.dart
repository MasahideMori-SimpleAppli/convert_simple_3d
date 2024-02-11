import 'package:simple_3d/simple_3d.dart';

import '../../convert_simple_3d.dart';

/// (en)　This is a utility for converting .Obj format files to Sp3dObj.
///
/// (ja) .Obj形式のファイルからSp3dObjにコンバートするためのユーティリティです。
///
class Sp3dObjConverter {
  /// (en) Converts an Obj file to Sp3dObj and returns it.
  ///
  /// (ja) ObjファイルをSp3dObjに変換して返します。
  ///
  /// * [basePath] : / etc. The file directly under the asset is called.
  /// Related .mtl files must be in the same path.
  /// * [objName] : sample.obj etc.
  /// * [mode] : Loading mode.
  static Future<List<Sp3dObj>> fromWFObjFile(String basePath, String objName,
      {WFLoadingMode mode =
          WFLoadingMode.notResetVertexIndexesOnNewGroup}) async {
    List<Sp3dObj> r = [];
    WFModel model = await WFModel.fromStr(basePath, objName, mode);
    // マテリアル情報をコンバート
    List<Sp3dMaterial> materials = [];
    for (WFMaterial i in model.materials) {
      materials.addAll(i.toSp3dMaterial(model));
    }
    for (WFObj i in model.objects) {
      // 面情報をコンバート
      List<Sp3dFragment> fragments = [];
      // グループをFragment扱いで変換。
      for (WFGroup j in i.groups) {
        fragments.add(j.toSp3dFragment(materials));
      }
      // verticesとmaterialsは簡単のためにコピーをそのまま使用する。
      r.add(Sp3dObj(model.vertices, fragments, materials, model.images,
          name: i.name));
    }
    return r;
  }
}
