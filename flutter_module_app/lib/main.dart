import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const mainChannel = MethodChannel('flutter_method_channel_id');
bool shouldPopAppOnBack = false;
final routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    mainChannel.setMethodCallHandler(
      (call) async {
        if (call.method == 'shouldPopAppOnBack') {
          shouldPopAppOnBack = call.arguments as bool;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [routeObserver],
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Flutter Home'),
            settings: settings,
          );
        }
        if (settings.name == '/detail') {
          return CupertinoPageRoute(
            builder: (_) => const DummyView(text: 'Swipe back does not work'),
            settings: settings,
          );
        }
        if (settings.name == '/detail-no-animation') {
          return PageRouteBuilder(
            pageBuilder: (context, _, __) => const DummyView(text: 'Swipe back does not work'),
            settings: settings,
          );
        }
      },
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => SystemNavigator.pop(),
          icon: const Icon(Icons.arrow_back_ios_sharp),
        ),
      ),
      body: Container(
        color: Colors.grey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have tapped the button this many times:'),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/detail'),
                child: const Text('Navigate with CupertinoPageRoute'),
              ),
              Text('$_counter', style: Theme.of(context).textTheme.headline4),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DummyView extends StatefulWidget {
  const DummyView({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<DummyView> createState() => _DummyViewState();
}

class _DummyViewState extends State<DummyView> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    super.initState();
    log('initState');
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    log('dispose');
    super.dispose();
  }

  @override
  void didPush() {
    log('didPush');
    // Route was pushed onto navigator and is now topmost route.
  }

  @override
  void didPop() {
    log('didPop');
    // didPop is called before the popping animation
    // Covering route was popped off the navigator.
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope with a callback prevents iOS swipe back
    // To perform this before the popping animation, we should use RouteAware mixin with its didPop callback
    // But in this example, this is not possible to put the content of onWillPop in didPop since we perform async
    // instructions
    return WillPopScope(
      onWillPop: shouldPopAppOnBack
          ? () async {
              SystemNavigator.pop();
              return true;
            }
          : null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dummy view'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_sharp),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.text),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Go back'),
              ),
              ElevatedButton(
                onPressed: () {
                  shouldPopAppOnBack = false;
                  Navigator.of(context).pop();
                },
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
