import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      final user = repo.currentUser;
      if (user != null) {
        final userModel = await repo.fetchUserModel(user.uid);
        if (userModel != null) {
          if (userModel.role.toUpperCase() == 'CHEF') {
            await repo.logout();
            emit(AuthInitial());
            return;
          }
          emit(AuthSuccess(userModel));
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repo.login(event.email, event.password);
        if (user == null) {
          emit(AuthFailure("User not found"));
          return;
        }

        final userModel = await repo.fetchUserModel(user.uid);
        if (userModel == null) {
          emit(AuthFailure("User profile not found in database"));
          return;
        }

        // 🔹 Block Chef logins in web
        if (userModel.role.toUpperCase() == 'CHEF') {
          await repo.logout();
          emit(
            AuthFailure("Chefs are not allowed to log in to the web panel."),
          );
          return;
        }

        emit(AuthSuccess(userModel));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repo.logout();
      emit(AuthInitial());
    });
  }
}
