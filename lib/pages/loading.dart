import 'package:flutter/material.dart';

class LoadingSpinner extends StatefulWidget {
  final bool loading;
  LoadingSpinner({this.loading});
  @override
  State<StatefulWidget> createState() => _LoadSpinnerState();
}

class _LoadSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Animation<double> _transition;
  final Color color = Colors.white;
  final double size = 100.0;
  final Duration duration = const Duration(milliseconds: 2000);
  bool loadingDone = false;
  bool completlydone = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration)
          ..addStatusListener((status) {
            if (completlydone) {
              _controller.stop(canceled: true);
              _animation = Tween(begin: -1.0, end: -1.0).animate(
                  CurvedAnimation(
                      parent: _controller, curve: Curves.easeInOut));
              _transition = _animation = Tween(begin: 1.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: _controller, curve: Curves.easeInOut));
              _controller.forward();
              print("Done! completydone");
              if (status == AnimationStatus.completed) {
                //_controller.reset();

              } else if (status == AnimationStatus.dismissed) {
                _controller.forward();
                print("Done! dismiss");
              }
            } else {
              if (!widget.loading) {
                _animation = Tween(begin: -1.0, end: -1.0).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeInOut));
                _transition = _animation = Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _controller, curve: Curves.easeInOut));
              }

              if (status == AnimationStatus.completed && !widget.loading) {
                _controller.reset();
                completlydone = true;
              } else if (status == AnimationStatus.completed) {
                _controller.reset();
              } else if (status == AnimationStatus.dismissed) {
                _controller.forward();
              }
            }
          })
          ..addListener(() => setState(() {}))
        //..repeat(reverse: true)
        ;
    _animation = Tween(begin: -1.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _transition = Tween(begin: 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Stack(
          children: [
            Center(
              child: Stack(
                children: List.generate(2, (i) {
                  return Transform.scale(
                    scale: (1.0 - i - _animation.value.abs()).abs(),
                    child: SizedBox.fromSize(
                        size: Size.square(size), child: _itemBuilder(i)),
                  );
                }),
              ),
            ),
            Center(
              child: Transform.scale(
                scale: (1.0 - 1 - _transition.value.abs()).abs(),
                child: SizedBox.fromSize(
                  size: Size.square(size),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.lightGreen,
                      semanticLabel: "something",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) => DecoratedBox(
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.6)));
}
