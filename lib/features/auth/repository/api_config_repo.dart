import '../../../core/services/api_service.dart';
import '../models/api_config_model.dart';
import '../../packing/models/printing_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ApiConfigRepo {
  ApiConfigModel getApiCongig();
  PrintingConfigModel getPrintingCongig();
  void setApiCongig(ApiConfigModel config);
  void setPrintingCongig(PrintingConfigModel config);
  Future<bool> testApiConnection(ApiConfigModel config);
}

class ApiConfigRepoImp extends ApiConfigRepo {
  ApiConfigRepoImp({
    required SharedPreferences preferences,
    required ApiService apiService,
  }) : _preferences = preferences,
       _apiService = apiService;

  final SharedPreferences _preferences;
  final ApiService _apiService;

  @override
  ApiConfigModel getApiCongig() {
    String baseUrl = _preferences.getString("BASE_URL") ?? "";
    String port = _preferences.getString("PORT") ?? "";
    String dbName = _preferences.getString("DB_NAME") ?? "";

    ApiConfigModel apiConfig = ApiConfigModel(
      baseUrl: baseUrl,
      port: port,
      dbName: dbName,
    );
    return apiConfig;
  }

  @override
  void setApiCongig(ApiConfigModel config) {
    _preferences.setString("BASE_URL", _addHttpProtocol(config.baseUrl));
    _preferences.setString("PORT", config.port);
    _preferences.setString("DB_NAME", config.dbName);
  }

  String _addHttpProtocol(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    return url;
  }

  @override
  PrintingConfigModel getPrintingCongig() {
    String ip = _preferences.getString("P_IP") ?? "";
    String port = _preferences.getString("P_PORT") ?? "9100";
    PrintingConfigModel apiConfig = PrintingConfigModel(ip: ip, port: port);
    return apiConfig;
  }

  @override
  void setPrintingCongig(PrintingConfigModel config) {
    _preferences.setString("P_IP", config.ip ?? "");
    _preferences.setString("P_PORT", config.port ?? "9100");
  }

  @override
  Future<bool> testApiConnection(ApiConfigModel config) async {
    // Store original configuration
    String currentBaseUrl = _preferences.getString("BASE_URL") ?? "";
    String currentPort = _preferences.getString("PORT") ?? "";

    try {
      // Set the test configuration temporarily
      await _preferences.setString(
        "BASE_URL",
        _addHttpProtocol(config.baseUrl),
      );
      await _preferences.setString("PORT", config.port);

      // Test the connection using the ApiService
      final response = await _apiService.get('/web');

      return response.isSuccess;
    } catch (e) {
      return false;
    } finally {
      // Always restore the original configuration
      await _preferences.setString("BASE_URL", currentBaseUrl);
      await _preferences.setString("PORT", currentPort);
    }
  }
}
