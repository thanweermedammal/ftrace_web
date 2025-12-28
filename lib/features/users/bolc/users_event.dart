// user_event.dart
import 'package:ftrace_web/features/users/model/users_model.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {
  final String? role;
  final String? status;

  LoadUsers({this.role, this.status});
}

class AddUser extends UserEvent {
  final UserModel user;
  AddUser(this.user);
}
