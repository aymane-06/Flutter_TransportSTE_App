import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/api_config_model.dart';
import '../../repository/api_config_repo.dart';

part 'api_config_state.dart';

class ApiConfigCubit extends Cubit<ApiConfigState> {
  ApiConfigCubit({required this.repo}) : super(ApiConfigInitial());

  ApiConfigRepo repo;

  void getApiConfig() {
    emit(ApiConfigInitial());
    final apiConf = repo.getApiCongig();
    emit(LoadedApiConfigState(apiConfig: apiConf));
  }

  void setApiConfig(ApiConfigModel apiConfig) {
    emit(ApiConfigInitial());
    repo.setApiCongig(apiConfig);
    emit(SuccessToChangeApiConfigState());
  }

  void testApiConnection(ApiConfigModel apiConfig) async {
    emit(ApiConfigInitial());
    try {
      final isConnected = await repo.testApiConnection(apiConfig);
      if (isConnected == true) {
        emit(
          SuccessToTestApiConnectionState(
            message: 'Successfully connected to the API',
          ),
        );
      } else {
        emit(FailedToConnectState(message: 'Failed to connect to the API'));
      }
    } catch (e) {
      emit(FailedToConnectState(message: 'Error testing connection: $e'));
    }
  }
}
