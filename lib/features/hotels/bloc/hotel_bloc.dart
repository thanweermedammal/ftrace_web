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
        repo.getHotels(),
        onData: (hotels) => HotelLoaded(hotels),
        onError: (error, _) => HotelError(error.toString()),
      );
    });
    on<AddHotel>((event, emit) async {
      await repo.addHotel(
        id: event.id,
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
      );
    });
  }
}
