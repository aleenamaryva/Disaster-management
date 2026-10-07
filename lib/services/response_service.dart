import '../models/disaster_response.dart';

abstract class ResponseService {
  Future<void> saveResponse(DisasterResponse response);
  List<DisasterResponse> getAllResponses();
  DisasterResponse? getLatestResponse();
  void clearResponseHistory();
  Future<void> saveLocalNoResponse({required String userId, required String disasterId});
  SafetyStatus get currentStatus;
}

class LocalResponseService implements ResponseService {
  SafetyStatus _currentStatus = SafetyStatus.noResponse;
  final List<DisasterResponse> _responses = [];

  @override
  Future<void> saveResponse(DisasterResponse response) async {
    _responses.add(response);
    _currentStatus = response.status;
  }

  @override
  List<DisasterResponse> getAllResponses() {
    final responses = List<DisasterResponse>.from(_responses);
    responses.sort((first, second) => second.timestamp.compareTo(first.timestamp));
    return List<DisasterResponse>.unmodifiable(responses);
  }

  @override
  DisasterResponse? getLatestResponse() {
    final responses = getAllResponses();
    return responses.isEmpty ? null : responses.first;
  }

  @override
  void clearResponseHistory() {
    _responses.clear();
    _currentStatus = SafetyStatus.noResponse;
  }

  @override
  Future<void> saveLocalNoResponse({required String userId, required String disasterId}) async {
    _currentStatus = SafetyStatus.noResponse;
  }

  @override
  SafetyStatus get currentStatus => _currentStatus;
}
