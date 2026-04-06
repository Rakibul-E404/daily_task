class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6733.sobhoy.com/api/v1';
  static const String imageBaseUrl = 'https://newsheakh6733.sobhoy.com';
  static const String loginIndividualAndChildren =
      '$baseUrl/auth/login/individual-user';
  static const String getPersonalInformation = '$baseUrl/users/profile/v2';
  static const String updatePersonalInformation = '$baseUrl/users/profile-info';
  static const String updatePersonalInformationImage =
      '$baseUrl/users/profile-picture';

  ///-------------------
  ///--- UGC -----------
  ///-------------------
  static const String getUgcDailyProgress = '$baseUrl/tasks/daily-progress/v2';
  static const String getUgcHomeScreenTask = '$baseUrl/tasks?page=1&limit=10';

  static String getUgcTaskDetails(String taskId) {
    return '$baseUrl/tasks/$taskId';
  }



  ///-------------------
  ///--- Individual ----
  ///-------------------

  static const String signUpIndevidual = '$baseUrl/auth/register/v2';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String resendVerificationCode = '$baseUrl/auth/resend-otp';


}
