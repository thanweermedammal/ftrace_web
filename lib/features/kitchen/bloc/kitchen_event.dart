abstract class KitchenEvent {}

class LoadKitchens extends KitchenEvent {
  final String hotelId;
  final String? status;

  LoadKitchens({required this.hotelId, this.status});
}

class AddKitchen extends KitchenEvent {
  final String hotelId;
  final String name;
  final String status;
  final List<String> storages;

  AddKitchen({
    required this.hotelId,
    required this.name,
    required this.status,
    required this.storages,
  });
}
