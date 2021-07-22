import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final bool loading;

  const LoadingWidget({Key key, this.loading}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> flips;
  Animation<double> inverseFlips;
  Animation<double> opacityHider;
  Tween<double> opacityTween = Tween(begin: 1.0, end: 0.0);

  final _zeroAngle = 1.57;
  final _frontAngle = 0.0001;

  List<String> loadings = [
    "Forbereder forbindelse",
    "Henter status oplysnigner",
    "Finder Kanaler",
    "Hej Joachim",
    "Appen bliver aldrig færdig"
  ];

  int counter = 0;
  bool opacityTransitionOver = false;
  String currentString = "Waiting..";
  String previousString = "Loading..";

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (opacityTransitionOver) {
                dispose();
              }
              //is loading still true?
              if (!widget.loading) {
                //Stop loading animation.
                opacityTransitionOver = true;
                opacityHider = opacityTween.animate(controller);
                controller.forward();
              } else {
                if (loadings.length > counter) {
                  setState(() {
                    previousString = currentString;
                    currentString = loadings[counter];
                  });
                } else {
                  counter = 0;
                  setState(() {
                    previousString = currentString;
                    currentString = loadings[counter];
                  });
                }
                counter++;
                controller.reset();
              }
            } else if (status == AnimationStatus.dismissed) {
              controller.forward();
            }
          });

    flips = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: _zeroAngle, end: _frontAngle), weight: 1),
      //  TweenSequenceItem( tween: Tween(begin: _frontAngle, end: _zeroAngle), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });

    inverseFlips = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: _frontAngle, end: _zeroAngle), weight: 1),
      //TweenSequenceItem( tween: Tween(begin: _zeroAngle, end: _frontAngle), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF3A008C),
      child: Stack(
        children: [
          Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _frontAngle)
              ..rotateX(flips.value),
            child: flipContainer(),
          ),
          Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _frontAngle)
              ..rotateX(inverseFlips.value),
            child: flipContainer2(),
          ),
        ],
      ),
    );
  }

  Widget flipContainer() {
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration:
          BoxDecoration(color: Color(0xFF3A008C).withOpacity(0.7), boxShadow: [
        BoxShadow(
          color: Color(0xFF3A008C).withAlpha(20),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3),
        )
      ]),
      alignment: Alignment.center,
      child: Text(currentString),
    );
  }

  Widget flipContainer2() {
    return Container(
      width: 200,
      //margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration:
          BoxDecoration(color: Color(0xFF3A008C).withOpacity(0.7), boxShadow: [
        BoxShadow(
          color: Color(0xFF3A008C).withAlpha(20),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3),
        )
      ]),
      alignment: Alignment.center,
      child: Text(previousString),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
