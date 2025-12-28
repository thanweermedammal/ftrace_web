import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/features/operations/bloc/operations_event.dart';
import 'package:ftrace_web/features/operations/bloc/operations_state.dart';
import '../data/operations_repository.dart';

// BLOC
class OperationsBloc extends Bloc<OperationsEvent, OperationsState> {
  final OperationsRepository repository;

  OperationsBloc(this.repository) : super(OperationsInitial()) {
    on<LoadReceivingLogs>((event, emit) async {
      emit(OperationsLoading());
      await emit.forEach(
        repository.fetchReceivingLogs(),
        onData: (logs) => ReceivingLogsLoaded(logs),
        onError: (e, _) => OperationsError(e.toString()),
      );
    });

    on<LoadStorageMovements>((event, emit) async {
      emit(OperationsLoading());
      await emit.forEach(
        repository.fetchStorageMovements(),
        onData: (movements) => StorageMovementsLoaded(movements),
        onError: (e, _) => OperationsError(e.toString()),
      );
    });

    on<DeleteOperations>((event, emit) async {
      await repository.deleteOperationsAcrossHotels(event.operations);
    });
  }
}
