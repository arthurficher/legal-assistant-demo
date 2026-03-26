import 'package:flutter/material.dart';

class IconLogin extends StatelessWidget {
  final double size;
  const IconLogin({super.key, required this.size}) : assert(size>0) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.size,
      height: this.size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(this.size*0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 15)
          ),
        ],
      ),
      padding: EdgeInsets.all(this.size*0.15),
      child:  Center(
        child: Image.asset(
          'assets/icon/icon_app.png',
          width: this.size*0.6,
          height: this.size*0.6,
        )
      ),
    );
  }
}