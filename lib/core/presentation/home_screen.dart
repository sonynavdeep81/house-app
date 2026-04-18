import 'package:flutter/material.dart';
import 'package:house_app/features/brick_calculator/presentation/brick_screen.dart';
import 'package:house_app/features/cement_calculator/presentation/cement_screen.dart';
import 'package:house_app/features/converter/presentation/converter_screen.dart';
import 'package:house_app/features/cost_estimator/presentation/cost_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = [
    ConverterScreen(),
    BrickScreen(),
    CementScreen(),
    CostScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.straighten),
            label: 'Converter',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work),
            label: 'Bricks',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop),
            label: 'Cement',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_rupee),
            label: 'Cost',
          ),
        ],
      ),
    );
  }
}
