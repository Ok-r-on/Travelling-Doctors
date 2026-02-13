import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:travelling_doctors/pages/doctor/docintern.dart';
import 'package:travelling_doctors/pages/doctor/homedoc.dart';
import 'package:travelling_doctors/pages/doctor/inventorydoc.dart';

import '../../auth/auth-service.dart';
import '../../logandreg/choosing_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<ScreenHiddenDrawer> _pages = [];
  final AuthService _authService = AuthService();

  final myTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white);

  @override
  void initState() {
    super.initState();

    _pages = [
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Home',
              baseStyle: myTextStyle,
              colorLineSelected: Colors.lightBlue.shade700,
              selectedStyle: myTextStyle),
          const DoctorHomePage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Inventory',
              baseStyle: myTextStyle,
              colorLineSelected: Colors.lightBlue.shade700,
              selectedStyle: myTextStyle),
          const InventoryPage()),
      ScreenHiddenDrawer(
          ItemHiddenMenu(
              name: 'Intern',
              baseStyle: myTextStyle,
              colorLineSelected: Colors.lightBlue.shade700,
              selectedStyle: myTextStyle),
          DoctorViewPage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      screens: _pages,
      backgroundColorMenu: const Color.fromARGB(1000, 66,110,124),
      initPositionSelected: 0,
      slidePercent: 40,
      verticalScalePercent: 90,
      enableCornerAnimation: true,
      enableScaleAnimation: true,
      contentCornerRadius: 10,
      isTitleCentered: true,
      actionsAppBar: [
        IconButton(
          icon: const Icon(Icons.logout, color: Color.fromARGB(1000,66,110,124),),
          onPressed: () {
            logout();
          },
        ),
      ],
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          spreadRadius: 2,
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(4, 0),
        )
      ],
      curveAnimation: Curves.easeInOut,
      isDraggable: true,
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
    Navigator.pop(context);
  }
}
