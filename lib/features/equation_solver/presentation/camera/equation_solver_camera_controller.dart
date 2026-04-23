import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:equation_solver_mobile/features/equation_solver/repository/equation_solver_repository_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class EquationSolverCameraController {
  EquationSolverCameraController({
    required IEquationSolverRepositoryInterface repository,
  }) : _repository = repository;

  final IEquationSolverRepositoryInterface _repository;
  CameraController? cameraController;

  Future<void> initCamera() async {
    final backCamera = await _getBackCamera();
    cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await cameraController!.initialize();
  }

  Future<CameraDescription> _getBackCamera() async {
    final cameras = await availableCameras();
    return cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  Future<String?> captureAndRecognize({
    Size? viewportSize,
    Rect? focusRect,
  }) async {
    if (cameraController == null) return null;
    try {
      final picture = await cameraController!.takePicture();
      final imagePath = viewportSize != null && focusRect != null
          ? await cropImageToFocusArea(
              imagePath: picture.path,
              viewportSize: viewportSize,
              focusRect: focusRect,
            )
          : picture.path;
      return await _repository.getRecognizedText(imagePath);
    } catch (_) {
      return null;
    }
  }

  Future<String> cropImageToFocusArea({
    required String imagePath,
    required Size viewportSize,
    required Rect focusRect,
  }) async {
    final sourceFile = File(imagePath);
    final decodedImage = img.decodeImage(await sourceFile.readAsBytes());
    if (decodedImage == null) {
      return imagePath;
    }

    final orientedImage = img.bakeOrientation(decodedImage);
    final cropRect = _mapFocusRectToImage(
      viewportSize: viewportSize,
      focusRect: focusRect,
      imageSize: Size(
        orientedImage.width.toDouble(),
        orientedImage.height.toDouble(),
      ),
    );

    final croppedImage = img.copyCrop(
      orientedImage,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );

    final croppedImagePath = '$imagePath.focus_crop.jpg';
    await File(
      croppedImagePath,
    ).writeAsBytes(img.encodeJpg(croppedImage, quality: 95));
    return croppedImagePath;
  }

  Rect _mapFocusRectToImage({
    required Size viewportSize,
    required Rect focusRect,
    required Size imageSize,
  }) {
    final scale = math.max(
      viewportSize.width / imageSize.width,
      viewportSize.height / imageSize.height,
    );
    final horizontalInset =
        ((imageSize.width * scale) - viewportSize.width) / 2;
    final verticalInset =
        ((imageSize.height * scale) - viewportSize.height) / 2;

    final sourceLeft = ((focusRect.left + horizontalInset) / scale).clamp(
      0.0,
      imageSize.width,
    );
    final sourceTop = ((focusRect.top + verticalInset) / scale).clamp(
      0.0,
      imageSize.height,
    );
    final sourceRight = ((focusRect.right + horizontalInset) / scale).clamp(
      0.0,
      imageSize.width,
    );
    final sourceBottom = ((focusRect.bottom + verticalInset) / scale).clamp(
      0.0,
      imageSize.height,
    );

    final left = sourceLeft.round();
    final top = sourceTop.round();
    final width = math.max(1, (sourceRight - sourceLeft).round());
    final height = math.max(1, (sourceBottom - sourceTop).round());

    return Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      math.min(width, imageSize.width.round() - left).toDouble(),
      math.min(height, imageSize.height.round() - top).toDouble(),
    );
  }

  Future<String?> pickFromGalleryAndRecognize() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      return await _repository.getRecognizedText(image.path);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    cameraController?.dispose();
  }
}
