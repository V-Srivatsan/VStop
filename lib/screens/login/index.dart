import 'package:flutter/material.dart';
import 'package:vstop/screens/sync/index.dart' as sync;
import 'form.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(child: LayoutBuilder(builder: (ctx, constraints) =>
        SingleChildScrollView( child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: Padding(
              padding: .symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: .min, spacing: 10,
                mainAxisAlignment: .center, crossAxisAlignment: .stretch,
                children: [
                  Image(image: AssetImage("assets/logo.png"), width: 75, height: 75),
                  Text("V-STOP", style: Theme.of(context).textTheme.displayLarge, textAlign: .center,),

                  SizedBox(height: 10),

                  LoginForm(onAuth: (ctx) => Navigator.pushReplacement(
                      ctx, MaterialPageRoute(builder: (_) => sync.Screen())
                  )),
                ],
              )
          )),
        ))
      ))
    );
  }
}
