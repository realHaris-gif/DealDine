import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/results_screen.dart';
import '../screens/restaurant_details_screen.dart';
import '../screens/deal_builder_screen.dart';
import 'package:flutter/material.dart';

abstract class Routes {
  static const String home = '/';
  static const String results = '/results';
  static const String restaurantDetails = '/restaurant-details';
  static const String dealBuilder = '/deal-builder';
}

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.results,
          name: 'results',
          builder: (context, state) => const ResultsScreen(),
        ),
        GoRoute(
          path: Routes.restaurantDetails,
          name: 'restaurant-details',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? '';
            return RestaurantDetailsScreen(restaurantId: id);
          },
        ),
        GoRoute(
          path: Routes.dealBuilder,
          name: 'deal-builder',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? '';
            return DealBuilderScreen(restaurantId: id);
          },
        ),
      ],
      
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Page not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}