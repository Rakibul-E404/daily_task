// import 'package:askfemi/utils/app_colors.dart';
// import 'package:askfemi/utils/app_texts.dart';
// import 'package:flutter/material.dart';
//
// class PersonalInformationScreen extends StatelessWidget {
//   const PersonalInformationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//         title: Text(
//           'Personal Information',
//           style: AppTextStyles.largeHeading,
//         ),
//       ),
//       body: Container(
//         color: AppColors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile information card
//             Card(
//               color: AppColors.backgroundColor,
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               elevation: 1,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Profile Image
//                     CircleAvatar(
//                       radius: 60,
//                       foregroundImage:
//                       AssetImage("assets/images/dummy_user_image.png"),
//                     ),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     // Name
//                     _buildInfoRow('Name', 'Rakibul'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Email
//                     _buildInfoRow('Email', 'r@gmail.com'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Phone number
//                     _buildInfoRow('Phone number', '14164161631'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Address
//                     _buildInfoRow('Address', 'USA'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Gender
//                     _buildInfoRow('Gender', 'Male'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Date of Birth
//                     _buildInfoRow('Date of Birth', '1.1.2025'),
//
//                     const Divider(height: 24, thickness: 1),
//
//                     // Age
//                     _buildInfoRow('Age', '12'),
//                   ],
//                 ),
//               ),
//             ),
//
//             const Spacer(),
//
//             // Edit Profile Button
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => EditProfileScreen(),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1E88E5),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Edit Profile',
//                   style: AppTextStyles.defaultTextStyle.copyWith(
//                       fontWeight: FontWeight.bold, color: AppColors.white),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.smallText.copyWith(color: AppColors.black),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: AppTextStyles.defaultTextStyle
//               .copyWith(fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   // Controllers for text fields
//   final TextEditingController nameController =
//   TextEditingController(text: 'Rakibul');
//   final TextEditingController emailController =
//   TextEditingController(text: 'r@gmail.com');
//   final TextEditingController phoneController =
//   TextEditingController(text: '14164161631');
//   final TextEditingController addressController =
//   TextEditingController(text: 'USA');
//   final TextEditingController genderController =
//   TextEditingController(text: 'Male');
//   final TextEditingController dobController =
//   TextEditingController(text: '1.1.2025');
//   final TextEditingController ageController = TextEditingController(text: '12');
//
//   @override
//   void dispose() {
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//         title: Text(
//           'Edit Profile',
//           style: AppTextStyles.largeHeading,
//         ),
//       ),
//       body: Container(
//         color: AppColors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile information card
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Card(
//                   color: AppColors.backgroundColor,
//                   margin:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   elevation: 1,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Profile Image with edit icon
//                         Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 60,
//                               foregroundImage: AssetImage(
//                                   "assets/images/dummy_user_image.png"),
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 padding: EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF1E88E5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.edit,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 30),
//
//                         // Name
//                         _buildEditableField('Name', nameController),
//
//                         const SizedBox(height: 16),
//
//                         // Email
//                         _buildEditableField('Email', emailController),
//
//                         const SizedBox(height: 16),
//
//                         // Phone number
//                         _buildEditableField('Phone number', phoneController),
//
//                         const SizedBox(height: 16),
//
//                         // Address
//                         _buildEditableField('Address', addressController),
//
//                         const SizedBox(height: 16),
//
//                         // Gender
//                         _buildEditableField('Gender', genderController),
//
//                         const SizedBox(height: 16),
//
//                         // Date of Birth
//                         _buildEditableField('Date of Birth', dobController),
//
//                         const SizedBox(height: 16),
//
//                         // Age
//                         _buildEditableField('Age', ageController),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Update Profile Button
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Handle profile update
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1E88E5),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Update Profile',
//                   style: AppTextStyles.defaultTextStyle.copyWith(
//                       fontWeight: FontWeight.bold, color: AppColors.white),
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEditableField(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.smallText.copyWith(
//             color: AppColors.black.withOpacity(0.6),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           style: AppTextStyles.defaultTextStyle.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: AppColors.white,
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                 color: AppColors.black.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                 color: AppColors.black.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(
//                 color: const Color(0xFF1E88E5),
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:askfemi/utils/app_colors.dart';
import 'package:askfemi/utils/app_texts.dart';
import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Personal Information',
          style: AppTextStyles.largeHeading,
        ),
      ),
      body: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile information card
            Card(
              color: AppColors.backgroundColor,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 60,
                      foregroundImage:
                      AssetImage("assets/images/dummy_user_image.png"),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // Name
                    _buildInfoRow('Name', 'Rakibul'),

                    const Divider(height: 24, thickness: 1),

                    // Email
                    _buildInfoRow('Email', 'r@gmail.com'),

                    const Divider(height: 24, thickness: 1),

                    // Phone number
                    _buildInfoRow('Phone number', '14164161631'),

                    const Divider(height: 24, thickness: 1),

                    // Address
                    _buildInfoRow('Address', 'USA'),

                    const Divider(height: 24, thickness: 1),

                    // Gender
                    _buildInfoRow('Gender', 'Male'),

                    const Divider(height: 24, thickness: 1),

                    // Date of Birth
                    _buildInfoRow('Date of Birth', '1.1.2025'),

                    const Divider(height: 24, thickness: 1),

                    // Age
                    _buildInfoRow('Age', '12'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Edit Profile Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: AppTextStyles.defaultTextStyle.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.smallText.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.defaultTextStyle
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for text fields
  final TextEditingController nameController =
  TextEditingController(text: 'Rakibul');
  final TextEditingController emailController =
  TextEditingController(text: 'r@gmail.com');
  final TextEditingController phoneController =
  TextEditingController(text: '14164161631');
  final TextEditingController addressController =
  TextEditingController(text: 'USA');
  final TextEditingController genderController =
  TextEditingController(text: 'Male');
  final TextEditingController dobController =
  TextEditingController(text: '1.1.2025');
  final TextEditingController ageController =
  TextEditingController(text: '12');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text(
          'Edit Profile',
          style: AppTextStyles.largeHeading,
        ),
      ),
      body: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile information card
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: AppColors.backgroundColor,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image with edit icon
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              foregroundImage: AssetImage(
                                  "assets/images/dummy_user_image.png"),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E88E5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // Name - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nameController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Email - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: emailController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Phone number - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone number',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: phoneController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Address - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: addressController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gender - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: genderController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Date of Birth - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date of Birth',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: dobController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Age - UPDATED: White container covering both label and field
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.black.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Age',
                                style: AppTextStyles.smallText.copyWith(
                                  color: AppColors.black.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: ageController,
                                style: AppTextStyles.defaultTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Update Profile Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle profile update
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Update Profile',
                  style: AppTextStyles.defaultTextStyle.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}