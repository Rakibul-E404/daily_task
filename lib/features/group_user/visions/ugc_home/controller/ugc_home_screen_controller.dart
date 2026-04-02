import 'package:get/get.dart';
import '../../../widget/ugc_home_widget/ugc_daily_progress_widget.dart';

class UgcHomeController extends GetxController {
  final DailyProgressService _progressService = DailyProgressService();

  var dailyProgress = Rx<DailyProgressData?>(null);
  var isLoading = false.obs;
  var errorMessage = RxString('');

  @override
  void onInit() {
    super.onInit();
    fetchDailyProgress();
  }

  Future<void> fetchDailyProgress() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final progress = await _progressService.getDailyProgress();
      dailyProgress.value = progress;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh method for pull-to-refresh
  Future<void> refreshData() async {
    await fetchDailyProgress();
  }
}