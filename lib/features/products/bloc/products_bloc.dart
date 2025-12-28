import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../data/products_repository.dart';
import '../model/product_model.dart';

// EVENTS
abstract class ProductsEvent {}

class LoadProducts extends ProductsEvent {
  final String? hotelId;
  final String? query;
  final String? supplier;
  final String? uom;
  final String? inventoryUom;
  final String? category;
  final UserModel? currentUser;
  LoadProducts({
    this.hotelId,
    this.query,
    this.supplier,
    this.uom,
    this.inventoryUom,
    this.category,
    this.currentUser,
  });
}

class AddProduct extends ProductsEvent {
  final ProductModel product;
  AddProduct(this.product);
}

class BulkAddProducts extends ProductsEvent {
  final List<ProductModel> products;
  BulkAddProducts(this.products);
}

class UpdateProduct extends ProductsEvent {
  final ProductModel product;
  UpdateProduct(this.product);
}

class DeleteProducts extends ProductsEvent {
  final List<ProductModel> products;
  DeleteProducts(this.products);
}

// STATE
abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  ProductsLoaded(this.products);
}

class ProductSaved extends ProductsState {}

class ProductsSaving extends ProductsState {}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

// BLOC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repository;

  ProductsBloc(this.repository) : super(ProductsInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductsLoading());
      await emit.forEach(
        repository.fetchProducts(
          event.hotelId,
          query: event.query,
          supplier: event.supplier,
          uom: event.uom,
          inventoryUom: event.inventoryUom,
          category: event.category,
          currentUser: event.currentUser,
        ),
        onData: (data) => ProductsLoaded(data),
        onError: (e, _) => ProductsError(e.toString()),
      );
    });

    on<AddProduct>((event, emit) async {
      emit(ProductsSaving());
      try {
        await repository.addProduct(event.product);
        emit(ProductSaved());
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });

    on<BulkAddProducts>((event, emit) async {
      emit(ProductsSaving());
      try {
        await repository.bulkAddProducts(event.products);
        emit(ProductSaved());
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });

    on<UpdateProduct>((event, emit) async {
      emit(ProductsSaving());
      try {
        await repository.updateProduct(event.product);
        emit(ProductSaved());
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });

    on<DeleteProducts>((event, emit) async {
      try {
        // Group by hotelId
        final Map<String, List<String>> byHotel = {};
        for (final p in event.products) {
          if (!byHotel.containsKey(p.hotelId)) {
            byHotel[p.hotelId] = [];
          }
          byHotel[p.hotelId]!.add(p.id);
        }

        // Execute deletes
        for (final entry in byHotel.entries) {
          await repository.deleteProducts(entry.key, entry.value);
        }
      } catch (e) {
        emit(ProductsError(e.toString()));
      }
    });
  }
}
