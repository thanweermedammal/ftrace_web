import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/hotels/data/hotel_repository.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';

import 'hotel_event.dart';
import 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  final HotelRepository repo;

  HotelBloc(this.repo) : super(HotelLoading()) {
    // on<LoadHotels>((event, emit) async {
    //   emit(HotelLoading());
    //   repo.getHotels().listen(
    //         (hotels) => emit(HotelLoaded(hotels)),
    //   );
    // });
    on<LoadHotels>((event, emit) async {
      emit(HotelLoading());
      await emit.forEach<List<HotelModel>>(
        repo.getHotels(currentUser: event.currentUser),
        onData: (hotels) => HotelLoaded(hotels),
        onError: (error, _) => HotelError(error.toString()),
      );
    });
    on<AddHotel>((event, emit) async {
      emit(HotelSaving());
      try {
        final newHotel = HotelModel(
          id: '',
          name: event.name,
          email: event.email ?? '',
          phone: event.phone ?? '',
          address: event.address ?? '',
          status: event.status,
          kitchens: [],
        );
        await repo.addHotel(newHotel);
        emit(HotelSaved());
      } catch (e) {
        emit(HotelError(e.toString()));
      }
    });

    on<UpdateHotel>((event, emit) async {
      emit(HotelSaving());
      try {
        await repo.updateHotel(event.hotel);
        emit(HotelSaved());
      } catch (e) {
        emit(HotelError(e.toString()));
      }
    });

    on<AddKitchenToHotel>((event, emit) async {
      await repo.addKitchen(event.hotelId, event.name);
      // Optional: Trigger a refresh if logic permits, or rely on Firestore if parent updates.
      // Currently, adding a subcollection item doesn't trigger the parent stream in getHotels implementation.
      // We might need a better reactivity model later.
    });

    on<DeleteHotels>((event, emit) async {
      await repo.deleteHotels(event.hotelIds);
    });
  }
}
