import 'package:json_annotation/json_annotation.dart';

part 'tinkoff_error.g.dart';

@JsonSerializable()
class TinkoffError extends Error {
  final String message;

  TinkoffError({required this.message});

  @override
  String toString() {
    return 'TinkoffError{message: $message}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinkoffError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  factory TinkoffError.fromJson(Map<String, dynamic> json) =>
      _$TinkoffErrorFromJson(json);
  Map<String, dynamic> toJson() => _$TinkoffErrorToJson(this);
}
