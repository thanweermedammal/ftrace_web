import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftrace_web/core/widgets/stat_card.dart';
import 'package:ftrace_web/core/widgets/top_bar.dart';
import 'package:ftrace_web/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:ftrace_web/features/dashboard/bloc/dashboard_event.dart';
import 'package:ftrace_web/features/dashboard/bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobileNav = width < 900;
    final isMobile = width < 600;

    return Column(
      children: [
        if (isMobileNav)
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.black),
            ),
          )
        else
          const TopBar(title: "Dashboard"),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DashboardLoaded) {
                  final s = state.stats;

                  int crossAxisCount = 3;
                  double aspectRatio = 1.6;

                  if (width < 800) {
                    crossAxisCount = 1;
                    aspectRatio = 2.8;
                  } else if (width < 1200) {
                    crossAxisCount = 2;
                    aspectRatio = 2.0;
                  }

                  final cards = [
                    StatCard(
                      icon: Icons.shopping_cart,
                      title: "Total Purchases",
                      value: s['totalPurchases']!,
                    ),
                    StatCard(
                      icon: Icons.error_outline,
                      title: "Expired Purchases",
                      value: s['expiredPurchases']!,
                    ),
                    StatCard(
                      icon: Icons.calendar_today,
                      title: "Expiry This Week",
                      value: s['expiryThisWeek']!,
                    ),
                    StatCard(
                      icon: Icons.checklist,
                      title: "Total Processes",
                      value: s['totalProcesses']!,
                    ),
                    StatCard(
                      icon: Icons.timer,
                      title: "Running Processes",
                      value: s['runningProcesses']!,
                    ),
                    StatCard(
                      icon: Icons.check_circle,
                      title: "Completed Processes",
                      value: s['completedProcesses']!,
                    ),
                  ];

                  return GridView.builder(
                    itemCount: cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (_, i) => cards[i],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ],
    );
  }
}
