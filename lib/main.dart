import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini AI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gemini AI Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _controller;
  late GenerativeModel model;
  String geminiResponse = '';
  Stream<GenerateContentResponse>? responseStream = const Stream.empty();

  @override
  void initState() {
    _controller = TextEditingController();
    model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'apiKey', // Replace with your API key
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  labelText: 'Ask Gemini!',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                controller: _controller,
                onSubmitted: (value) async {
                  final content = [Content.text(_controller.text)];

                  setState(() {
                    geminiResponse = '';
                    responseStream = model.generateContentStream(content);
                  });
                },
              ),
              const SizedBox(height: 36),
              StreamBuilder<GenerateContentResponse>(
                stream: responseStream,
                builder: (BuildContext context, AsyncSnapshot<GenerateContentResponse> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasError) {
                    children = <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Stack trace: ${snapshot.stackTrace}'),
                      ),
                    ];
                  } else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        children = const <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(''),
                          ),
                        ];
                      case ConnectionState.waiting:
                        children = const <Widget>[
                          CircularProgressIndicator(),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Awaiting answer...'),
                          ),
                        ];
                      case ConnectionState.active:
                        geminiResponse = geminiResponse + (snapshot.data?.text ?? '');
                        children = <Widget>[
                          Text(geminiResponse),
                          const SizedBox(height: 12),
                          const CircularProgressIndicator(),
                        ];
                      case ConnectionState.done:
                        geminiResponse = geminiResponse + (snapshot.data?.text ?? '');
                        children = <Widget>[
                          Text(geminiResponse),
                        ];
                    }
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
