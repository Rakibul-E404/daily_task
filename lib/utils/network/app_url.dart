class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6733.sobhoy.com/api/v1';
  static const String imageBaseUrl = 'https://newsheakh6733.sobhoy.com';
  static const String loginIndividualAndChildren =
      '$baseUrl/auth/login/individual-user';
  static const String getPersonalInformation = '$baseUrl/users/profile/v2';
  static const String updatePersonalInformationProfileData =
      '$baseUrl/users/profile-info';
  static const String updatePersonalInformationProfileImage =
      '$baseUrl/users/profile-picture';

  static const String createPersonalTask = '$baseUrl/tasks/v2';
  static const String createCollaborativeTask = '$baseUrl/tasks/v2';
  static const String createSingleAssignmentTask = '$baseUrl/tasks/v2';
  static const String getSupportMode = '$baseUrl/users/support-mode';
  static const String updateSupportMode = '$baseUrl/users/support-mode';
  static const String getNotification = '$baseUrl/activitys/my';
  static const String getNotificationStyle = '$baseUrl/users/notification-style';
  static const String updateNotificationStyle = '$baseUrl/users/notification-style';
  static const String getPreferredTime = '$baseUrl/users/preferred-time';

  static String getPrivacyPolicyTermsConditionsAboutUs(String type) {
    return '$baseUrl/settings?type=$type';
  }

  static const String changePassword = '$baseUrl/auth/change-password';
  static const String deleteAccount = '$baseUrl/users/delete-my-account';

  ///-------------------
  ///--- UGC -----------
  ///-------------------
  static const String getUgcDailyProgress = '$baseUrl/tasks/daily-progress/v2';
  static const String getUgcHomeScreenTask = '$baseUrl/tasks?page=1&limit=10';

  static String getUgcTaskDetails(String taskId) {
    return '$baseUrl/tasks/$taskId';
  }

  static String getMemberList =
      '$baseUrl/children-business-users/my-family-members';

  static String ugcTaskStatusUpdate(String taskId) {
    return '$baseUrl/task-progress/$taskId/status';
  }

  static String ugcPersonalTaskStatusUpdate(String taskId) {
    return '$baseUrl/tasks/$taskId/status';
  }

  static String deleteTask(String taskId) {
    return '$baseUrl/tasks/$taskId';
  }

  static String getTaskStatusList({
    required String taskStatus,
    String? fromDate,
    String? toDate,
  }) {
    String url = '$baseUrl/tasks?status=$taskStatus';

    if (fromDate != null && fromDate.isNotEmpty) {
      url = '$url&from=$fromDate';
    }

    if (toDate != null && toDate.isNotEmpty) {
      url = '$url&to=$toDate';
    }

    return url;
  }

  ///-------------------
  ///--- Individual ----
  ///-------------------

  static const String signUpIndevidual = '$baseUrl/auth/register/v2';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String resendVerificationCode = '$baseUrl/auth/resend-otp';
}
