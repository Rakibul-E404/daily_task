import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/network/iamge_upload_service.dart';
import '../../utils/temp/cache.dart';

class PersonalInformationController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _picker = ImagePicker();

  // Reactive variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isUploadingImage = false.obs;
  var errorMessage = RxString('');
  var isFirstLoad = true.obs;

  // User data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhoneNumber = ''.obs;
  var userAddress = ''.obs;
  var userGender = ''.obs;
  var userDateOfBirth = ''.obs;
  var userAge = ''.obs;
  var userProfileImage = ''.obs;
  var isAccountSecondary = false.obs;

  // Temporary image file for preview before upload
  var tempProfileImageFile = Rx<File?>(null);
  var hasImageChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final hasCache = _loadFromCache();

    if (!hasCache) {
      await fetchPersonalInformation(showLoading: true);
    } else {
      await fetchPersonalInformation(background: true);
    }
  }

  bool _loadFromCache() {
    try {
      final cachedData = CacheService.getUserProfile();
      if (cachedData != null && cachedData.isNotEmpty) {
        userName.value = cachedData['name'] ?? '';
        userEmail.value = cachedData['email'] ?? '';
        userPhoneNumber.value = cachedData['phoneNumber'] ?? '';
        userAddress.value = cachedData['address'] ?? '';
        userGender.value = cachedData['gender'] ?? '';
        userDateOfBirth.value = cachedData['dateOfBirth'] ?? '';
        userAge.value = cachedData['age'] ?? '';
        userProfileImage.value = cachedData['profileImage'] ?? '';
        isAccountSecondary.value = cachedData['isAccountSecondary'] ?? false;

        print('📦 Loaded from cache: ${userName.value}');
        return true;
      } else {
        print('No cache found');
        return false;
      }
    } catch (e) {
      print('Error loading cache: $e');
      return false;
    }
  }

  Future<void> fetchPersonalInformation({bool background = false, bool showLoading = false}) async {
    if (showLoading) {
      isLoading.value = true;
    }

    if (background) {
      isRefreshing.value = true;
    }

    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      print('🔑 Token: ${token != null ? 'Found' : 'Not found'}');

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        return;
      }

      print('🌐 Making API request to: ${AppUrl.getPersonalInformation}');

      final response = await _networkCaller.getRequest(
        AppUrl.getPersonalInformation,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final result = attributes?['result'];

        if (result != null) {
          final name = result['name'] ?? '';
          final email = result['email'] ?? '';
          final phoneNumber = result['phoneNumber'] ?? '';
          final isSecondary = attributes?['isAccountSecondary'] ?? false;

          // Get profile image URL - empty string if not available
          String profileImage = '';
          final profileImageData = result['profileImage'];
          if (profileImageData != null && profileImageData['imageUrl'] != null) {
            profileImage = _getImageUrl(profileImageData['imageUrl']);
          }

          String address = '';
          String gender = '';
          String dateOfBirth = '';
          String age = '';

          final profileId = result['profileId'];
          if (profileId != null) {
            address = profileId['location'] ?? '';
            gender = _formatGender(profileId['gender'] ?? '');
            dateOfBirth = _formatDate(profileId['dob'] ?? '');
            age = _calculateAge(profileId['dob'] ?? '');
          }

          userName.value = name;
          userEmail.value = email;
          userPhoneNumber.value = phoneNumber;
          userAddress.value = address;
          userGender.value = gender;
          userDateOfBirth.value = dateOfBirth;
          userAge.value = age;
          userProfileImage.value = profileImage;
          isAccountSecondary.value = isSecondary;

          await CacheService.saveUserProfile({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'address': address,
            'gender': gender,
            'dateOfBirth': dateOfBirth,
            'age': age,
            'profileImage': profileImage,
            'isAccountSecondary': isSecondary,
          });

          print('✅ Data updated from API: $name');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load data';
        print('❌ API call failed: ${response.errorMessage}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching personal information: $e');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
      if (background) {
        isRefreshing.value = false;
      }
      isFirstLoad.value = false;
    }
  }

  Future<void> refreshData() async {
    print('🔄 Manual refresh triggered');
    isRefreshing.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No token found');
        isRefreshing.value = false;
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getPersonalInformation,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final result = attributes?['result'];

        if (result != null) {
          userName.value = result['name'] ?? '';
          userEmail.value = result['email'] ?? '';
          userPhoneNumber.value = result['phoneNumber'] ?? '';
          isAccountSecondary.value = attributes?['isAccountSecondary'] ?? false;

          final profileImageData = result['profileImage'];
          if (profileImageData != null && profileImageData['imageUrl'] != null) {
            userProfileImage.value = _getImageUrl(profileImageData['imageUrl']);
          } else {
            userProfileImage.value = '';
          }

          final profileId = result['profileId'];
          if (profileId != null) {
            userAddress.value = profileId['location'] ?? '';
            userGender.value = _formatGender(profileId['gender'] ?? '');
            userDateOfBirth.value = _formatDate(profileId['dob'] ?? '');
            userAge.value = _calculateAge(profileId['dob'] ?? '');
          }

          await CacheService.saveUserProfile({
            'name': userName.value,
            'email': userEmail.value,
            'phoneNumber': userPhoneNumber.value,
            'address': userAddress.value,
            'gender': userGender.value,
            'dateOfBirth': userDateOfBirth.value,
            'age': userAge.value,
            'profileImage': userProfileImage.value,
            'isAccountSecondary': isAccountSecondary.value,
          });

          print('✅ Refresh successful');
        }
      }
    } catch (e) {
      print('Refresh error: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> forceRefresh() async {
    print('🔄 Force refresh - clearing cache');
    await CacheService.clearCache();
    await fetchPersonalInformation(showLoading: true);
  }

  Future<void> backgroundRefresh() async {
    print('🔄 Background refresh');
    await fetchPersonalInformation(background: true);
  }

  // ==================== IMAGE PICKER (No auto-upload) ====================

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        tempProfileImageFile.value = File(image.path);
        hasImageChanges.value = true;
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        tempProfileImageFile.value = File(image.path);
        hasImageChanges.value = true;
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image from camera',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Upload image when update profile is called
  Future<String?> uploadProfileImageIfChanged() async {
    if (hasImageChanges.value && tempProfileImageFile.value != null) {
      isUploadingImage.value = true;
      try {
        final imageUrl = await _imageUploadService.uploadProfileImage(tempProfileImageFile.value!);
        if (imageUrl != null) {
          userProfileImage.value = imageUrl;
          tempProfileImageFile.value = null;
          hasImageChanges.value = false;
          return imageUrl;
        }
        return null;
      } finally {
        isUploadingImage.value = false;
      }
    }
    return userProfileImage.value;
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImageFromGallery();
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImageFromCamera();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Get the current display image (temp preview or actual)
  String getDisplayImage() {
    if (hasImageChanges.value && tempProfileImageFile.value != null) {
      return tempProfileImageFile.value!.path;
    }
    return userProfileImage.value;
  }

  // Reset image changes
  void resetImageChanges() {
    tempProfileImageFile.value = null;
    hasImageChanges.value = false;
  }

  // ==================== HELPER METHODS ====================

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';  // Return empty string instead of dummy image
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    String cleanPath = imagePath;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '${AppUrl.imageBaseUrl}/$cleanPath';
  }

  String _formatGender(String gender) {
    if (gender.isEmpty) return 'Not specified';
    return gender[0].toUpperCase() + gender.substring(1).toLowerCase();
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Not specified';
    }
  }

  String _calculateAge(String dateString) {
    if (dateString.isEmpty) return 'Not specified';
    try {
      final birthDate = DateTime.parse(dateString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'Not specified';
    }
  }
}