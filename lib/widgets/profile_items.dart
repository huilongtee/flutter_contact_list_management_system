import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final Color bgColor, borderColor;
  final double width, height, size;
  final int index;
  ProfileWidget({
    this.bgColor,
    this.borderColor,
    this.height,
    this.width,
    this.index,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    List<IconData> _icons = [
      Icons.phone,
      Icons.email,
      Icons.home,
      Icons.work,
    ];

    return Container(
      width: this.width,
      height: this.height,
      child: Icon(
        _icons[index],
        size: this.size,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: this.bgColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
