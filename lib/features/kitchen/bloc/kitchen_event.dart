import 'package:ftrace_web/features/users/model/users_model.dart';
import '../model/kitchen_model.dart';

abstract class KitchenEvent {}

class LoadKitchens extends KitchenEvent {
  final String? hotelId;
  final String? status;
  final String? query;
  final UserModel? currentUser;

  LoadKitchens({this.hotelId, this.status, this.query, this.currentUser});
}

class AddKitchen extends KitchenEvent {
  final String hotelId;
  final String hotelName;
  final String name;
  final String status;
  final List<String> storages;

  AddKitchen({
    required this.hotelId,
    required this.hotelName,
    required this.name,
    required this.status,
    required this.storages,
  });
}

class UpdateKitchen extends KitchenEvent {
  final KitchenModel kitchen;
  UpdateKitchen(this.kitchen);
}

class DeleteKitchens extends KitchenEvent {
  final List<KitchenModel> kitchens;
  DeleteKitchens(this.kitchens);
}
