abstract class KitchenFormState {}

class KitchenFormInitial extends KitchenFormState {}

class KitchenFormSaving extends KitchenFormState {}

class KitchenFormSaved extends KitchenFormState {}

class KitchenFormError extends KitchenFormState {
  final String message;
  KitchenFormError(this.message);
}
