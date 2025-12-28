import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;

  DashboardBloc(this.repo) : super(DashboardLoading()) {
    on<LoadDashboard>((event, emit) async {
      try {
        final stats = await repo.calculateDashboardStats();
        emit(DashboardLoaded(stats));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}
