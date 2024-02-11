# convert_simple_3d

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/convert_simple_3d/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/convert_simple_3d/blob/main/README_JA.md)にあります。

## overview
This package is for converting between Simple 3D Format and other 3D files.
However, each file format has unique parameters, so compatibility is not complete.
Please note that this project has low priority.

## How to Use
### Related packages
This package is intended to make the following packages easier to use.
[simple_3d](https://pub.dev/packages/simple_3d)

### Converting .obj files to Sp3dObj
```dart
List<Sp3dObj> objs = await Sp3dObjConverter.fromWFObjFile("/", "test.obj");
````

## support
This package has no official support.

## About version control
The C part will be changed at the time of version upgrade.
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
This software is released under the MIT License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.