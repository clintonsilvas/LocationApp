import 'package:go_router/go_router.dart';
import 'package:locationapp/screens/home_screen.dart';
import 'package:locationapp/screens/entrega_form_screen.dart';
import '../models/entrega.dart';

final router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      name: 'home',

      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: '/entrega',
      name: 'entrega-form',
      builder: (context, state) {
        final entrega = state.extra as Entrega?;
        return EntregaFormScreen(entrega: entrega);
      },
    ),
  ],
);
