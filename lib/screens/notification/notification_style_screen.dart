import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_texts_style.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class NotificationStyleScreen extends StatefulWidget {
  const NotificationStyleScreen({super.key});

  @override
  State<NotificationStyleScreen> createState() =>
      _NotificationStyleScreenState();
}

class _NotificationStyleScreenState extends State<NotificationStyleScreen> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  String _selectedOption = 'gentle';
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _fetchNotificationStyle();
  }

  Future<void> _fetchNotificationStyle() async {
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
        AppUrl.getNotificationStyle,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 GET Response status code: ${response.statusCode}');
      print('📡 GET Response success: ${response.isSuccess}');
      print('📡 GET Response body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final attributes = response.jsonResponse?['data']?['attributes'];
        if (attributes != null) {
          final notificationStyle = attributes['notificationStyle'] ?? 'gentle';
          setState(() {
            _selectedOption = notificationStyle;
            _isLoading = false;
          });

          // Auto-play the current selected sound when screen opens (if not silent)
          if (_selectedOption != 'silent') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _playSampleSound(_selectedOption);
            });
          }
        } else {
          setState(() {
            _errorMessage = 'No data found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load notification style';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notification style: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationStyle() async {
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
        "notificationStyle": _selectedOption,
      };

      print('📤 PUT Request - Saving notification style: $requestBody');

      final response = await _networkCaller.putRequest(
        AppUrl.updateNotificationStyle,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 PUT Response status code: ${response.statusCode}');
      print('📡 PUT Response success: ${response.isSuccess}');
      print('📡 PUT Response body: ${response.jsonResponse}');

      if (response.isSuccess || response.statusCode == 200) {
        _showSuccessSnackbar('Notification style saved successfully');
        Navigator.pop(context, _selectedOption);
      } else {
        String error = response.errorMessage ?? 'Failed to save notification style';
        if (response.jsonResponse != null) {
          error = response.jsonResponse?['message'] ?? error;
        }
        _showErrorSnackbar(error);
      }
    } catch (e) {
      print('Error saving notification style: $e');
      _showErrorSnackbar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
        debugPrint('🎵 Player state: $state');
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        debugPrint('✅ Sound finished playing');
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _selectOption(String option) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    }

    setState(() {
      _selectedOption = option;
    });

    if (option == 'gentle' || option == 'firm') {
      await _playSampleSound(option);
    }
  }

  Future<void> _playSampleSound(String option) async {
    try {
      setState(() {
        _isPlaying = true;
      });

      await _audioPlayer.stop();

      String soundPath;
      if (option == 'gentle') {
        soundPath = 'tune/gentle_notification.mp3';
      } else {
        soundPath = 'tune/firm_notification.mp3';
      }

      debugPrint('🎵 Attempting to play: $soundPath');

      await _audioPlayer.play(
        AssetSource(soundPath),
        volume: 1.0,
      );

      debugPrint('✅ Play command executed successfully');

    } catch (e) {
      debugPrint('❌ Error playing sound: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio file not found: $e'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red[700],
          ),
        );
      }
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
              onPressed: _fetchNotificationStyle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SafeArea(
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
                  // Header with icon and title
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

                  // Option Tiles
                  _buildOptionTile(
                    key: 'gentle',
                    title: 'Gentle',
                    subtitle: 'Soft and non-intrusive • Tap to hear sample',
                    isSelected: _selectedOption == 'gentle',
                    isPlaying: _isPlaying && _selectedOption == 'gentle',
                    onTap: () => _selectOption('gentle'),
                  ),
                  const SizedBox(height: 16),

                  _buildOptionTile(
                    key: 'firm',
                    title: 'Firm',
                    subtitle: 'Clear and noticeable • Tap to hear sample',
                    isSelected: _selectedOption == 'firm',
                    isPlaying: _isPlaying && _selectedOption == 'firm',
                    onTap: () => _selectOption('firm'),
                  ),
                  const SizedBox(height: 16),

                  _buildOptionTile(
                    key: 'silent',
                    title: 'Silent',
                    subtitle: 'Notification will not be provided',
                    isSelected: _selectedOption == 'silent',
                    isPlaying: false,
                    onTap: () => _selectOption('silent'),
                  ),

                  // Save button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveNotificationStyle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : const Text(
                        'Save Preference',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
    required bool isPlaying,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.0),
          color: isSelected ? AppColors.lightBlueColor : Colors.white,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Dynamic icon based on selection and playing state
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isPlaying
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                )
                    : Icon(
                  key == 'gentle'
                      ? Icons.volume_down
                      : key == 'firm'
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color: isSelected ? AppColors.primaryColor : Colors.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.smallHeading.copyWith(
                          fontSize: 16,
                          color: isSelected ? AppColors.primaryColor : null,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isPlaying) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Playing...',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 12),
            // // Custom toggle indicator (replaces radio button)
            // AnimatedContainer(
            //   duration: const Duration(milliseconds: 200),
            //   width: 44,
            //   height: 24,
            //   decoration: BoxDecoration(
            //     color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Stack(
            //     children: [
            //       AnimatedPositioned(
            //         duration: const Duration(milliseconds: 200),
            //         top: 2,
            //         left: isSelected ? 22 : 2,
            //         child: Container(
            //           width: 20,
            //           height: 20,
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             shape: BoxShape.circle,
            //             boxShadow: [
            //               BoxShadow(
            //                 color: Colors.black.withOpacity(0.1),
            //                 blurRadius: 2,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}