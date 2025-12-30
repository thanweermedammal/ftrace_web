import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/kitchen/data/kitchen_repository.dart';

import 'kitchen_form_event.dart';
import 'kitchen_form_state.dart';

class KitchenFormBloc extends Bloc<KitchenFormEvent, KitchenFormState> {
  final KitchenRepository repository;

  KitchenFormBloc(this.repository) : super(KitchenFormInitial()) {
    on<AddKitchenForm>(_onAddKitchen);
    on<UpdateKitchenForm>(_onUpdateKitchen);
  }

  Future<void> _onAddKitchen(
      AddKitchenForm event,
      Emitter<KitchenFormState> emit,
      ) async {
    emit(KitchenFormSaving());
    try {
      await repository.addKitchen(
        hotelId: event.hotelId,
        hotelName: event.hotelName,
        name: event.name,
        status: event.status,
        storages: event.storages,
      );
      emit(KitchenFormSaved());
    } catch (e) {
      emit(KitchenFormError(e.toString()));
    }
  }

  Future<void> _onUpdateKitchen(
      UpdateKitchenForm event,
      Emitter<KitchenFormState> emit,
      ) async {
    emit(KitchenFormSaving());
    try {
      await repository.updateKitchen(kitchen: event.kitchen);
      emit(KitchenFormSaved());
    } catch (e) {
      emit(KitchenFormError(e.toString()));
    }
  }
}
