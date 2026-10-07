import '../models/disaster_alert.dart';
import '../models/disaster_response.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'api_service.dart';
import 'location_service.dart';
import 'response_service.dart';

class AppSession {
  static final ApiService apiService = ApiService();
  static final FastApiAuthService authService = FastApiAuthService(api: apiService);
  static final DeviceLocationService locationService = DeviceLocationService();
  static final LocalResponseService responseService = LocalResponseService();

  static User? currentUser;
  static DisasterAlert? activeAlert = DisasterAlert.sample();
  static SafetyStatus currentStatus = SafetyStatus.noResponse;

  static Future<void> restoreAuthSession() async {
    currentUser = await authService.restoreSession();
  }

  static Future<void> signOut() async {
    await authService.signOut();
    clear();
  }

  static void clear() {
    currentUser = null;
    currentStatus = SafetyStatus.noResponse;
    activeAlert = DisasterAlert.sample();
    responseService.clearResponseHistory();
  }
}
