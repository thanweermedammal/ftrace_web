// user_event.dart
import 'package:ftrace_web/features/users/model/users_model.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {
  final String? role;
  final String? status;
  final String? query;

  LoadUsers({this.role, this.status, this.query});
}

class AddUser extends UserEvent {
  final UserModel user;
  AddUser(this.user);
}

class UpdateUser extends UserEvent {
  final UserModel user;
  UpdateUser(this.user);
}
class DeleteUsers extends UserEvent {
  final List<String> ids;
  DeleteUsers(this.ids);
}