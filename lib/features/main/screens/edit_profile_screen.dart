import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/app_theme.dart';
import '../../../core/services/image_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/loading_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedImagePath;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling ref.read during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          _selectedImagePath = user.avatar;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      // Pass the selected source to the image service
      final String? imagePath = await ImageService.pickAndCropProfileImage(source: source);
      
      if (imagePath != null) {
        setState(() {
          _selectedImagePath = imagePath;
        });
      } else {
        // Image picking was cancelled or failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Camera access was denied or cancelled. Please grant camera permission in Settings.'
                    : 'Photo library access was denied or cancelled. Please grant photo access in Settings.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () async {
                  // This will be imported from permission_handler
                  await openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Image Source',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              title: Text(
                'Camera',
                style: GoogleFonts.inter(color: AppTheme.darkGray),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: Text(
                'Gallery',
                style: GoogleFonts.inter(color: AppTheme.darkGray),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Show a confirmation dialog before updating
    final shouldUpdate = await _showUpdateConfirmation();
    if (!shouldUpdate) return;

    try {
      await ref.read(authProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        avatar: _selectedImagePath,
      );

      if (mounted) {
        // Show success dialog with updated information
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Update Failed',
          message: 'Failed to update profile: ${e.toString()}',
          onRetry: _updateProfile,
        );
      }
    }
  }

  Future<bool> _showUpdateConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Update Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGray,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to update your profile with the following information?',
              style: GoogleFonts.inter(color: AppTheme.mediumGray),
            ),
            const SizedBox(height: 16),
            _InfoRow('Name', _nameController.text.trim()),
            _InfoRow('Email', _emailController.text.trim()),
            _InfoRow('Phone', _phoneController.text.trim().isEmpty ? 'Not provided' : _phoneController.text.trim()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Success!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your profile has been updated successfully. The changes are now reflected in your account.',
              style: GoogleFonts.inter(
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Profile Updated',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return LoadingOverlay(
      isLoading: authState.isLoading && !_isUploadingImage,
      loadingMessage: 'Updating profile...',
      child: Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkGray),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppTheme.primaryOrange.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: Image.file(
                                      File(_selectedImagePath!),
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.primaryOrange,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primaryOrange,
                                  ),
                          ),
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                _isUploadingImage ? Icons.hourglass_empty : Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Text(
                        _isUploadingImage ? 'Selecting...' : 'Change Profile Photo',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _isUploadingImage 
                              ? AppTheme.mediumGray 
                              : AppTheme.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number (Optional)',
                      hint: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Error Message
              if (authState.hasError)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: GoogleFonts.inter(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Update Button
              LoadingButton(
                onPressed: _updateProfile,
                isLoading: authState.isLoading,
                text: 'Update Profile',
                backgroundColor: AppTheme.primaryOrange,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
