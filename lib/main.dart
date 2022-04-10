import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Test',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double widthMin = 500;

  bool _startRestart = false;
  bool _endRestart = false;
  int _turns = 1;
  late bool _p1Active;
  late double deviceWidth;
  late double deviceHeight;
  late TargetPlatform device;
  late Orientation deviceOrientation;

  @override
  void initState() {
    _p1Active = true;
    super.initState();
  }

  void reset() async {
    setState(() {
      _turns = 1;
      _endRestart = true;
      _p1Active = true;
    });
  }

  Axis get _diretion {
    final device = Theme.of(context).platform;
    switch (device) {
      case TargetPlatform.android:
        return _orientation;
      case TargetPlatform.iOS:
        return _orientation;
      default:
        return (widthMin < MediaQuery.of(context).size.width)
            ? Axis.horizontal
            : Axis.vertical;
    }
  }

  Axis get _orientation {
    return deviceOrientation == Orientation.portrait
        ? Axis.vertical
        : Axis.horizontal;
  }

  void changePlayer() {
    setState(() {
      _p1Active = (_p1Active) ? false : true;
      if (_p1Active) ++_turns;
    });
  }

  Widget get _turnsText {
    return deviceOrientation == Orientation.portrait
        ? Text(
            'TURNS: $_turns',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TURN $_turns',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                ),
                child: InkWell(
                  child: const Text(
                    "RESTART",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => setState(() => _startRestart = true),
                ),
              ),
            ],
          );
  }

  Widget get _topOptions {
    return deviceOrientation == Orientation.portrait
        ? Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: InkWell(
                    child: const Text(
                      "RESTART",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () => setState(() => _startRestart = true),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _playerCard(bool isActive, Color color) {
    return Card(
      isActive: isActive,
      color: color,
      restart: _startRestart,
      onChange: () => changePlayer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceOrientation = MediaQuery.of(context).orientation;
    if (_startRestart && !_endRestart) reset();
    final _player1 = _playerCard(_p1Active, Colors.white);
    final _player2 = _playerCard(!_p1Active, Colors.yellow);
    if (_endRestart) {
      setState(() {
        _startRestart = false;
        _endRestart = false;
      });
    }
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.blue.shade900,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: _diretion,
          children: [
            _topOptions,
            _player1,
            _turnsText,
            _player2,
          ],
        ),
      ),
    );
  }
}

class Card extends StatefulWidget {
  const Card({
    Key? key,
    required this.isActive,
    required this.onChange,
    required this.color,
    required this.restart,
  }) : super(key: key);

  final void Function() onChange;
  final bool isActive;
  final bool restart;
  final Color color;

  @override
  _Card createState() => _Card();
}

class _Card extends State<Card> {
  List<int> _scores = [];

  late double _height;
  late double _width;
  int _count = 0;
  int _total = 0;
  bool _hasRestart = false;

  int get _maxCount {
    return (_scores.isNotEmpty) ? _scores.reduce(max) : 0;
  }

  @override
  void initState() {
    super.initState();
  }

  void get _setSize {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      final width = MediaQuery.of(context).size.width;
      setState(() {
        _height = width - 50;
        _width = width - 15;
      });
    } else {
      final height = MediaQuery.of(context).size.height;
      setState(() {
        _height = height - 15;
        _width = height - 70;
      });
    }
  }

  void setInitial() {
    setState(() {
      _scores.add(_count);
      _total += _count;
      _count = 0;
      _hasRestart = false;
    });
  }

  void reset() {
    setState(() {
      _count = 0;
      _total = 0;
      _scores = [];
      _hasRestart = true;
    });
  }

  Widget _getButton(String text, Function f) {
    return Container(
      width: _width / 6,
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Colors.red,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          onTap: () => setState(() => f()),
        ),
      ),
    );
  }

  Widget get _cardOption {
    return (widget.isActive)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _getButton("-", () => --_count),
                  _getButton("+", () => ++_count),
                ],
              ),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    _setSize;
    if (widget.restart) {
      if (!_hasRestart && _scores.isNotEmpty) reset();
      if (!widget.isActive) setState(() => _count = 0);
    } else if (!widget.isActive) {
      setInitial();
    }

    return Container(
      height: _height,
      width: _width,
      padding: const EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: widget.color,
        child: InkWell(
          onTap: () {
            if (widget.isActive) {
              setState(() => ++_count);
            } else {
              widget.onChange();
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: _width / 4,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.black,
                    ),
                  ),
                  child: Text(
                    '$_maxCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              (!widget.isActive)
                  ? Container()
                  : Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          width: 5.0,
                          color: Colors.red,
                        ),
                      ),
                      child: Container(
                        width: _width / 4,
                        color: Colors.blue,
                        child: Text(
                          '$_count',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ),
              Center(
                child: Text(
                  '$_total',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 80,
                  ),
                ),
              ),
              _cardOption,
            ],
          ),
        ),
      ),
    );
  }
}
