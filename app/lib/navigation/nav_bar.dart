import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.pageIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BottomAppBar(
        padding: EdgeInsets.all(10),
        elevation: 0.0,
        shadowColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 60,
            color: Colors.white,
            child: Row(
              children: [
                navItem(
                  'assets/icons/home.png',
                  pageIndex == 0,
                  onTap: () => onTap(0),
                ),
                navItem(
                  'assets/icons/group.png',
                  pageIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 80),
                navItem(
                  'assets/icons/activity.png',
                  pageIndex == 2,
                  onTap: () => onTap(2),
                ),
                navItem(
                  'assets/icons/user.png',
                  pageIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(String icon, bool selected, {Function()? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          icon,
          color: selected ? Colors.green : Colors.green.withOpacity(0.4),
        ),
      ),
    );
  }
}
