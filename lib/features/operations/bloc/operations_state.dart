// STATE
import 'package:ftrace_web/features/operations/model/operations_model.dart';

abstract class OperationsState {}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class ReceivingLogsLoaded extends OperationsState {
  final List<ReceivingModel> logs;
  ReceivingLogsLoaded(this.logs);
}

class StorageMovementsLoaded extends OperationsState {
  final List<KitchenStorageModel> movements;
  StorageMovementsLoaded(this.movements);
}

class DeletingOperations extends OperationsState {}

class OperationsError extends OperationsState {
  final String message;
  OperationsError(this.message);
}
