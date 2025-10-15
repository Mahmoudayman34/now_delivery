import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Pick and save profile image
  static Future<String?> pickAndCropProfileImage({ImageSource? source}) async {
    try {
      // Use provided source or default to gallery
      final ImageSource imageSource = source ?? ImageSource.gallery;
      
      // Check and request permissions before accessing camera/gallery
      bool hasPermission = false;
      if (imageSource == ImageSource.camera) {
        hasPermission = await _checkCameraPermission();
        if (!hasPermission) {
          debugPrint('Camera permission denied');
          return null;
        }
      } else {
        hasPermission = await _checkPhotoLibraryPermission();
        if (!hasPermission) {
          debugPrint('Photo library permission denied');
          return null;
        }
      }
      
      // Pick image with constraints for profile photo
      final XFile? pickedFile = await _picker.pickImage(
        source: imageSource,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front, // Use front camera for profile pictures
      );
      
      if (pickedFile == null) {
        debugPrint('User cancelled image picking');
        return null;
      }
      
      // Verify file exists and is readable
      final File sourceFile = File(pickedFile.path);
      if (!await sourceFile.exists()) {
        debugPrint('Picked file does not exist: ${pickedFile.path}');
        return null;
      }
      
      // Save to app directory
      final String savedPath = await _saveImageLocally(pickedFile.path);
      
      // Clean up temporary file (only if it's different from saved path)
      if (pickedFile.path != savedPath) {
        try {
          await sourceFile.delete();
        } catch (e) {
          debugPrint('Could not delete temporary file: $e');
          // Non-critical error, continue
        }
      }
      
      return savedPath;
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Check camera permission
  static Future<bool> _checkCameraPermission() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.camera.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.camera.request();
          return result.isGranted;
        }
        return status.isGranted || status.isLimited;
      }
      // Android permissions are handled by image_picker plugin
      return true;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }
  
  /// Check photo library permission
  static Future<bool> _checkPhotoLibraryPermission() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isDenied || status.isPermanentlyDenied) {
          final result = await Permission.photos.request();
          return result.isGranted || result.isLimited;
        }
        return status.isGranted || status.isLimited;
      }
      // Android permissions are handled by image_picker plugin
      return true;
    } catch (e) {
      debugPrint('Error checking photo library permission: $e');
      return false;
    }
  }
  
  /// Save image to local app directory
  static Future<String> _saveImageLocally(String sourcePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String profileImagesDir = path.join(appDir.path, 'profile_images');
    
    // Create directory if it doesn't exist
    await Directory(profileImagesDir).create(recursive: true);
    
    // Generate unique filename
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String targetPath = path.join(profileImagesDir, fileName);
    
    // Copy file
    await File(sourcePath).copy(targetPath);
    
    return targetPath;
  }
  
  /// Delete old profile image
  static Future<void> deleteProfileImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }
  
  /// Pick image from camera
  static Future<String?> pickImageFromCamera() async {
    return await pickAndCropProfileImage(source: ImageSource.camera);
  }
  
  /// Pick image from gallery
  static Future<String?> pickImageFromGallery() async {
    return await pickAndCropProfileImage(source: ImageSource.gallery);
  }
}
