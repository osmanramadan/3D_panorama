import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panorama osman ramadan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;
  double zoomValue = 1.0;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void zoomIn() {
    setState(() {
      zoomValue += 0.1;
    });
  }
  void zoomOut() {
    setState(() {
      zoomValue -= 0.1;
    });
  }
  void clear() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);

    await _cameraController.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _captureImage() async {
    final XFile imageFile = await _cameraController.takePicture();

    setState(() {
      _capturedImage = imageFile;
    });

    print(imageFile.path);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panorama Demo'),
      ),
      body: Stack(
          children: [
          CameraPreview(_cameraController),
          Positioned(
            top: 110.0,
            left: 110.0,
            child: SizedBox(
              width: 350.0 * zoomValue,
              height: 350.0 * zoomValue,
              child:Panorama(
                  zoom: zoomValue, // Initial zoom level, 1.0 means no zoom
                    sensitivity:8.0, // Touch sensitivity for panning and zooming
                    latitude :2,
                    longitude:-33,
                    maxZoom: 5.0, // Maximum allowed zoom level
                    minZoom: 0.5, // Minimum allowed zoom level
                    interactive: true,
                  child: _capturedImage != null
                    ? Image.network(_capturedImage!.path)
                    : Image.asset("assets/image3.jpg"), // Allow user interaction (panning and zooming)
                    ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                _captureImage();
              },
              child: const Text('Capture Image'),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                zoomIn();
              },
              child: const Text('Zoom in'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                clear();
              },
              child: const Text('clear'),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: () {
                zoomOut();
              },
              child: const Text('Zoom out'),
            ),
          ),
        ],
      ),
    );
  }
}
