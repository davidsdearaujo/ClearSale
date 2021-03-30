import 'package:clearsale/src/domain/errors/failure.dart';

class EndpointMessageFailure extends Failure {
  final String status;
  final Map<String, dynamic> fields;
  EndpointMessageFailure({
    required String message,
    required this.status,
    required this.fields,
  }) : super("endpoint-message-failure", message: message);
}

class EndpointInvalidStatusCodeFailure extends Failure {
  final int statusCode;
  final String body;
  EndpointInvalidStatusCodeFailure({
    required this.statusCode,
    required this.body,
  }) : super("endpoint-invalid-statuscode-failure");
}
