import 'package:ftrace_web/features/hotels/model/hotel_model.dart';

abstract class HotelState {}

class HotelLoading extends HotelState {}

class HotelSaving extends HotelState {}

class HotelSaved extends HotelState {}

class HotelLoaded extends HotelState {
  final List<HotelModel> hotels;
  HotelLoaded(this.hotels);
}

class HotelError extends HotelState {
  final String message;
  HotelError(this.message);
}
