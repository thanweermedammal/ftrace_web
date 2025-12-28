// user_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/side_bar.dart';
import 'package:ftrace_web/features/users/bolc/users_bloc.dart';
import 'package:ftrace_web/features/users/bolc/users_event.dart';
import 'package:ftrace_web/features/users/bolc/users_state.dart';
import 'package:ftrace_web/features/users/data/users_repository.dart';
import 'package:ftrace_web/features/users/ui/users_form_screen.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    return BlocProvider(
      create: (_) => UserBloc(UserRepository())..add(LoadUsers()),
      child:
    Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // 📱 MOBILE DRAWER
      drawer: isMobile
          ? const Drawer(
        child: Sidebar(),
      )
          : null,

      // ---------- TOP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,

        // 📱 Show menu icon ONLY on mobile
        leading: isMobile
            ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : null,

        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black),
        ),
      ),


      body: Column(
          children: [
            _filterBar(context),
            Expanded(child: _userTable()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  UserFormPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _filterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () =>
                context.read<UserBloc>().add(LoadUsers(status: 'Active')),
            child: const Text('Active'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () =>
                context.read<UserBloc>().add(LoadUsers(status: 'Inactive')),
            child: const Text('Inactive'),
          ),
        ],
      ),
    );
  }

  Widget _userTable() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoaded) {
          return ListView.separated(
            itemCount: state.users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final u = state.users[i];
              return ListTile(
                title: Text(u.name),
                subtitle: Text(u.email),
                trailing: Chip(
                  label: Text(u.status),
                  backgroundColor:
                  u.status == 'Active' ? Colors.green[100] : Colors.red[100],
                ),
              );
            },
          );
        }
        if (state is UserError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
