import 'package:askfemi/features/individual_user/views/subscription/subscription_models.dart';
import 'package:get/get.dart';
import '../../../../utils/network/app_url.dart';
import '../../../../utils/network/network_caller_dio.dart';
import '../../../../utils/network/secure_storage_service.dart';

class SubscriptionController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var isLoading = false.obs;
  var errorMessage = RxString('');
  var subscriptionResponse = Rx<SubscriptionResponse?>(null);
  var individualPlan = Rx<SubscriptionPlan?>(null);
  var hasSubscription = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionData();
  }

  Future<void> fetchSubscriptionData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      if (token == null) {
        errorMessage.value = 'No access token found';
        isLoading.value = false;
        return;
      }

      print('🌐 Making GET request to: ${AppUrl.getSubscription}');

      final response = await _networkCaller.getRequest(
        AppUrl.getSubscription,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Response status code: ${response.statusCode}');
      print('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final subscriptionData = SubscriptionResponse.fromJson(response.jsonResponse!);
        subscriptionResponse.value = subscriptionData;

        // Find individual plan
        if (subscriptionData.data.attributes.results.isNotEmpty) {
          individualPlan.value = subscriptionData.data.attributes.results.firstWhere(
                (plan) => plan.subscriptionType == 'individual',
            orElse: () => subscriptionData.data.attributes.results.first,
          );
          hasSubscription.value = true;
          print('✅ Loaded individual plan: ${individualPlan.value?.subscriptionName}');
        } else {
          hasSubscription.value = false;
          print('⚠️ No subscription data found');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load subscription data';
        print('❌ API call failed: ${response.errorMessage}');
      }
    } catch (e) {
      print('Error fetching subscription: $e');
      errorMessage.value = 'An error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  SubscriptionPlan? getIndividualPlan() {
    return individualPlan.value;
  }

  bool hasActiveSubscription() {
    return individualPlan.value != null && individualPlan.value!.isActive;
  }

  void cancelSubscription() {
    // Implement cancel subscription logic here
    print('Cancelling subscription: ${individualPlan.value?.subscriptionId}');
  }
}