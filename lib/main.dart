import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/routes/app_router.dart';
import 'common/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String>(create: (_) => "Grotix Initializing..."),
      ],
      child: MaterialApp.router(
        title: 'Grotix',
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}