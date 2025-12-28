abstract class DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, int> stats;
  DashboardLoaded(this.stats);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
