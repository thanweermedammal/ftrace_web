import 'package:ftrace_web/features/kitchen/model/kitchen_model.dart';



abstract class KitchenFormEvent {}

class AddKitchenForm extends KitchenFormEvent {
  final String hotelId;
  final String hotelName;
  final String name;
  final String status;
  final List<String> storages;

  AddKitchenForm({
    required this.hotelId,
    required this.hotelName,
    required this.name,
    required this.status,
    required this.storages,
  });
}

class UpdateKitchenForm extends KitchenFormEvent {
  final KitchenModel kitchen;

  UpdateKitchenForm({required this.kitchen});
}
