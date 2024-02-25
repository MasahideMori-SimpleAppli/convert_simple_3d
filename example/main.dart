import 'package:convert_simple_3d/convert_simple_3d.dart';
import 'package:flutter/material.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final List<Sp3dObj> _objs = [];
  late Sp3dWorld _world;
  bool _isLoaded = false;
  final ValueNotifier<int> _vn = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    load3dFile();
  }

  void load3dFile() async {
    // TODO Set the path for obj files created with software such as Blender.
    //  The mtl file must be placed at the same level as the obj file.
    _objs.addAll(await Sp3dObjConverter.fromWFObjFile("/", "test.obj"));
    for (Sp3dObj i in _objs) {
      i.resize(10);
    }
    _world = Sp3dWorld(_objs);
    _world.initImages().then((value) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return MaterialApp(
          title: 'Convert test',
          home: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 0, 255, 0),
              ),
              backgroundColor: const Color.fromARGB(255, 33, 33, 33),
              body: Container()));
    } else {
      final double width = MediaQuery.of(context).size.width;
      final double height = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          kBottomNavigationBarHeight -
          kToolbarHeight;
      return MaterialApp(
        title: 'Convert test',
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 255, 0),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          body: Column(
            children: [
              Sp3dRenderer(
                Size(width, height),
                Sp3dV2D(width / 2, height / 2),
                _world,
                Sp3dCamera(Sp3dV3D(0, 0, 3000), 6000, isAllDrawn: true),
                Sp3dLight(Sp3dV3D(0, 0, -1), syncCam: true),
                allowUserWorldRotation: true,
                checkTouchObj: true,
                vn: _vn,
              )
            ],
          ),
        ),
      );
    }
  }
}
