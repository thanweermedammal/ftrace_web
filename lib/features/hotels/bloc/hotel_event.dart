abstract class HotelEvent {}

class LoadHotels extends HotelEvent {}

class AddHotel extends HotelEvent {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  AddHotel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });
}
