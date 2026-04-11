import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
  var isNetworkError = false.obs;
  var isServerError = false.obs;

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

  // Preferred Time
  var preferredTime = ''.obs;
  var isLoadingPreferredTime = false.obs;

  // Temporary image file for preview before upload
  var tempProfileImageFile = Rx<File?>(null);
  var hasImageChanges = false.obs;

  // Allowed MIME types and extensions
  final List<String> _allowedExtensions = ['jpg', 'jpeg', 'png'];
  final List<String> _allowedMimeTypes = ['image/jpeg', 'image/png', 'image/jpg'];

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final hasCache = _loadFromCache();

    // Load cached preferred time
    await loadCachedPreferredTime();

    if (!hasCache) {
      await fetchPersonalInformation(showLoading: true);
      await fetchPreferredTime();
    } else {
      await fetchPersonalInformation(background: true);
      await fetchPreferredTime();
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

  // Validate image file by extension and MIME type
  Future<bool> _isValidImageFile(File file) async {
    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      return false;
    }

    // Try to read file header to determine MIME type
    try {
      final List<int> fileHeader = await file.readAsBytes().then((bytes) => bytes.sublist(0, bytes.length > 12 ? 12 : bytes.length));

      // Check PNG signature
      if (fileHeader.length >= 8 &&
          fileHeader[0] == 0x89 &&
          fileHeader[1] == 0x50 &&
          fileHeader[2] == 0x4E &&
          fileHeader[3] == 0x47 &&
          fileHeader[4] == 0x0D &&
          fileHeader[5] == 0x0A &&
          fileHeader[6] == 0x1A &&
          fileHeader[7] == 0x0A) {
        return true; // PNG
      }

      // Check JPEG signature (SOI marker)
      if (fileHeader.length >= 2 && fileHeader[0] == 0xFF && fileHeader[1] == 0xD8) {
        return true; // JPEG
      }

      return false;
    } catch (e) {
      print('Error reading file header: $e');
      return false;
    }
  }

  // Show error dialog for invalid image type
  void _showInvalidImageTypeAlert() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Invalid Image Format',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Please select a valid image file.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supported formats:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allowedExtensions.map((ext) {
                      return Chip(
                        label: Text(ext.toUpperCase()),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      barrierDismissible: true,
    );
  }

  String _getUserFriendlyErrorMessage(dynamic error, {int? statusCode}) {
    // Server error status codes
    if (statusCode == 502) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    if (statusCode == 503) {
      return 'Service unavailable. Please try again later.';
    }
    if (statusCode == 504) {
      return 'Gateway timeout. Please try again later.';
    }
    if (statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    if (statusCode == 404) {
      return 'Service not found. Please contact support.';
    }
    if (statusCode == 403) {
      return 'Access denied. Please check your permissions.';
    }
    if (statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    // Network/Connection errors
    if (error.toString().contains('Failed host lookup') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('No address associated with hostname')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    if (error.toString().contains('Connection refused') ||
        error.toString().contains('Connection timed out')) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.toString().contains('Network is unreachable')) {
      return 'No internet connection. Please check your network settings.';
    }

    return 'An error occurred. Please try again later.';
  }

  Future<void> fetchPersonalInformation({bool background = false, bool showLoading = false}) async {
    if (showLoading) {
      isLoading.value = true;
    }

    if (background) {
      isRefreshing.value = true;
    }

    errorMessage.value = '';
    isNetworkError.value = false;
    isServerError.value = false;

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

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        isNetworkError.value = false;
        isServerError.value = false;

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
        // Handle specific status codes
        if (response.statusCode == 502 || response.statusCode == 503 ||
            response.statusCode == 504 || response.statusCode == 500) {
          isServerError.value = true;
          isNetworkError.value = true;
          errorMessage.value = _getUserFriendlyErrorMessage(null, statusCode: response.statusCode);
        } else {
          errorMessage.value = response.errorMessage ?? 'Failed to load data';
        }
        print('❌ API call failed: ${response.errorMessage}');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      isNetworkError.value = true;
      errorMessage.value = _getUserFriendlyErrorMessage(e);
    } catch (e) {
      print('Error fetching personal information: $e');
      errorMessage.value = _getUserFriendlyErrorMessage(e);
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

  // Fetch Preferred Time from API
  Future<void> fetchPreferredTime() async {
    isLoadingPreferredTime.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found for preferred time');
        isLoadingPreferredTime.value = false;
        return;
      }

      print('🌐 Making API request to: ${AppUrl.getPreferredTime}');

      final response = await _networkCaller.getRequest(
        AppUrl.getPreferredTime,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        final preferredTimeValue = attributes?['preferredTime'] ?? '';

        preferredTime.value = preferredTimeValue;
        print('✅ Preferred time fetched: $preferredTimeValue');

        // Cache the preferred time
        await CacheService.savePreferredTime(preferredTimeValue);
      } else {
        print('❌ Failed to fetch preferred time: ${response.errorMessage}');
        preferredTime.value = '';
      }
    } catch (e) {
      print('Error fetching preferred time: $e');
      preferredTime.value = '';
    } finally {
      isLoadingPreferredTime.value = false;
    }
  }

  // Load cached preferred time
  Future<void> loadCachedPreferredTime() async {
    final cachedTime = await CacheService.getPreferredTime();
    if (cachedTime != null && cachedTime.isNotEmpty) {
      preferredTime.value = cachedTime;
      print('📦 Loaded preferred time from cache: $cachedTime');
    }
  }

  Future<void> refreshData() async {
    print('🔄 Manual refresh triggered');
    isRefreshing.value = true;
    isNetworkError.value = false;
    isServerError.value = false;

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
        isNetworkError.value = false;
        isServerError.value = false;

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
      } else {
        if (response.statusCode == 502 || response.statusCode == 503 ||
            response.statusCode == 504 || response.statusCode == 500) {
          isServerError.value = true;
          isNetworkError.value = true;
          errorMessage.value = _getUserFriendlyErrorMessage(null, statusCode: response.statusCode);
        } else {
          errorMessage.value = response.errorMessage ?? 'Failed to refresh';
        }
      }

      // Also refresh preferred time
      await fetchPreferredTime();

    } on SocketException catch (e) {
      print('SocketException during refresh: $e');
      isNetworkError.value = true;
      errorMessage.value = _getUserFriendlyErrorMessage(e);
    } catch (e) {
      print('Refresh error: $e');
      errorMessage.value = _getUserFriendlyErrorMessage(e);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> retryFetch() async {
    print('🔄 Retry fetch triggered');
    isNetworkError.value = false;
    isServerError.value = false;
    errorMessage.value = '';
    await fetchPersonalInformation(showLoading: true);
    await fetchPreferredTime();
  }

  Future<void> forceRefresh() async {
    print('🔄 Force refresh - clearing cache');
    resetImageChanges();
    await CacheService.clearCache();
    await fetchPersonalInformation(showLoading: true);
    await fetchPreferredTime();

    userName.refresh();
    userEmail.refresh();
    userPhoneNumber.refresh();
    userAddress.refresh();
    userGender.refresh();
    userDateOfBirth.refresh();
    userAge.refresh();
    userProfileImage.refresh();
    isAccountSecondary.refresh();
    preferredTime.refresh();
  }

  Future<void> backgroundRefresh() async {
    print('🔄 Background refresh');
    await fetchPersonalInformation(background: true);
    await fetchPreferredTime();
  }

  // ==================== IMAGE PICKER WITH MIME TYPE VALIDATION ====================

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate image type
        final isValid = await _isValidImageFile(file);
        if (!isValid) {
          _showInvalidImageTypeAlert();
          return;
        }

        tempProfileImageFile.value = file;
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
        final file = File(image.path);

        // Validate image type
        final isValid = await _isValidImageFile(file);
        if (!isValid) {
          _showInvalidImageTypeAlert();
          return;
        }

        tempProfileImageFile.value = file;
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
        final imageUrl = await _imageUploadService
            .uploadProfileImage(tempProfileImageFile.value!);

        if (imageUrl != null) {
          final cleanedUrl = _getImageUrl(imageUrl);

          // Clear old cached image
          if (userProfileImage.value.isNotEmpty) {
            await CachedNetworkImage.evictFromCache(userProfileImage.value);
          }

          // Clear cache for new image
          await CachedNetworkImage.evictFromCache(cleanedUrl);

          userProfileImage.value = cleanedUrl;
          tempProfileImageFile.value = null;
          hasImageChanges.value = false;

          // Update cache with new image URL
          await CacheService.saveUserProfile({
            'name': userName.value,
            'email': userEmail.value,
            'phoneNumber': userPhoneNumber.value,
            'address': userAddress.value,
            'gender': userGender.value,
            'dateOfBirth': userDateOfBirth.value,
            'age': userAge.value,
            'profileImage': cleanedUrl,
            'isAccountSecondary': isAccountSecondary.value,
          });

          return cleanedUrl;
        }
        return null;
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to upload image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Supported formats: ${_allowedExtensions.join(', ').toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
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
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }

    // Clean spaces
    String cleanPath = imagePath.trim().replaceAll(RegExp(r'\s+'), '');

    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }

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