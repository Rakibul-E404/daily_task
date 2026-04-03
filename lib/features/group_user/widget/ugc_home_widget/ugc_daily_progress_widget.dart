import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/network_response_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class DailyProgressData {
  final int completed;
  final int total;
  final double percentage;
  final String message;
  final int pending;
  final int inProgress;
  final int remaining;

  DailyProgressData({
    required this.completed,
    required this.total,
    required this.percentage,
    required this.message,
    required this.pending,
    required this.inProgress,
    required this.remaining,
  });

  factory DailyProgressData.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] ?? {};
    final statistics = json['statistics'] ?? {};

    return DailyProgressData(
      completed: progress['completed'] ?? 0,
      total: progress['total'] ?? 0,
      percentage: (progress['percentage'] ?? 0).toDouble(),
      message: json['message'] ?? 'No tasks yet',
      pending: statistics['pending'] ?? 0,
      inProgress: statistics['inProgress'] ?? 0,
      remaining: statistics['remaining'] ?? 0,
    );
  }
}

Widget ugcBuildDailyProgress(DailyProgressData data, double screenWidth) {
  return Card(
    color: AppColors.white,
    elevation: 1,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              Chip(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.012,
                  vertical: 0,
                ),
                label: Text(
                  '${data.completed} / ${data.total}',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: screenWidth * 0.03,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.mainBottomNavColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                ),
                side: const BorderSide(width: 0, color: Colors.transparent),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: data.percentage / 100, // Convert percentage to 0-1
                  backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.005),
                  minHeight: screenWidth * 0.03,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            data.message,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppColors.grey,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    ),
  );
}





class DailyProgressService {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  Future<DailyProgressData?> getDailyProgress() async {
    try {
      // Get token from secure storage
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        print('No access token found');
        return null;
      }

      // Make API call with authorization header
      final NetworkResponseDio response = await _networkCaller.getRequest(
        AppUrl.getUgcDailyProgress,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data']?['attributes'];

        if (data != null) {
          return DailyProgressData.fromJson(data);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching daily progress: $e');
      return null;
    }
  }
}