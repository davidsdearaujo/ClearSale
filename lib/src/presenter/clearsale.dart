import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

import '../domain/models/analysis_response_model.dart';
import '../domain/models/analysis_request_model.dart';
import '../domain/models/chargeback_marking_response_model.dart';
import '../domain/models/credentials_model.dart';
import '../domain/models/message_model.dart';
import '../domain/models/response_model.dart';
import '../domain/models/token_model.dart';
import '../domain/usecases/analysis_request.dart';
import '../domain/usecases/authenticate.dart';
import '../domain/usecases/chargeback_marking.dart';
import '../domain/usecases/reanalysis_request.dart';
import '../domain/usecases/status_consult.dart';
import '../domain/usecases/status_update.dart';
import '../external/datasources/guarantee_datasource_impl.dart';
import '../infra/repositories/guarantee_repository_impl.dart';

class ClearSale {
  final CredentialsModel credentials;
  late Authenticate _authenticate;
  late AnalysisRequest _analysisRequest;
  late ReanalysisRequest _reanalysisRequest;
  late ChargebackMarking _chargebackMarking;
  late StatusConsult _statusConsult;
  late StatusUpdate _statusUpdate;

  factory ClearSale({
    required String userName,
    required String password,
    bool automaticAuthenticate = true,
    bool isProduction = false,
  }) {
    assert(userName != "");

    assert(password != "");

    return ClearSale._(CredentialsModel(userName, password), automaticAuthenticate, isProduction);
  }

  factory ClearSale.test({
    required String userName,
    required String password,
    bool automaticAuthenticate = true,
    required Client httpClient,
    required bool isProduction,
  }) {
    return ClearSale._(CredentialsModel(userName, password), automaticAuthenticate, isProduction, httpClient);
  }

  ClearSale._(this.credentials, bool automaticAuthenticate, bool isProduction, [Client? httpClient]) {
    final guaranteeDatasource = GuaranteeDatasourceImpl(isProduction, httpClient ?? Client());
    final guaranteeRepository = GuaranteeRepositoryImpl(guaranteeDatasource);
    _authenticate = Authenticate(guaranteeRepository);
    _analysisRequest = AnalysisRequest(guaranteeRepository);
    _reanalysisRequest = ReanalysisRequest(guaranteeRepository);
    _chargebackMarking = ChargebackMarking(guaranteeRepository);
    _statusConsult = StatusConsult(guaranteeRepository);
    _statusUpdate = StatusUpdate(guaranteeRepository);
    if (automaticAuthenticate) authenticate();
  }

  Future<TokenModel?> authenticate({int loopCountIfError = 3}) async {
    final response = await _authenticate.call(credentials, loopCountIfError);
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }

  Future<ResponseModel<AnalysisResponseModel>?> analysisRequest(
    AnalysisRequestModel analysisRequestModel,
  ) async {
    final response = await _analysisRequest.call(analysisRequestModel);
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }

  Future<ResponseModel<AnalysisResponseModel>?> reanalysisRequest(
    AnalysisRequestModel analysisRequestModel,
  ) async {
    final response = await _reanalysisRequest.call(analysisRequestModel);
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }

  Future<ResponseModel<ChargebackMarkingResponseModel>?> chargebackMarking({
    required String message,
    required List<String> analysisCode,
  }) async {
    final response = await _chargebackMarking.call(
      message: message,
      analysisCode: analysisCode,
    );
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }

  Future<ResponseModel<OrderModel>?> statusConsult(String analysisCode) async {
    final response = await _statusConsult.call(analysisCode);
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }

  ///Importante: Os status de atualização devem ser combinados com a equipe de integração.
  Future<ResponseModel<MessageModel>?> statusUpdate(
    String analysisCode,
    String newStatusCode,
  ) async {
    final response = await _statusUpdate.call(analysisCode, newStatusCode);
    if (response.isLeft()) throw response.fold(id, id);
    return response.fold((l) => null, (r) => r);
  }
}
