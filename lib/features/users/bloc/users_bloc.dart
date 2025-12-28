// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/bloc/users_event.dart';
import 'package:ftrace_web/features/users/bloc/users_state.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUsers>((event, emit) async {
      emit(UserLoading());
      await emit.forEach(
        repository.fetchUsers(role: event.role, status: event.status),
        onData: (data) => UserLoaded(data),
        onError: (_, e) => UserError(e.toString()),
      );
    });

    on<AddUser>((event, emit) async {
      emit(UserSaving());
      try {
        await repository.addUser(event.user);
        emit(UserSaved());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUser>((event, emit) async {
      emit(UserSaving());
      try {
        await repository.updateUser(event.user);
        emit(UserSaved());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
    on<DeleteUsers>((event, emit) async {
      await repository.deleteUsers(event.ids);
    });
  }
}
