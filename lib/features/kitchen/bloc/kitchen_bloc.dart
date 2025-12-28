import 'package:flutter_bloc/flutter_bloc.dart';
import 'kitchen_event.dart';
import 'kitchen_state.dart';
import '../data/kitchen_repository.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final KitchenRepository repository;

  KitchenBloc(this.repository) : super(KitchenInitial()) {
    on<LoadKitchens>((event, emit) async {
      emit(KitchenLoading());

      await emit.forEach(
        repository.fetchKitchens(
          hotelId: event.hotelId,
          status: event.status,
          currentUser: event.currentUser,
        ),
        onData: (data) => KitchenLoaded(data),
        onError: (e, _) => KitchenError(e.toString()),
      );
    });

    on<AddKitchen>((event, emit) async {
      emit(KitchenSaving());
      try {
        await repository.addKitchen(
          hotelId: event.hotelId,
          hotelName: event.hotelName,
          name: event.name,
          status: event.status,
          storages: event.storages,
        );
        emit(KitchenSaved());
      } catch (e) {
        emit(KitchenError(e.toString()));
      }
    });

    on<UpdateKitchen>((event, emit) async {
      emit(KitchenSaving());
      try {
        await repository.updateKitchen(kitchen: event.kitchen);
        emit(KitchenSaved());
      } catch (e) {
        emit(KitchenError(e.toString()));
      }
    });

    on<DeleteKitchens>((event, emit) async {
      try {
        await repository.deleteKitchensAcrossHotels(event.kitchens);
      } catch (e) {
        emit(KitchenError(e.toString()));
      }
    });
  }
}
