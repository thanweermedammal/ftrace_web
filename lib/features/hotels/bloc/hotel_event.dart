import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

abstract class HotelEvent {}

class LoadHotels extends HotelEvent {
  final String? query;
  final UserModel? currentUser;
  LoadHotels({this.query, this.currentUser});
}

class AddHotel extends HotelEvent {
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String status;

  AddHotel({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.status = 'ACTIVE',
  });
}

class UpdateHotel extends HotelEvent {
  final HotelModel hotel;
  UpdateHotel(this.hotel);
}

class AddKitchenToHotel extends HotelEvent {
  final String hotelId;
  final String name;
  AddKitchenToHotel(this.hotelId, this.name);
}

class DeleteHotels extends HotelEvent {
  final List<String> hotelIds;
  DeleteHotels(this.hotelIds);
}
