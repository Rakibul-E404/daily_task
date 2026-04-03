// personal_information_controller.dart
import 'package:get/get.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/network_response_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';

class PersonalInformationController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Reactive variables
  var isLoading = false.obs;
  var errorMessage = RxString('');

  // User data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhoneNumber = ''.obs;
  var userAddress = ''.obs;
  var userGender = ''.obs;
  var userDateOfBirth = ''.obs;
  var userAge = ''.obs;
  var userProfileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPersonalInformation();
  }

  Future<void> fetchPersonalInformation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        print('No access token found');
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getPersonalInformation,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];

        if (attributes != null) {
          // Set basic user info
          userName.value = attributes['name'] ?? '';
          userEmail.value = attributes['email'] ?? '';
          userPhoneNumber.value = attributes['phoneNumber'] ?? '';

          // Get profile image URL
          final profileImage = attributes['profileImage'];
          if (profileImage != null && profileImage['imageUrl'] != null) {
            userProfileImage.value = _getImageUrl(profileImage['imageUrl']);
          }

          // Get profile details
          final profileId = attributes['profileId'];
          if (profileId != null) {
            userAddress.value = profileId['location'] ?? '';
            userGender.value = _formatGender(profileId['gender'] ?? '');
            userDateOfBirth.value = _formatDate(profileId['dob'] ?? '');
            userAge.value = _calculateAge(profileId['dob'] ?? '');
          }
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load data';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error fetching personal information: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get full image URL
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return "assets/images/dummy_user_image.png";
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

  // Format gender
  String _formatGender(String gender) {
    if (gender.isEmpty) return 'Not specified';
    return gender[0].toUpperCase() + gender.substring(1).toLowerCase();
  }

  // Format date from ISO string to readable format
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Not specified';
    }
  }

  // Calculate age from date of birth
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

  // // Refresh data
  // Future<void> refreshData() async {
  //   await fetchPersonalInformation();
  // }
}