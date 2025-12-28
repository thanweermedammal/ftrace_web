import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await repo.login(event.email, event.password);
        emit(AuthSuccess());
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
