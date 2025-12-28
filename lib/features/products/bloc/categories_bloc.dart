import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../data/categories_repository.dart';
import '../model/category_model.dart';

// EVENTS
abstract class CategoriesEvent {}

class LoadCategories extends CategoriesEvent {
  final String? hotelId;
  final String? query;
  final UserModel? currentUser;
  LoadCategories({this.hotelId, this.query, this.currentUser});
}

class AddCategories extends CategoriesEvent {
  final List<String> names;
  final String hotelId;
  final String hotelName;
  AddCategories(this.names, this.hotelId, this.hotelName);
}

class UpdateCategory extends CategoriesEvent {
  final CategoryModel category;
  UpdateCategory(this.category);
}

class DeleteCategories extends CategoriesEvent {
  final List<CategoryModel> categories;
  DeleteCategories(this.categories);
}

// STATE
abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class CategoriesSaved extends CategoriesState {}

class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}

// BLOC
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository repository;

  CategoriesBloc(this.repository) : super(CategoriesInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoriesLoading());
      await emit.forEach(
        repository.fetchCategories(
          event.hotelId,
          query: event.query,
          currentUser: event.currentUser,
        ),
        onData: (data) => CategoriesLoaded(data),
        onError: (e, _) => CategoriesError(e.toString()),
      );
    });

    on<AddCategories>((event, emit) async {
      try {
        await repository.addCategories(
          event.names,
          event.hotelId,
          event.hotelName,
        );
        emit(CategoriesSaved());
      } catch (e) {
        emit(CategoriesError(e.toString()));
      }
    });

    on<UpdateCategory>((event, emit) async {
      try {
        await repository.updateCategory(event.category);
        emit(CategoriesSaved());
      } catch (e) {
        emit(CategoriesError(e.toString()));
      }
    });

    on<DeleteCategories>((event, emit) async {
      try {
        final Map<String, List<String>> byHotel = {};
        for (final c in event.categories) {
          if (!byHotel.containsKey(c.hotelId)) {
            byHotel[c.hotelId] = [];
          }
          byHotel[c.hotelId]!.add(c.id);
        }

        for (final entry in byHotel.entries) {
          await repository.deleteCategories(entry.key, entry.value);
        }
      } catch (e) {
        emit(CategoriesError(e.toString()));
      }
    });
  }
}
