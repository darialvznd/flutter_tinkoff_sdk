import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tinkoff_sdk/helpers/tinkoff_check_type_helper.dart';
import 'package:flutter_tinkoff_sdk/models/tinkoff_acquiring_models/tinkoff_common_response.dart';

import 'helpers/tinkoff_dark_theme_mode.dart';
import 'helpers/tinkoff_language_helper.dart';
import 'models/tinkoff_acquiring_models/tinkoff_error.dart';

class FlutterTinkoffSDk {
  static const MethodChannel _channel = MethodChannel('flutter_tinkoff_sdk');

  /// Terminal key given by Tinkoff
  final String terminalKey;

  /// Public key given by Tinkoff
  final String publicKey;

  FlutterTinkoffSDk({
    required this.terminalKey,
    required this.publicKey,
  });

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Open card payment process screen
  Future<TinkoffCommonResponse> openPaymentScreen({
    required String orderId,
    required String title,
    required double money, //amount in rubles
    required String customerId,
    required String email,
    required String paymentId,
    required String lang,
  }) async {
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'openPaymentScreen',
      {
        'orderId': orderId,
        'title': title,
        'amount': money,
        'customerId': customerId,
        'email': email,
        'terminalKey': terminalKey,
        'publicKey': publicKey,
        'paymentId': paymentId,
        'lang': lang,
      },
    );

    final TinkoffCommonResponse status = TinkoffCommonResponse.fromJson(
      response.cast<String, dynamic>(),
    );

    return status;
  }

  /// Not configured
  /// (!) Android-specific
  /// Open google pay payment process screen

  Future<TinkoffCommonResponse> openGooglePay({
    required String orderId,
    required String title,
    required String description,
    required double money,
    required bool recurrentPayment,
    required String customerId,
    TinkoffCheckType? checkType,
    required String email,
    required bool enableSecureKeyboard,
    required bool enableCameraCardScanner,
    required TinkoffDarkThemeMode darkThemeMode,
    required TinkoffLanguage language,
  }) async {
    final Map<dynamic, dynamic> response = await _channel.invokeMethod('openGooglePay', {
      'orderId': orderId,
      'title': title,
      'description': description,
      'money': money,
      'recurrentPayment': recurrentPayment,
      'customerId': customerId,
      'checkType': checkType != null ? TinkoffCheckTypeHelper(checkType).value : null,
      'email': email,
      'enableSecureKeyboard': enableSecureKeyboard,
      'enableCameraCardScanner': enableCameraCardScanner,
      'darkThemeMode': TinkoffDarkThemeModeHelper(darkThemeMode).value,
      'language': TinkoffLanguageHelper(language).value
    });

    final TinkoffCommonResponse status = TinkoffCommonResponse.fromJson(response.cast<String, dynamic>());

    if (status.error != null) throw TinkoffError(message: status.error!);

    return status;
  }

  /// Not configured
  /// (!) iOS-specific
  /// Open apple pay payment process screen

  Future<TinkoffCommonResponse> openApplePay({
    required String orderId,
    required String title,
    required String description,
    required double money,
    required bool recurrentPayment,
    required String customerId,
    TinkoffCheckType? checkType,
    required String email,
    required TinkoffLanguage language,
    required String merchantIdentifier,
  }) async {
    final Map<dynamic, dynamic> response = await _channel.invokeMethod('openApplePay', {
      'orderId': orderId,
      'title': title,
      'description': description,
      'money': money,
      'recurrentPayment': recurrentPayment,
      'customerId': customerId,
      'checkType': checkType != null ? TinkoffCheckTypeHelper(checkType).value : null,
      'email': email,
      'language': TinkoffLanguageHelper(language).value,
      'merchantIdentifier': merchantIdentifier
    });

    final TinkoffCommonResponse status = TinkoffCommonResponse.fromJson(response.cast<String, dynamic>());

    if (status.error != null) throw TinkoffError(message: status.error!);

    return status;
  }
}
