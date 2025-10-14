import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// Pick and save profile image
  static Future<String?> pickAndCropProfileImage({ImageSource? source}) async {
    try {
      // Use provided source or default to gallery
      final ImageSource imageSource = source ?? ImageSource.gallery;
      
      // Pick image with constraints for profile photo
      final XFile? pickedFile = await _picker.pickImage(
        source: imageSource,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      // Save to app directory
      final String savedPath = await _saveImageLocally(pickedFile.path);
      
      // Clean up temporary file
      await File(pickedFile.path).delete().catchError((_) => File(''));
      
      return savedPath;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
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
