import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SetupRouter extends GoRouter {
  SetupRouter({required this.routes, super.initialLocation}) : super(routes: routes);

  final List<GoRoute> routes;
}

final routerProvider = Provider.family<SetupRouter, List<GoRoute>>(
  (ref, routes) => SetupRouter(
    routes: routes,
  ),
);
