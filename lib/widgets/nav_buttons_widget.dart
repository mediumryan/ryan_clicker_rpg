import 'package:flutter/material.dart';

class NavButtonsWidget extends StatelessWidget {
  const NavButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.menu, size: 24.0), // Made icon larger
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }
}
