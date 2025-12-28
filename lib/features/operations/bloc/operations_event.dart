// EVENTS
import 'package:ftrace_web/features/operations/model/operations_model.dart';

abstract class OperationsEvent {}

class LoadReceivingLogs extends OperationsEvent {}

class LoadStorageMovements extends OperationsEvent {}
class DeleteOperations extends OperationsEvent {
  final List<ReceivingModel> operations;
  DeleteOperations(this.operations);
}

