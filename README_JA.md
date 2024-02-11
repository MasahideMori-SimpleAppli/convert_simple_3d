# convert_simple_3d

日本語版の解説です。  

## 概要
このパッケージはSimple 3D Formatと、他の3Dファイルとを変換するためのものです。  
ただし、それぞれのファイル形式には特有のパラメータが存在するため、互換性は完全ではありません。  
プロジェクトとしての優先度も低めなので、注意してください。  

## 利用方法
### 関連パッケージ
このパッケージは、以下のパッケージをより利用しやすくするためのものです。  
[simple_3d](https://pub.dev/packages/simple_3d)

### .objファイルのSp3dObjへの変換
```dart
List<Sp3dObj> objs = await Sp3dObjConverter.fromWFObjFile("/", "test.obj");
```

## サポート
このパッケージには公式のサポートはありません。

## バージョン管理について
それぞれ、Cの部分が変更されます。
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更 
  - C.X.X
- メソッドの追加など 
  - X.C.X
- 軽微な変更やバグ修正 
  - X.X.C
    
## ライセンス
このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## 著作権表示
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.