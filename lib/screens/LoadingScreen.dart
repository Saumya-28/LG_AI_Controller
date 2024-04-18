import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lg_ai_controller/screens/HomeScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:particles_flutter/particles_flutter.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  @override
  void initState()
  {
    Future.delayed(Duration(seconds: 6),() async{
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: CupertinoColors.black,
      body: Stack(

        children: [
          // Particle background
          CircularParticle(
            key: UniqueKey(),
            awayRadius: 5,
            numberOfParticles: 160,
            speedOfParticles: 1,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            onTapAnimation: true,
            particleColor: Colors.white.withAlpha(150),
            awayAnimationDuration: Duration(milliseconds: 600),
            maxParticleSize: 2,
            isRandSize: true,
            isRandomColor: true,
            randColorList: [

              Colors.white.withAlpha(210),

            ],
            awayAnimationCurve: Curves.easeInOutBack,
            enableHover: true,
            hoverColor: Colors.white,
            hoverRadius: 5,
            connectDots: false, //not recommended
          ),
          // Centered Lottie animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/Animation.json',
                  width: 400,
                  height:  400,

                ),
                SizedBox(),
               Lottie.asset('assets/lottie/Animation1.json',
               width: 80,
               height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
