class AppUrl {

  AppUrl._();

  static const String baseUrl = 'https://newsheakh6733.sobhoy.com/api/v1';
  static const String loginIndividualAndChildren = '$baseUrl/auth/login/individual-user';
  ///-------------------
  ///--- UGC -----------
  ///-------------------
  static const String getUgcDailyProgress = '$baseUrl/tasks/daily-progress/v2';
  static const String getUgcHomeScreenTask = '$baseUrl/tasks?page=1&limit=10';
}