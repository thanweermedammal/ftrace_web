import 'package:ftrace_web/features/auth/ui/login_page.dart';
import 'package:ftrace_web/features/dashboard/ui/dashboard_page.dart';
import 'package:ftrace_web/features/dishes/ui/dish_detail_page.dart';
import 'package:ftrace_web/features/dishes/ui/dish_form_page.dart';
import 'package:ftrace_web/features/dishes/ui/dishes_list_page.dart';
import 'package:ftrace_web/features/hotels/ui/hotel_form_page.dart';
import 'package:ftrace_web/features/hotels/ui/hotel_list_page.dart';
import 'package:ftrace_web/features/kitchen/ui/kitchen_form_page.dart';
import 'package:ftrace_web/features/kitchen/ui/kitchen_list_page.dart';
import 'package:ftrace_web/features/operations/ui/operations_page.dart';
import 'package:ftrace_web/features/products/ui/categories_page.dart';
import 'package:ftrace_web/features/products/ui/category_form_page.dart';
import 'package:ftrace_web/features/products/ui/product_detail_page.dart';
import 'package:ftrace_web/features/products/ui/product_form_page.dart';
import 'package:ftrace_web/features/products/ui/product_list_page.dart';
import 'package:ftrace_web/features/products/ui/supplier_form_page.dart';
import 'package:ftrace_web/features/products/ui/suppliers_page.dart';
import 'package:ftrace_web/features/kitchen/ui/kitchen_detail_page.dart';
import 'package:ftrace_web/features/kitchen/model/kitchen_model.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import 'package:ftrace_web/features/users/ui/users_detail_page.dart';
import 'package:ftrace_web/features/users/ui/users_form_screen.dart';
import 'package:ftrace_web/features/users/ui/users_list_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:ftrace_web/features/dishes/model/dish_model.dart';
import 'package:ftrace_web/features/products/model/category_model.dart';
import 'package:ftrace_web/features/products/model/supplier_model.dart';
import 'package:ftrace_web/features/products/model/product_model.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/hotels/ui/hotel_detail_page.dart';
import 'package:ftrace_web/core/widgets/main_layout.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => LoginPage()),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => DashboardPage()),
        GoRoute(path: '/hotels', builder: (_, __) => HotelListPage()),
        GoRoute(
          path: '/hotelsform',
          builder: (context, state) {
            final hotel = state.extra as HotelModel?;
            return HotelFormPage(hotel: hotel);
          },
        ),
        GoRoute(path: '/kitchen', builder: (_, __) => const KitchenListPage()),
        GoRoute(
          path: '/kitchenform',
          builder: (context, state) {
            final kitchen = state.extra as KitchenModel?;
            final hotelId = state.uri.queryParameters['hotelId'];
            return KitchenFormPage(kitchen: kitchen, hotelId: hotelId);
          },
        ),
        GoRoute(
          path: '/kitchendetail',
          builder: (context, state) {
            final kitchen = state.extra as KitchenModel;
            return KitchenDetailPage(kitchen: kitchen);
          },
        ),
        GoRoute(path: '/users', builder: (_, __) => const UserListPage()),
        GoRoute(
          path: '/usersform',
          builder: (context, state) {
            final user = state.extra as UserModel?;
            return UserFormPage(user: user);
          },
        ),
        GoRoute(
          path: '/operations',
          builder: (_, __) => const OperationsPage(),
        ),
        GoRoute(path: '/dishes', builder: (_, __) => const DishesListPage()),
        GoRoute(
          path: '/dishform',
          builder: (context, state) {
            final dish = state.extra as DishModel?;
            return DishFormPage(dish: dish);
          },
        ),
        GoRoute(
          path: '/dishdetail',
          builder: (context, state) {
            final dish = state.extra as DishModel;
            return DishDetailPage(dish: dish);
          },
        ),
        GoRoute(path: '/products', builder: (_, __) => const ProductListPage()),
        GoRoute(
          path: '/productform',
          builder: (context, state) {
            final product = state.extra as ProductModel?;
            return ProductFormPage(product: product);
          },
        ),
        GoRoute(
          path: '/productdetail',
          builder: (context, state) {
            final product = state.extra as ProductModel;
            return ProductDetailPage(product: product);
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (_, __) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/categoryform',
          builder: (context, state) {
            final category = state.extra as CategoryModel?;
            return CategoryFormPage(category: category);
          },
        ),
        GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersPage()),
        GoRoute(
          path: '/supplierform',
          builder: (context, state) {
            final supplier = state.extra as SupplierModel?;
            return SupplierFormPage(supplier: supplier);
          },
        ),
        GoRoute(
          path: '/hoteldetail',
          builder: (context, state) {
            final hotel = state.extra as HotelModel;
            return HotelDetailPage(hotel: hotel);
          },
        ),
        GoRoute(
          path: '/usersdetail',
          builder: (context, state) {
            final user = state.extra as UserModel;
            return UserDetailPage(user: user);
          },
        ),
      ],
    ),
  ],
);
