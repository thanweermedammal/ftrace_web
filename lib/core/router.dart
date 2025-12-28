import 'package:ftrace_web/features/auth/ui/login_page.dart';
import 'package:ftrace_web/features/dashboard/ui/dashboard_page.dart';
import 'package:ftrace_web/features/hotels/ui/hoteL_form_page.dart';
import 'package:ftrace_web/features/hotels/ui/hotel_list_page.dart';
import 'package:ftrace_web/features/kitchen/ui/kitchen_form_page.dart';
import 'package:ftrace_web/features/kitchen/ui/kitchen_list_page.dart';
import 'package:ftrace_web/features/users/ui/users_form_screen.dart';
import 'package:ftrace_web/features/users/ui/users_list_screen.dart';
import 'package:go_router/go_router.dart';
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => LoginPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => DashboardPage()),
    GoRoute(path: '/hotels', builder: (_, __) => HotelListPage()),
    GoRoute(path: '/hotelsform', builder: (_, __) => HotelFormPage()),
    // GoRoute(path: '/kitchen', builder: (_, __) => KitchenListPage()),
    // GoRoute(path: '/kitchenform', builder: (_, __) => KitchenFormPage()),
    GoRoute(path: '/users', builder: (_, __) => UserListPage()),
    GoRoute(path: '/usersform', builder: (_, __) => UserFormPage()),
  ],
);
