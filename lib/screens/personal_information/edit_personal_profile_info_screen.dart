/**

/// ===============================================================
/// EDIT PROFILE SCREEN
/// ===============================================================
library;

import 'package:askfemi/screens/personal_information/personal_profile_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../features/individual_user/widget/edit_update_button.dart';



class EditPersonalProfileInfoScreen extends StatefulWidget {
  const EditPersonalProfileInfoScreen({super.key});

  @override
  State<EditPersonalProfileInfoScreen> createState() => _EditPersonalProfileInfoScreenState();
}

class _EditPersonalProfileInfoScreenState extends State<EditPersonalProfileInfoScreen> {
  /// Controllers for all editable fields
  final nameController = TextEditingController(text: 'Rakibul');
  final emailController = TextEditingController(text: 'r@gmail.com');
  final phoneController = TextEditingController(text: '14164161631');
  final addressController = TextEditingController(text: 'USA');
  final genderController = TextEditingController(text: 'Male');
  final dobController = TextEditingController(text: '1.1.2025');
  final ageController = TextEditingController(text: '12');

  @override
  void dispose() {
    /// Always dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    genderController.dispose();
    dobController.dispose();
    ageController.dispose();
    super.dispose();
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
          /// Scrollable form
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
                      /// Profile avatar with edit icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [const ProfileAvatar(showEdit: true)],
                      ),
                      const SizedBox(height: 30),

                      /// Editable fields
                      LabeledTextField(
                        label: 'Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Email',
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Phone number',
                        controller: phoneController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Address',
                        controller: addressController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Gender',
                        controller: genderController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Date of Birth',
                        controller: dobController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(label: 'Age', controller: ageController),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Update button
          Padding(
            padding: const EdgeInsets.all(16),
            child: EditUpdateButton(
              title: 'Update Profile',
              onPressed: () {
                /// Handle update logic here
                Get.back();
              },
            ),
          ),
          const SizedBox(height: 20),
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
    return Stack(
      children: [
        const CircleAvatar(
          radius: 60,
          foregroundImage: AssetImage('assets/images/dummy_user_image.png'),
        ),

        /// Edit icon shown only in edit screen
        if (showEdit)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.pencil_circle_fill, size: 25, color: Colors.white),
            ),
          ),
      ],
    );
  }
}*/








