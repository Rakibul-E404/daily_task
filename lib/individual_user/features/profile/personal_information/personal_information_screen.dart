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
        title:  Text(
          'Personal Information',
          style: AppTextStyles.largeHeading,
        ),
      ),
      body: Container(
        color: AppColors.white, // Light grey background
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
                    
                    // Profiel Image 
                    CircleAvatar(
                      radius: 60,
                      foregroundImage: AssetImage("assets/images/dummy_user_image.png"),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5), // Blue color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:  Text(
                  'Edit Profile',
                  style: AppTextStyles.defaultTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,)
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
          style: AppTextStyles.smallText.copyWith(
            color: AppColors.black
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.defaultTextStyle.copyWith(
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}