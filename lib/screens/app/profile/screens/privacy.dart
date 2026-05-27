import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Policy")),
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: .symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: .min, spacing: 15,
            children: [

              Section(title: "How does V-Stop retrieve data?", content: Text(retrieval)),

              Divider(),

              Section(title: "What about my credentials?", content: Text(security)),

              Divider(),

              Section(title: "What data is collected?", content: Text(collection)),

              Divider(),

              Section(title: "I don't want to share my marks!", content: Text(encryption)),

            ],
          ),
        ),
      )),
    );
  }
}


class Section extends StatelessWidget {
  final String title;
  final Widget content;
  const Section({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        content
      ],
    );
  }
}


const
retrieval = """
V-Stop interacts with V-TOP in the background, forwarding your credentials to it. Once logged in, it retrieves your data and stores it locally.
""",
security = """
V-Stop stores your credentials locally on your device, encrypted using the Android Keychain or iOS Keystore system. This means that your credentials can only be accessed in-app, and it does not leave the app except for authenticating on V-TOP.
""",
collection = """
V-Stop only collects your total marks of each class for grade calculation. No other details are sent, not even the course, or individual assignment marks. 
""",
encryption = """
V-Stop encrypts your identity using SHA-256 with unique identifiers and stores it locally. This means that not even the developer will have access to your uploaded marks even if the overall class mean and deviation is available.
""";