import 'package:expense_tracker/features/dashboard/features/home/repository/user_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logics/home_bloc.dart';
import '../logics/home_event.dart';
import '../logics/home_state.dart';
import '../repository/home_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: UserDataRepository().getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              'Failed to load user data.',
              style: TextStyle(color: theme.error),
            ),
          );
        }

        // Extract user data safely
        final uid = snapshot.data?['uid'] ?? '';
        final name = snapshot.data?['name'] ?? 'User';

        return BlocProvider(
          create: (_) => HomeBloc(homeRepository: HomeRepository())
            ..add(HomeInitialEvent(uid: uid)),
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeSuccess) {
                return RefreshIndicator(
                  onRefresh: () async {
                    BlocProvider.of<HomeBloc>(context)
                        .add(HomeReloadRequested(uid: uid));
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    children: [
                      _buildTopRow(theme, name),
                      const SizedBox(height: 30),
                      _buildCreditCard(theme, state.totalBalance, uid),
                    ],
                  ),
                );
              }

              return Center(
                child: Text(
                  'Error occurred. Please try again.',
                  style: TextStyle(color: theme.error),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreditCard(ColorScheme theme, double totalBalance, String uid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),

        // Add shadow
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(.5),
            blurRadius: 100,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: theme.onPrimary.withOpacity(.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: theme.onPrimary.withOpacity(.5),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'BDT ${totalBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: theme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${uid.substring(0, 4)} **** **** ${uid.substring(12, 16)}',
                style: TextStyle(
                  color: theme.onPrimary.withOpacity(0.7),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(
                'assets/icons/mastercard.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(ColorScheme theme, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                color: theme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                color: theme.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/icons/user.png',
            width: 35,
            height: 35,
            scale: 2,
          ),
        ),
      ],
    );
  }
}