import 'package:flutter/material.dart';
import './introPage3.dart';

class IntroPage2 extends StatefulWidget {
  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage2> {
  TextEditingController _controller;
  bool _validateError = false;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF3D48EA), //0x4C0010EE
        bottomNavigationBar: bottomBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Mit fornavn er..",
                            style:
                                TextStyle(fontSize: 26, color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Hvad må vi kalde dig?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            )),
                      ],
                    ),
                    Divider(),
                    Container(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: new InputDecoration(
                          errorText: _validateError ? 'Navn er påkrævet' : null,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          hintText: 'Skriv navn her',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                        onSubmitted: (String value) async {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget bottomBar() {
    return BottomAppBar(
        color: Color(0xFF2F3BF2),
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
                          shape: BoxShape.circle, color: Colors.white60),
                    ),
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
    setState(() {
      _controller.text.isEmpty ? _validateError = true : _validateError = false;
    });
    if (_controller.text.isNotEmpty) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => IntroPage3(name: _controller.text)));
    }
  }
}
