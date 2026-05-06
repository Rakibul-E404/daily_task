class SubscriptionResponse {
  final int code;
  final String message;
  final SubscriptionData data;
  final bool success;

  SubscriptionResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.success,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: SubscriptionData.fromJson(json['data'] ?? {}),
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
      'success': success,
    };
  }
}

class SubscriptionData {
  final SubscriptionAttributes attributes;

  SubscriptionData({
    required this.attributes,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      attributes: SubscriptionAttributes.fromJson(json['attributes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attributes': attributes.toJson(),
    };
  }
}

class SubscriptionAttributes {
  final List<SubscriptionPlan> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  SubscriptionAttributes({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  factory SubscriptionAttributes.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] as List? ?? [];
    return SubscriptionAttributes(
      results: resultsList.map((e) => SubscriptionPlan.fromJson(e)).toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalResults: json['totalResults'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'totalResults': totalResults,
    };
  }
}

class SubscriptionPlan {
  final String subscriptionName;
  final String subscriptionType;
  final bool freeTrialEnabled;
  final String initialDuration;
  final String renewalFrequency;
  final String amount;
  final String currency;
  final int maxChildrenAccount;
  final String purchaseChannel;
  final String revenueCatProductIdentifier;
  final String revenueCatPackageIdentifier;
  final List<String> availablePlatforms;
  final bool isActive;
  final String subscriptionId;

  SubscriptionPlan({
    required this.subscriptionName,
    required this.subscriptionType,
    required this.freeTrialEnabled,
    required this.initialDuration,
    required this.renewalFrequency,
    required this.amount,
    required this.currency,
    required this.maxChildrenAccount,
    required this.purchaseChannel,
    required this.revenueCatProductIdentifier,
    required this.revenueCatPackageIdentifier,
    required this.availablePlatforms,
    required this.isActive,
    required this.subscriptionId,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      subscriptionName: json['subscriptionName'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      freeTrialEnabled: json['freeTrialEnabled'] ?? false,
      initialDuration: json['initialDuration'] ?? '',
      renewalFrequency: json['renewalFrequncy'] ?? '',
      amount: json['amount'] ?? '0',
      currency: json['currency'] ?? 'usd',
      maxChildrenAccount: json['maxChildrenAccount'] ?? 0,
      purchaseChannel: json['purchaseChannel'] ?? '',
      revenueCatProductIdentifier: json['revenueCatProductIdentifier'] ?? '',
      revenueCatPackageIdentifier: json['revenueCatPackageIdentifier'] ?? '',
      availablePlatforms: List<String>.from(json['availablePlatforms'] ?? []),
      isActive: json['isActive'] ?? false,
      subscriptionId: json['_subscriptionId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionName': subscriptionName,
      'subscriptionType': subscriptionType,
      'freeTrialEnabled': freeTrialEnabled,
      'initialDuration': initialDuration,
      'renewalFrequncy': renewalFrequency,
      'amount': amount,
      'currency': currency,
      'maxChildrenAccount': maxChildrenAccount,
      'purchaseChannel': purchaseChannel,
      'revenueCatProductIdentifier': revenueCatProductIdentifier,
      'revenueCatPackageIdentifier': revenueCatPackageIdentifier,
      'availablePlatforms': availablePlatforms,
      'isActive': isActive,
      '_subscriptionId': subscriptionId,
    };
  }

  // Helper methods
  String getFormattedAmount() {
    return '${_getCurrencySymbol()}$amount';
  }

  String _getCurrencySymbol() {
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$';
      case 'eur':
        return '€';
      case 'gbp':
        return '£';
      case 'bdt':
        return '৳';
      default:
        return '\$';
    }
  }

  String getFormattedPeriod() {
    switch (renewalFrequency.toLowerCase()) {
      case 'monthly':
        return '/ Month';
      case 'yearly':
        return '/ Year';
      case 'weekly':
        return '/ Week';
      default:
        return '/ Month';
    }
  }

  String getPackageName() {
    return 'Basic ${_capitalize(renewalFrequency)} Package';
  }

  String getSubscriptionDescription() {
    if (subscriptionType == 'individual') {
      return 'Perfect for individuals who want to manage their own tasks with focus and simplicity.';
    }
    return 'Perfect for managing tasks efficiently with premium features.';
  }

  String getTrialText() {
    if (freeTrialEnabled) {
      return 'Start Free Trial 7 days';
    }
    return '';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  List<String> getFeatureList() {
    return [
      'Single-user account',
      'Create personal tasks',
      'Start tasks anytime',
      'Mark tasks as completed',
      'Private task visibility',
      'No shared tasks or assignments',
    ];
  }
}