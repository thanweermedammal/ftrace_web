// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/bolc/users_event.dart';
import 'package:ftrace_web/features/users/bolc/users_state.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UserLoading());
      await emit.forEach(
        repository.fetchUsers(
          role: event.role,
          status: event.status,
        ),
        onData: (data) => UserLoaded(data),
        onError: (_, e) => UserError(e.toString()),
      );
    });

    on<AddUser>((event, emit) async {
      await repository.addUser(event.user);
    });
  }
}
