import 'package:json_annotation/json_annotation.dart';

part 'tinkoff_common_response.g.dart';

@JsonSerializable()
class TinkoffCommonResponse {
  final TinkoffAcquiringResultStatus status;
  final String? cardId;
  final int? paymentId;
  final String? rebillId;
  final String? error;

  TinkoffCommonResponse({
    required this.status,
    required this.cardId,
    required this.paymentId,
    required this.rebillId,
    this.error,
  });

  @override
  String toString() {
    return 'TinkoffCommonResponse{status: $status, cardId: $cardId, paymentId: $paymentId, rebillId: $rebillId, error: $error}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinkoffCommonResponse &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          cardId == other.cardId &&
          paymentId == other.paymentId &&
          rebillId == other.rebillId &&
          error == other.error;

  @override
  int get hashCode =>
      status.hashCode ^
      cardId.hashCode ^
      paymentId.hashCode ^
      rebillId.hashCode ^
      error.hashCode;

  factory TinkoffCommonResponse.fromJson(Map<String, dynamic> json) =>
      _$TinkoffCommonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TinkoffCommonResponseToJson(this);
}

enum TinkoffAcquiringResultStatus {
  @JsonValue("RESULT_OK")
  resultOK,
  @JsonValue("RESULT_CANCELLED")
  resultCancelled,
  @JsonValue("RESULT_NONE")
  resultNone,
  @JsonValue("RESULT_ERROR")
  resultError,
  @JsonValue("ERROR_NOT_INITIALIZED")
  errorNotInitialized,
  @JsonValue("ERROR_NO_ACTIVITY")
  errorNoActivity,
}
