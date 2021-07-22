import 'package:flutter/material.dart';
import './introPage2.dart';

class IntroPage1 extends StatefulWidget {
  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6200EE),
      bottomNavigationBar: bottomBar(),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Vi klargører testen..",
                  style: TextStyle(fontSize: 26, color: Colors.white)),
              Divider(),
              Text("Inden vi kan begynde testen \n skal vi vide et par ting!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return BottomAppBar(
        color: Color(0xFF5900D9),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Container(
              //color: Colors.yellow,
              height: 10,
            )),
            Container(
              // color: Colors.green,
              width: 120.0,
              height: 56,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white60),
                    ),
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white60),
                    ),
                  ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  height: 40,
                  //   color: Colors.red,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: Color(0x22CCCCCC),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      'NÆSTE',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void _next() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => IntroPage2()));
  }
}
