import 'package:flutter/material.dart';

import 'const.dart';
Container _tableDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ), );
  }

  Widget _tableItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(.2),
              child: Icon(icon, color: Colors.blue),
            ),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 100),
            Text(desc, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Padding(padding: const EdgeInsets.only(left: 50.0), child: Divider()),
      ],
    );
  }


Widget myImage() {
  return Container(
    height: 100,
    width: 100,
   child: Image.network(image1,fit: BoxFit.cover,),
    )
  ;
}

Widget myAppBar() {
  return Container(
    height: 150,
    width: double.infinity,
    color: Colors.blue,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Text(
          "My Profile",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}