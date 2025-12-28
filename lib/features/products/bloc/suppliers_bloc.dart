import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../data/suppliers_repository.dart';
import '../model/supplier_model.dart';

// EVENTS
abstract class SuppliersEvent {}

class LoadSuppliers extends SuppliersEvent {
  final String? hotelId;
  final String? query;
  final UserModel? currentUser;
  LoadSuppliers({this.hotelId, this.query, this.currentUser});
}

class AddSuppliers extends SuppliersEvent {
  final List<String> names;
  final String hotelId;
  final String hotelName;
  AddSuppliers(this.names, this.hotelId, this.hotelName);
}

class UpdateSupplier extends SuppliersEvent {
  final SupplierModel supplier;
  UpdateSupplier(this.supplier);
}

class DeleteSuppliers extends SuppliersEvent {
  final List<SupplierModel> suppliers;
  DeleteSuppliers(this.suppliers);
}

// STATE
abstract class SuppliersState {}

class SuppliersInitial extends SuppliersState {}

class SuppliersLoading extends SuppliersState {}

class SuppliersLoaded extends SuppliersState {
  final List<SupplierModel> suppliers;
  SuppliersLoaded(this.suppliers);
}

class SuppliersSaved extends SuppliersState {}

class SuppliersError extends SuppliersState {
  final String message;
  SuppliersError(this.message);
}

// BLOC
class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final SuppliersRepository repository;

  SuppliersBloc(this.repository) : super(SuppliersInitial()) {
    on<LoadSuppliers>((event, emit) async {
      emit(SuppliersLoading());
      await emit.forEach(
        repository.fetchSuppliers(
          event.hotelId,
          query: event.query,
          currentUser: event.currentUser,
        ),
        onData: (data) => SuppliersLoaded(data),
        onError: (e, _) => SuppliersError(e.toString()),
      );
    });

    on<AddSuppliers>((event, emit) async {
      try {
        await repository.addSuppliers(
          event.names,
          event.hotelId,
          event.hotelName,
        );
        emit(SuppliersSaved());
      } catch (e) {
        emit(SuppliersError(e.toString()));
      }
    });

    on<UpdateSupplier>((event, emit) async {
      try {
        await repository.updateSupplier(event.supplier);
        emit(SuppliersSaved());
      } catch (e) {
        emit(SuppliersError(e.toString()));
      }
    });

    on<DeleteSuppliers>((event, emit) async {
      try {
        final Map<String, List<String>> byHotel = {};
        for (final s in event.suppliers) {
          if (!byHotel.containsKey(s.hotelId)) {
            byHotel[s.hotelId] = [];
          }
          byHotel[s.hotelId]!.add(s.id);
        }

        for (final entry in byHotel.entries) {
          await repository.deleteSuppliers(entry.key, entry.value);
        }
      } catch (e) {
        emit(SuppliersError(e.toString()));
      }
    });
  }
}
