import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      title: Text(
        "PDF Converter",
        style: TextStyle(fontSize: 24),
      ),
      actions: [
        GestureDetector(
          child: Container(
            margin: EdgeInsets.only(right: 20, top: 10),
            child: Icon(
              Icons.nights_stay_sharp,
              size: 28,
            ),
          ),
          onTap: () {},
        ),
        GestureDetector(
          child: Container(
            margin: EdgeInsets.only(right: 20, top: 10),
            child: Icon(
              Icons.settings,
              size: 28,
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(60);
}
