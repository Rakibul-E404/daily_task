import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';
import '../bottom_navigation/main_bottom_nav.dart';

class ChooseSupportModeScreen extends StatefulWidget {
  final bool fromProfile;

  const ChooseSupportModeScreen({
    super.key,
    this.fromProfile = false,
  });

  @override
  State<ChooseSupportModeScreen> createState() =>
      _ChooseSupportModeScreenState();
}

class _ChooseSupportModeScreenState extends State<ChooseSupportModeScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  String? selectedMode;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSupportMode();
  }

  Future<void> _fetchSupportMode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        setState(() {
          _errorMessage = 'No access token found';
          _isLoading = false;
        });
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getSupportMode,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 GET Response status code: ${response.statusCode}');
      print('📡 GET Response success: ${response.isSuccess}');
      print('📡 GET Response body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final supportMode = attributes['supportMode'] ?? 'calm';
          setState(() {
            selectedMode = supportMode;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No data found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load support mode';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching support mode: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSupportMode() async {
    if (selectedMode == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        _showErrorSnackbar('No access token found. Please login again.');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final Map<String, dynamic> requestBody = {
        "supportMode": selectedMode,
      };

      print('📤 PUT Request - Saving support mode: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.updateSupportMode,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 PUT Response status code: ${response.statusCode}');
      print('📡 PUT Response success: ${response.isSuccess}');
      print('📡 PUT Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        _showSuccessSnackbar('Support mode saved successfully');

        if (widget.fromProfile) {
          Navigator.pop(context);
        } else {
          Get.offAll(const MainBottomNav());
        }
      } else {
        String error = response.errorMessage ?? 'Failed to save support mode';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        _showErrorSnackbar(error);
      }
    } catch (e) {
      print('Error saving support mode: $e');
      _showErrorSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isSaving = false;
      });
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        title: widget.fromProfile ?
        Text("Support Mode",style: AppTextStyles.largeHeading,) : null,
        leading: widget.fromProfile ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ) : null,
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
              onPressed: _fetchSupportMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            if (!widget.fromProfile) const SizedBox(height: 60),

            // Title
            if (!widget.fromProfile)
              const Text(
                'Choose Your Support Style',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 12),

            // Subtitle
            if (!widget.fromProfile)
              Text(
                'How would you like Clarity to communicate with you?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 40),

            // Support Style Cards
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSupportCard(
                      mode: 'calm',
                      icon: SvgPicture.asset(
                        'assets/images/clam.svg',
                        width: 35,
                        height: 35,
                      ),
                      title: 'Calm',
                      description:
                      'Gentle guidance with peaceful reminders and soothing encouragement.',
                      quote: '"Take your time. Each small step matters."',
                      isSelected: selectedMode == 'calm',
                    ),
                    const SizedBox(height: 16),
                    _buildSupportCard(
                      mode: 'encouraging',
                      icon: SvgPicture.asset(
                        'assets/images/encouraging.svg',
                        width: 35,
                        height: 35,
                      ),
                      title: 'Encouraging',
                      description:
                      'Positive energy with motivational reminders and uplifting support.',
                      quote: '"You\'re doing great! Keep up the momentum!"',
                      isSelected: selectedMode == 'encouraging',
                    ),
                    const SizedBox(height: 16),
                    _buildSupportCard(
                      mode: 'logical',
                      icon: SvgPicture.asset(
                        'assets/images/logical.svg',
                        width: 35,
                        height: 35,
                      ),
                      title: 'Logical',
                      description:
                      'Clear, structured guidance with practical advice and actionable steps.',
                      quote: null,
                      isSelected: selectedMode == 'logical',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Button based on navigation source
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (selectedMode != null && !_isSaving)
                    ? _saveSupportMode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  widget.fromProfile ? 'Save Changes' : 'Get Started',
                  style: AppTextStyles.smallHeading.copyWith(
                    color: selectedMode != null ? AppColors.white : AppColors.lightGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String mode,
    required Widget icon,
    required String title,
    required String description,
    String? quote,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectionFillColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title Row
            Row(
              children: [
                // Icon Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getEmojiBackgroundColor(mode),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: icon),
                ),
                const SizedBox(width: 12),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),

            // Quote (if available)
            if (quote != null) ...[
              const SizedBox(height: 12),
              Text(
                quote,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEmojiBackgroundColor(String mode) {
    switch (mode) {
      case 'calm':
        return AppColors.calmColor;
      case 'encouraging':
        return AppColors.encouragingColor;
      case 'logical':
        return AppColors.logicalColor;
      default:
        return AppColors.grey;
    }
  }
}