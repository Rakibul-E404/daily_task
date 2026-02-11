import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';

class NotificationStyleScreen extends StatefulWidget {
  const NotificationStyleScreen({super.key});

  @override
  State<NotificationStyleScreen> createState() =>
      _NotificationStyleScreenState();
}

class _NotificationStyleScreenState extends State<NotificationStyleScreen> {
  String? _selectedOption; // null = none selected; values: 'gentle', 'firm', 'xyz'

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notification Style', style: AppTextStyles.smallHeading),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/notification_square.svg",
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification Style',
                              style: AppTextStyles.defaultTextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'How reminders should feel',
                              style: AppTextStyles.defaultTextStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildOptionTile(
                    key: 'gentle',
                    title: 'Gentle',
                    subtitle: 'Soft and non - intrusive',
                    isSelected: _selectedOption == 'gentle',
                    onTap: () => _selectOption('gentle'),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    key: 'firm',
                    title: 'Firm',
                    subtitle: 'Soft and non - intrusive',
                    isSelected: _selectedOption == 'firm',
                    onTap: () => _selectOption('firm'),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    key: 'xyz',
                    title: 'XYZ',
                    subtitle: 'Soft and non - intrusive',
                    isSelected: _selectedOption == 'xyz',
                    onTap: () => _selectOption('xyz'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String key,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
          color: isSelected ? AppColors.lightBlueColor : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.grey, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.smallHeading.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Custom swappable toggle indicator (not a Switch — just visual)
            Container(
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 1,
                    left: isSelected ? 19 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.lightGrey, blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}