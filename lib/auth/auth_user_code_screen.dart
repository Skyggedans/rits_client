import 'package:flutter/material.dart';
import 'dart:math';

class AuthUserCodeScreen extends StatefulWidget {
  final String userCode;
  final String verificationUrl;
  final Duration expiresIn;

  AuthUserCodeScreen({
    Key key,
    @required this.userCode,
    @required this.verificationUrl,
    @required this.expiresIn,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthUserCodeScreenState();
}

class _AuthUserCodeScreenState extends State<AuthUserCodeScreen>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  String get verificationUrl => widget.verificationUrl;
  String get userCode => widget.userCode;
  Duration get duration => widget.expiresIn;
  String get timerString =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: duration);
    _animationController.reverse(
        from: _animationController.value == 0.0
            ? 1.0
            : _animationController.value);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorization'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Please navigate to',
              textAlign: TextAlign.center,
            ),
            Text(
              verificationUrl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'and enter the code displayed below:',
              textAlign: TextAlign.center,
            ),
            Text(
              userCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: Align(
                alignment: FractionalOffset.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget child) {
                            return CustomPaint(
                              painter: TimerPainter(
                                  animation: _animationController,
                                  backgroundColor: Color(0xff128750),
                                  color: Theme.of(context).accentColor),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: FractionalOffset.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Text(
                            //   "Count Down",
                            //   style: Theme.of(context).textTheme.subhead,
                            // ),
                            AnimatedBuilder(
                                animation: _animationController,
                                builder: (_, Widget child) {
                                  return Text(
                                    timerString,
                                    style: Theme.of(context).textTheme.display3,
                                  );
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  TimerPainter({this.animation, this.backgroundColor, this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
