import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const CHANNEL = 'com.github.birros.flutter_vlc_demo/video';
const METHOD = 'play';
const DEFAULT_VIDEO_URI =
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter VLC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter VLC Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _uri;
  final _formKey = GlobalKey<FormState>();

  void _playVideo(String uri) {
    const platform = const MethodChannel(CHANNEL);
    try {
      platform.invokeMethod(METHOD, {
        'uri': uri,
      });
    } on PlatformException catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: DEFAULT_VIDEO_URI,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !(Uri.tryParse(value)?.hasAbsolutePath ?? false)) {
                          return 'Please enter valid uri';
                        }
                        return null;
                      },
                      onSaved: (value) => _uri = value,
                    ),
                    Container(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form!.validate()) {
                          form.save();
                          _playVideo(_uri!);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: Text('Play'.toUpperCase()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
