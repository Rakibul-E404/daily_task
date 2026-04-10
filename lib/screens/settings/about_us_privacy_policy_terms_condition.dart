/**
    import 'package:flutter/material.dart';
    import '../../../../utils/app_colors.dart';
    import '../../../../utils/app_texts_style.dart';
    import '../../../../utils/static_text.dart';

    class AboutUsPrivacyPolicyTermsConditionScreen extends StatelessWidget {
    const AboutUsPrivacyPolicyTermsConditionScreen({
    super.key,
    required this.pageTitle,
    required this.content,
    });

    final String pageTitle;
    final String content;

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(

    leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
    onPressed: () => Navigator.pop(context),
    ),
    title: Text(pageTitle, style: AppTextStyles.smallHeading),
    backgroundColor: AppColors.white,
    surfaceTintColor: AppColors.transparent,
    elevation: 0,
    ),
    body: SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text("Last Update Feb 2026",style: AppTextStyles.smallText.copyWith(
    color: AppColors.textColorBlue,fontSize: 14
    ),),
    const SizedBox(height: 12),
    Text(pageTitle, style: AppTextStyles.smallHeading),
    SingleChildScrollView(
    child: SizedBox(
    width: MediaQuery.of(context).size.width *
    2,
    child: Text(
    content,
    textAlign: TextAlign.justify, // 👈 justify both sides
    style: AppTextStyles.defaultTextStyle.copyWith(
    height: 1.6,
    color: AppColors.black,
    ),
    ),
    ),
    ),
    const SizedBox(height: 12),
    ],
    ),
    ),
    ),
    );
    }
    }
 */

// about_us_privacy_policy_terms_condition_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import 'controller/settings_screen_controller.dart';

class AboutUsPrivacyPolicyTermsConditionScreen extends StatefulWidget {
  final String pageTitle;
  final String type; // 'aboutUs', 'privacyPolicy', 'termsAndConditions'

  const AboutUsPrivacyPolicyTermsConditionScreen({
    super.key,
    required this.pageTitle,
    required this.type,
  });

  @override
  State<AboutUsPrivacyPolicyTermsConditionScreen> createState() =>
      _AboutUsPrivacyPolicyTermsConditionScreenState();
}

class _AboutUsPrivacyPolicyTermsConditionScreenState
    extends State<AboutUsPrivacyPolicyTermsConditionScreen> {
  final SettingsScreenController _controller = Get.put(
    SettingsScreenController(),
  );

  String _content = '';
  String _lastUpdated = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final data = await _controller.fetchSettingsData(widget.type);

    if (data != null) {
      setState(() {
        _content = data['details'] ?? '';
        _lastUpdated = _formatDate(data['updatedAt'] ?? '');
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = _controller.errorMessage.value.isNotEmpty
            ? _controller.errorMessage.value
            : 'Failed to load data';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return 'Last Updated ${_getMonthAbbr(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return '';
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.pageTitle, style: AppTextStyles.smallHeading),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
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
                    onPressed: _fetchData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_lastUpdated.isNotEmpty)
                    Text(
                      _lastUpdated,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textColorBlue,
                        fontSize: 14,
                      ),
                    ),
                  if (_lastUpdated.isNotEmpty) const SizedBox(height: 12),
                  HtmlWidget(htmlContent: _content),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }
}

// Custom HTML Widget to render HTML content
class HtmlWidget extends StatelessWidget {
  final String htmlContent;

  const HtmlWidget({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    // Remove HTML tags and convert to plain text
    String plainText = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");

    return Text(
      plainText,
      textAlign: TextAlign.justify,
      style: AppTextStyles.defaultTextStyle.copyWith(
        height: 1.6,
        color: AppColors.black,
      ),
    );
  }
}
