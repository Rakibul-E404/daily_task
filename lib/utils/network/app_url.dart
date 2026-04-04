class AppUrl {

  AppUrl._();

  static const String baseUrl = 'https://newsheakh6733.sobhoy.com/api/v1';
  static const String imageBaseUrl = 'https://newsheakh6733.sobhoy.com';
  static const String loginIndividualAndChildren = '$baseUrl/auth/login/individual-user';
  static const String getPersonalInformation = '$baseUrl/users/profile/v2';
  static const String updatePersonalInformation = '$baseUrl/users/profile-info';
  ///-------------------
  ///--- UGC -----------
  ///-------------------
  static const String getUgcDailyProgress = '$baseUrl/tasks/daily-progress/v2';
  static const String getUgcHomeScreenTask = '$baseUrl/tasks?page=1&limit=10';
}