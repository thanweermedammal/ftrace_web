import '../model/kitchen_model.dart';

abstract class KitchenState {}

class KitchenInitial extends KitchenState {}

class KitchenLoading extends KitchenState {}

class KitchenLoaded extends KitchenState {
  final List<KitchenModel> kitchens;
  KitchenLoaded(this.kitchens);
}

class KitchenSaving extends KitchenState {}

class KitchenSaved extends KitchenState {}
class KitchenDeleting extends KitchenState {}
class KitchenDeleted extends KitchenState {}
class KitchenError extends KitchenState {
  final String message;
  KitchenError(this.message);
}
