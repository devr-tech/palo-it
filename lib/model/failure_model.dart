import 'package:equatable/equatable.dart';

class FailureModel extends Equatable {
  final dynamic statusCode;
  final String message;
  final dynamic data;
  const FailureModel({required this.statusCode, required this.message, this.data});

  @override
  // TODO: implement props
  List<Object?> get props => [statusCode, message, data];
}
