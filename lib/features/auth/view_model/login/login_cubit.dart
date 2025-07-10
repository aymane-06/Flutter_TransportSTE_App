import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_auth_model.dart';
import '../../repository/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.authRepo}) : super(LoginInitial());

  final AuthRepo authRepo;

  void login(UserAuthModel user) async {
    emit(LoadingAuthState());

    final res = await authRepo.login(user);
    res.fold(
      (l) => emit(FailedToLoginState(message: l.message)),
      (r) => emit(SuccessToLoginState()),
    );
  }
}
