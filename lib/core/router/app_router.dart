import 'package:go_router/go_router.dart';
import 'package:house_app/features/converter/presentation/converter_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ConverterScreen(),
    ),
  ],
);
