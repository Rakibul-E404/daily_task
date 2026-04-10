import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import 'controller/settings_screen_controller.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final SettingsScreenController _controller = Get.put(SettingsScreenController());

  String _email = '';
  String _phoneNumber = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchContactInfo();
  }

  Future<void> _fetchContactInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final data = await _controller.fetchSettingsData('contactUs');

    if (data != null) {
      final details = data['details'];
      setState(() {
        _email = details?['email'] ?? '';
        _phoneNumber = details?['phoneNumber'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = _controller.errorMessage.value.isNotEmpty
            ? _controller.errorMessage.value
            : 'Failed to load contact information';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String type) {
    // Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Contact Us', style: AppTextStyles.smallHeading),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchContactInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Center(
        child: Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Section
              InkWell(
                onTap: _email.isNotEmpty
                    ? () => _copyToClipboard(_email, 'Email')
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryColor,
                        child: const Icon(Icons.email_outlined, color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _email.isNotEmpty ? _email : 'Not available',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          fontSize: 18,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.primaryColor),
              // Phone Section
              InkWell(
                onTap: _phoneNumber.isNotEmpty
                    ? () => _copyToClipboard(_phoneNumber, 'Phone number')
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryColor,
                        child: const Icon(Icons.phone, color: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _phoneNumber.isNotEmpty ? _phoneNumber : 'Not available',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.defaultTextStyle.copyWith(
                          fontSize: 18,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}