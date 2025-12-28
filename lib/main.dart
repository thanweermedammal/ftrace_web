import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/router.dart';
import 'package:ftrace_web/features/auth/bloc/auth_bloc.dart';
import 'package:ftrace_web/features/auth/ui/login_page.dart';
import 'package:ftrace_web/features/hotels/bloc/hotel_bloc.dart';
import 'package:ftrace_web/features/hotels/data/hotel_repository.dart';
import 'package:ftrace_web/features/kitchen/bloc/kitchen_bloc.dart';
import 'package:ftrace_web/features/kitchen/data/kitchen_repository.dart';
import 'package:ftrace_web/features/users/bolc/users_bloc.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/data/dashboard-repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider(create: (_)=>DashboardRepository()),
        RepositoryProvider(create: (_)=> HotelRepository()),
        RepositoryProvider(create: (_)=>KitchenRepository()),
        RepositoryProvider(create: (_)=>UserRepository())
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(create: (context)=>DashboardBloc(context.read<DashboardRepository>())),
          BlocProvider(create: (context)=>HotelBloc(context.read<HotelRepository>())),
          BlocProvider(create: (context)=>KitchenBloc(context.read<KitchenRepository>())),
          BlocProvider(create: (context)=>UserBloc(context.read<UserRepository>())),
          // other blocs here
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'FTrace Web',
          theme: ThemeData(
            colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: router,
          // home: const LoginPage(),
        ),
      ),
    );
  }
}
