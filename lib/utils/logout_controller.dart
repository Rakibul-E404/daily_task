// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../utils/network/app_url.dart';
// import '../../../../utils/network/network_caller_dio.dart';
// import '../../../../utils/network/secure_storage_service.dart';
// import '../../../../utils/temp/cache.dart';
// import '../../../auth/sign_in/singn_in_screen.dart';
//
// class LogoutController extends GetxController {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//
//   var isLoading = false.obs;
//   var errorMessage = RxString('');
//
//   Future<void> logout() async {
//     if (isLoading.value) return;
//
//     isLoading.value = true;
//     errorMessage.value = '';
//
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//
//       if (token == null) {
//         // If no token, just clear local data and navigate to login
//         await _clearLocalDataAndNavigate();
//         return;
//       }
//
//       print('🌐 Making POST request to: ${AppUrl.logOut}');
//
//       final response = await _networkCaller.postRequest(
//         AppUrl.logOut,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       print('📡 Response status code: ${response.statusCode}');
//       print('📡 Response success: ${response.isSuccess}');
//
//       if (response.isSuccess) {
//         await _clearLocalDataAndNavigate();
//       } else {
//         errorMessage.value = response.errorMessage ?? 'Failed to logout';
//         Get.snackbar(
//           'Error',
//           errorMessage.value,
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         isLoading.value = false;
//       }
//     } catch (e) {
//       print('Error during logout: $e');
//       errorMessage.value = 'An error occurred. Please try again.';
//       Get.snackbar(
//         'Error',
//         errorMessage.value,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _clearLocalDataAndNavigate() async {
//     try {
//       await SecureStorageService.instance.clearAll();
//       await CacheService.clearCache();
//
//       Get.offAll(() =>  SignInScreen());
//     } catch (e) {
//       print('Error clearing local data: $e');
//       // Even if there's an error, try to navigate
//       Get.offAll(() =>  SignInScreen());
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }