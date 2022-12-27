// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tinkoff_common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TinkoffCommonResponse _$TinkoffCommonResponseFromJson(
        Map<String, dynamic> json) =>
    TinkoffCommonResponse(
      status:
          $enumDecode(_$TinkoffAcquiringCommonStatusEnumMap, json['status']),
      cardId: json['cardId'] as String?,
      paymentId: json['paymentId'] as int?,
      rebillId: json['rebillId'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$TinkoffCommonResponseToJson(
        TinkoffCommonResponse instance) =>
    <String, dynamic>{
      'status': _$TinkoffAcquiringCommonStatusEnumMap[instance.status]!,
      'cardId': instance.cardId,
      'paymentId': instance.paymentId,
      'rebillId': instance.rebillId,
      'error': instance.error,
    };

const _$TinkoffAcquiringCommonStatusEnumMap = {
  TinkoffAcquiringResultStatus.resultOK: 'RESULT_OK',
  TinkoffAcquiringResultStatus.resultCancelled: 'RESULT_CANCELLED',
  TinkoffAcquiringResultStatus.resultNone: 'RESULT_NONE',
  TinkoffAcquiringResultStatus.resultError: 'RESULT_ERROR',
  TinkoffAcquiringResultStatus.errorNotInitialized: 'ERROR_NOT_INITIALIZED',
  TinkoffAcquiringResultStatus.errorNoActivity: 'ERROR_NO_ACTIVITY',
};
