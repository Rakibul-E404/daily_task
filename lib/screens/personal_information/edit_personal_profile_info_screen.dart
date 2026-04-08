import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../features/individual_user/widget/edit_update_button.dart';
import 'package:askfemi/screens/personal_information/personal_Infromation_screen_controller.dart';

class EditPersonalProfileInfoScreen extends StatefulWidget {
  const EditPersonalProfileInfoScreen({super.key});

  @override
  State<EditPersonalProfileInfoScreen> createState() => _EditPersonalProfileInfoScreenState();
}

class _EditPersonalProfileInfoScreenState extends State<EditPersonalProfileInfoScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  /// Controllers for all editable fields
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController genderController;
  late TextEditingController dobController;
  late TextEditingController ageController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileController = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : Get.put(PersonalInformationController());

    nameController = TextEditingController(text: profileController.userName.value);
    emailController = TextEditingController(text: profileController.userEmail.value);
    phoneController = TextEditingController(text: profileController.userPhoneNumber.value);
    addressController = TextEditingController(text: profileController.userAddress.value);
    genderController = TextEditingController(text: profileController.userGender.value);
    dobController = TextEditingController(text: profileController.userDateOfBirth.value);
    ageController = TextEditingController(text: profileController.userAge.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    genderController.dispose();
    dobController.dispose();
    ageController.dispose();
    super.dispose();
  }

  String _getUserFriendlyErrorMessage(int? statusCode, String? message) {
    if (statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    if (statusCode == 502) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    if (statusCode == 503) {
      return 'Service unavailable. Please try again later.';
    }
    if (statusCode == 504) {
      return 'Gateway timeout. Please try again later.';
    }
    if (statusCode == 400) {
      return 'Invalid information. Please check your details.';
    }
    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }
    if (statusCode == 403) {
      return 'Access denied. Please check your permissions.';
    }
    if (statusCode == 404) {
      return 'Service not found. Please contact support.';
    }
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return 'Failed to update profile. Please try again.';
  }

  Future<void> _updateProfile() async {
    if (_isUpdating) return;

    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Name cannot be empty');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showErrorSnackbar('Phone number cannot be empty');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final profileController = Get.find<PersonalInformationController>();
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        _showErrorSnackbar('No access token found');
        return;
      }

      // Upload profile image if changed
      final imageUrl = await profileController.uploadProfileImageIfChanged();

      // Update profile data
      final Map<String, dynamic> requestBody = {
        "name": nameController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        "location": addressController.text.trim(),
      };

      print('📤 Updating profile with: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.updatePersonalInformationProfileData,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');
      print('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess) {
        await profileController.refreshData();
        _showSuccessSnackbar('Profile updated successfully');
        Get.back();
      } else {
        // Handle specific status codes
        final errorMessage = _getUserFriendlyErrorMessage(
          response.statusCode,
          response.errorMessage,
        );

        // Show different messages based on status code
        if (response.statusCode == 500) {
          _showErrorSnackbar(errorMessage);
        } else {
          _showErrorSnackbar(errorMessage);
        }
      }
    } catch (e) {
      print('Error: $e');

      // Check for socket/connection errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        _showErrorSnackbar('No internet connection. Please check your network.');
      } else {
        _showErrorSnackbar('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }


  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: AppColors.transparent,
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Edit Profile', style: AppTextStyles.largeHeading),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                color: AppColors.backgroundColor,
                margin: const EdgeInsets.all(16),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [ProfileAvatar(showEdit: true)],
                      ),
                      const SizedBox(height: 30),

                      LabeledTextField(
                        label: 'Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Email',
                        controller: emailController,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Phone number',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Address',
                        controller: addressController,
                        hintText: 'Enter your address',
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Gender',
                        controller: genderController,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Date of Birth',
                        controller: dobController,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Age',
                        controller: ageController,
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: _isUpdating
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
                : EditUpdateButton(
              title: 'Update Profile',
              onPressed: _updateProfile,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// ----------------------------
/// LABELED TEXT FIELD (EDIT MODE)
/// ----------------------------
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final String? hintText;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: AppTextStyles.defaultTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------------------
/// PROFILE AVATAR WIDGET
/// ----------------------------
class ProfileAvatar extends StatelessWidget {
  final bool showEdit;

  const ProfileAvatar({super.key, this.showEdit = false});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : null;

    return Obx(() {
      String imageUrl = profileController?.getDisplayImage() ?? '';
      final isUploading = profileController?.isUploadingImage ?? false.obs;

      return Center(
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl.isNotEmpty
                      ? (imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl)
                      : (imageUrl.startsWith('/')
                      ? FileImage(File(imageUrl)) as ImageProvider
                      : const AssetImage('assets/images/dummy_user_image.png') as ImageProvider))
                      : const AssetImage('assets/images/dummy_user_image.png') as ImageProvider,
                  onBackgroundImageError: (_, __) {},
                ),
                if (showEdit)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isUploading.value ? null : () {
                        profileController?.showImagePickerOptions();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: isUploading.value
                            ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          CupertinoIcons.pencil_circle_fill,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isUploading.value)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Uploading...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}