// /// ===============================================================
// /// EDIT PROFILE SCREEN
// /// ===============================================================
// library;
//
// import 'package:askfemi/screens/personal_information/personal_Infromation_screen_controller.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../../../utils/app_colors.dart';
// import '../../../../../utils/app_texts_style.dart';
// import '../../../../../utils/network/app_url.dart';
// import '../../../../../utils/network/network_caller_dio.dart';
// import '../../../../../utils/network/network_response_dio.dart';
// import '../../../../../utils/network/secure_storage_service.dart';
// import '../../features/individual_user/widget/edit_update_button.dart';
//
// class EditPersonalProfileInfoScreen extends StatefulWidget {
//   const EditPersonalProfileInfoScreen({super.key});
//
//   @override
//   State<EditPersonalProfileInfoScreen> createState() => _EditPersonalProfileInfoScreenState();
// }
//
// class _EditPersonalProfileInfoScreenState extends State<EditPersonalProfileInfoScreen> {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//
//   /// Controllers for all editable fields
//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;
//   late TextEditingController genderController;
//   late TextEditingController dobController;
//   late TextEditingController ageController;
//
//   bool _isLoading = false;
//   bool _isUpdating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }
//
//   void _initializeControllers() {
//     // Get existing data from PersonalInformationController
//     final profileController = Get.isRegistered<PersonalInformationController>()
//         ? Get.find<PersonalInformationController>()
//         : Get.put(PersonalInformationController());
//
//     nameController = TextEditingController(text: profileController.userName.value);
//     emailController = TextEditingController(text: profileController.userEmail.value);
//     phoneController = TextEditingController(text: profileController.userPhoneNumber.value);
//     addressController = TextEditingController(text: profileController.userAddress.value);
//     genderController = TextEditingController(text: profileController.userGender.value);
//     dobController = TextEditingController(text: profileController.userDateOfBirth.value);
//     ageController = TextEditingController(text: profileController.userAge.value);
//   }
//
//   @override
//   void dispose() {
//     /// Always dispose controllers
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     addressController.dispose();
//     genderController.dispose();
//     dobController.dispose();
//     ageController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateProfile() async {
//     if (_isUpdating) return;
//
//     // Validate required fields
//     if (nameController.text.trim().isEmpty) {
//       _showErrorSnackbar('Name cannot be empty');
//       return;
//     }
//
//     if (phoneController.text.trim().isEmpty) {
//       _showErrorSnackbar('Phone number cannot be empty');
//       return;
//     }
//
//     setState(() {
//       _isUpdating = true;
//     });
//
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//
//       if (token == null) {
//         _showErrorSnackbar('No access token found');
//         return;
//       }
//
//       // Prepare data for API
//       final Map<String, dynamic> requestBody = {
//         "name": nameController.text.trim(),
//         "phoneNumber": phoneController.text.trim(),
//         "location": addressController.text.trim(),
//       };
//
//       print('📤 Updating profile with: $requestBody');
//
//       final response = await _networkCaller.putRequest(
//         AppUrl.updatePersonalInformation,
//         body: requestBody,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       print('📡 Response status: ${response.isSuccess}');
//
//       if (response.isSuccess) {
//         // Refresh the profile data in the controller
//         final profileController = Get.find<PersonalInformationController>();
//         await profileController.refreshData();
//
//         _showSuccessSnackbar('Profile updated successfully');
//
//         // Go back to profile screen
//         Get.back();
//       } else {
//         _showErrorSnackbar(response.errorMessage ?? 'Failed to update profile');
//       }
//     } catch (e) {
//       print('Error updating profile: $e');
//       _showErrorSnackbar('An error occurred: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUpdating = false;
//         });
//       }
//     }
//   }
//
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         surfaceTintColor: AppColors.transparent,
//         backgroundColor: AppColors.white,
//         elevation: 0,
//         title: Text('Edit Profile', style: AppTextStyles.largeHeading),
//       ),
//       body: Column(
//         children: [
//           /// Scrollable form
//           Expanded(
//             child: SingleChildScrollView(
//               child: Card(
//                 color: AppColors.backgroundColor,
//                 margin: const EdgeInsets.all(16),
//                 elevation: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       /// Profile avatar with edit icon
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: const [ProfileAvatar(showEdit: true)],
//                       ),
//                       const SizedBox(height: 30),
//
//                       /// Editable fields
//                       LabeledTextField(
//                         label: 'Name',
//                         controller: nameController,
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Email',
//                         controller: emailController,
//                         enabled: false, // Email usually not editable
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Phone number',
//                         controller: phoneController,
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Address',
//                         controller: addressController,
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Gender',
//                         controller: genderController,
//                         enabled: false, // Gender might not be editable
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Date of Birth',
//                         controller: dobController,
//                         enabled: false, // DOB usually not editable
//                       ),
//                       const SizedBox(height: 16),
//
//                       LabeledTextField(
//                         label: 'Age',
//                         controller: ageController,
//                         enabled: false, // Age auto-calculated from DOB
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           /// Update button with loading state
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: _isUpdating
//                 ? const Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primaryColor,
//               ),
//             )
//                 : EditUpdateButton(
//               title: 'Update Profile',
//               onPressed: _updateProfile,
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
//
// /// ----------------------------
// /// LABELED TEXT FIELD (EDIT MODE)
// /// ----------------------------
// class LabeledTextField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final bool enabled;
//   final TextInputType keyboardType;
//
//   const LabeledTextField({
//     super.key,
//     required this.label,
//     required this.controller,
//     this.enabled = true,
//     this.keyboardType = TextInputType.text,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.black.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: AppTextStyles.smallText.copyWith(
//               color: AppColors.black.withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             enabled: enabled,
//             keyboardType: keyboardType,
//             style: AppTextStyles.defaultTextStyle.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//             decoration: const InputDecoration(
//               isDense: true,
//               border: InputBorder.none,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ----------------------------
// /// PROFILE AVATAR WIDGET
// /// ----------------------------
// class ProfileAvatar extends StatelessWidget {
//   final bool showEdit;
//
//   const ProfileAvatar({super.key, this.showEdit = false});
//
//   @override
//   Widget build(BuildContext context) {
//     // Get profile image from controller
//     final profileController = Get.isRegistered<PersonalInformationController>()
//         ? Get.find<PersonalInformationController>()
//         : null;
//
//     final imageUrl = profileController?.userProfileImage.value ?? '';
//
//     return Stack(
//       children: [
//         CircleAvatar(
//           radius: 60,
//           backgroundImage: imageUrl.isNotEmpty && imageUrl.startsWith('http')
//               ? NetworkImage(imageUrl)
//               : const AssetImage('assets/images/dummy_user_image.png') as ImageProvider,
//           onBackgroundImageError: (_, __) {},
//         ),
//         /// Edit icon shown only in edit screen
//         if (showEdit)
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: GestureDetector(
//               onTap: () {
//                 // TODO: Implement image picker functionality
//                 print('Edit profile image tapped');
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(5),
//                 decoration: const BoxDecoration(
//                   color: AppColors.primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(CupertinoIcons.pencil_circle_fill, size: 25, color: Colors.white),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }






/// ===============================================================
/// EDIT PROFILE SCREEN
/// ===============================================================
library;

import 'package:askfemi/screens/personal_information/personal_Infromation_screen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_texts_style.dart';
import '../../../../../utils/network/app_url.dart';
import '../../../../../utils/network/network_caller_dio.dart';
import '../../../../../utils/network/network_response_dio.dart';
import '../../../../../utils/network/secure_storage_service.dart';
import '../../features/individual_user/widget/edit_update_button.dart';

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
    // Get existing data from PersonalInformationController
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
    /// Always dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    genderController.dispose();
    dobController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // Future<void> _updateProfile() async {
  //   if (_isUpdating) return;
  //
  //   // Validate required fields
  //   if (nameController.text.trim().isEmpty) {
  //     _showErrorSnackbar('Name cannot be empty');
  //     return;
  //   }
  //
  //   if (phoneController.text.trim().isEmpty) {
  //     _showErrorSnackbar('Phone number cannot be empty');
  //     return;
  //   }
  //
  //   setState(() {
  //     _isUpdating = true;
  //   });
  //
  //   try {
  //     final token = await SecureStorageService.instance.getAccessToken();
  //
  //     if (token == null) {
  //       _showErrorSnackbar('No access token found');
  //       return;
  //     }
  //
  //     // Prepare data for API - address field should be sent as 'location'
  //     final Map<String, dynamic> requestBody = {
  //       "name": nameController.text.trim(),
  //       "phoneNumber": phoneController.text.trim(),
  //       "location": addressController.text.trim(),  // ← FIXED: address -> location
  //     };
  //
  //     print('📤 Updating profile with: $requestBody');
  //
  //     final response = await _networkCaller.putRequest(
  //       AppUrl.updatePersonalInformation,
  //       body: requestBody,
  //       headers: {'Authorization': 'Bearer $token'},
  //     );
  //
  //     print('📡 Response status: ${response.isSuccess}');
  //     print('📡 Response body: ${response.jsonResponse}');
  //
  //     if (response.isSuccess) {
  //       // Refresh the profile data in the controller
  //       final profileController = Get.find<PersonalInformationController>();
  //       await profileController.refreshData();
  //
  //       _showSuccessSnackbar('Profile updated successfully');
  //
  //       // Go back to profile screen
  //       Get.back();
  //     } else {
  //       _showErrorSnackbar(response.errorMessage ?? 'Failed to update profile');
  //     }
  //   } catch (e) {
  //     print('Error updating profile: $e');
  //     _showErrorSnackbar('An error occurred: ${e.toString()}');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isUpdating = false;
  //       });
  //     }
  //   }
  // }



  Future<void> _updateProfile() async {
    if (_isUpdating) return;

    // Validate required fields
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
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        _showErrorSnackbar('No access token found');
        return;
      }

      // Option 1: Try with 'location'
      final Map<String, dynamic> requestBody = {
        "name": nameController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        "location": addressController.text.trim(),
      };

      // Option 2: If above doesn't work, try with 'address'
      // final Map<String, dynamic> requestBody = {
      //   "name": nameController.text.trim(),
      //   "phoneNumber": phoneController.text.trim(),
      //   "address": addressController.text.trim(),
      // };

      // Option 3: Try with nested profileId object
      // final Map<String, dynamic> requestBody = {
      //   "name": nameController.text.trim(),
      //   "phoneNumber": phoneController.text.trim(),
      //   "profileId": {
      //     "location": addressController.text.trim(),
      //   }
      // };

      print('📤 Updating profile with: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.updatePersonalInformation,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response: ${response.statusCode} - ${response.jsonResponse}');

      if (response.isSuccess) {
        final profileController = Get.find<PersonalInformationController>();
        await profileController.refreshData();

        _showSuccessSnackbar('Profile updated successfully');
        Get.back();
      } else {
        _showErrorSnackbar(response.errorMessage ?? 'Failed to update profile');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackbar('Error: ${e.toString()}');
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
        duration: const Duration(seconds: 2),
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
          /// Scrollable form
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
                      /// Profile avatar with edit icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [ProfileAvatar(showEdit: true)],
                      ),
                      const SizedBox(height: 30),

                      /// Editable fields
                      LabeledTextField(
                        label: 'Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),

                      LabeledTextField(
                        label: 'Email',
                        controller: emailController,
                        enabled: false, // Email usually not editable
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

          /// Update button with loading state
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
    // Get profile image from controller
    final profileController = Get.isRegistered<PersonalInformationController>()
        ? Get.find<PersonalInformationController>()
        : null;

    final imageUrl = profileController?.userProfileImage.value ?? '';

    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageUrl.isNotEmpty && imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/dummy_user_image.png') as ImageProvider,
          onBackgroundImageError: (_, __) {},
        ),
        /// Edit icon shown only in edit screen
        if (showEdit)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement image picker functionality
                print('Edit profile image tapped');
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.pencil_circle_fill, size: 25, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}