import 'dart:async';

import 'package:example/time_plot.dart';
import 'package:flutter/material.dart';
import 'package:requests_limiter/requests_limiter.dart';

const int kMaxHistorySeconds = 10;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Requests Limiter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Requests Limiter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _resourceCounter = 0;
  int _tapCounter = 0;
  bool _haveAccess = true;
  final LimitsSet _limitsSet = LimitsSet(limits: <RateLimit>[
    RateLimit(timeMs: 1000, requestCount: 1),
    RateLimit(timeMs: 3000, requestCount: 2),
    // RateLimit(timeMs: 6000, requestCount: 3),
  ]);
  final Set<int> timeOfTap = {};

  final Set<int> timeOfRequest = {};

  late final Timer _haveAccessTimer;
  late final Timer _clearTimesTimer;

  @override
  void initState() {
    super.initState();

    _haveAccessTimer = Timer.periodic(
      const Duration(milliseconds: 32),
      (timer) {
        setState(() {
          _haveAccess = _limitsSet.haveAccess();
        });
      },
    );

    _clearTimesTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        final int timeLimit = DateTime.now().millisecondsSinceEpoch - kMaxHistorySeconds * 1000;

        timeOfTap.removeWhere((int time) => time < timeLimit);
        timeOfRequest.removeWhere((int time) => time < timeLimit);
      },
    );
  }

  @override
  void dispose() {
    _haveAccessTimer.cancel();
    _clearTimesTimer.cancel();
  }

  Future<void> _incrementCounter() async {
    setState(() => _tapCounter++);
    timeOfTap.add(DateTime.now().millisecondsSinceEpoch);

    await _limitsSet.waitAccess();
    timeOfRequest.add(DateTime.now().millisecondsSinceEpoch);
    _resourceRequest();
  }

  void _resourceRequest() => setState(() => _resourceCounter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Center(
              child: Text('You have sent this many requests:'),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$_tapCounter',
                  style: Theme.of(context).textTheme.headline4,
                  key: Key('$_resourceCounter'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LiveTimePlot(
                period: kMaxHistorySeconds,
                count: 500,
                values: timeOfTap,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('You have received data this many times:'),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$_resourceCounter',
                  style: Theme.of(context).textTheme.headline4,
                  key: Key('$_resourceCounter'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LiveTimePlot(
                period: kMaxHistorySeconds,
                count: 500,
                values: timeOfRequest,
              ),
            ),
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 80,
                width: 150,
                color: _haveAccess ? Colors.green.shade400 : Colors.red.shade400,
                child: Center(
                  child: Text(
                    _haveAccess ? 'Free' : 'Locked',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _incrementCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
