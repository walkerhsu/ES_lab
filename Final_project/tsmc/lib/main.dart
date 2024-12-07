import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tsmc/redux/states/app_state.dart';
import 'package:tsmc/redux/reducers/app_reducer.dart';
import 'package:tsmc/BLE/ble_home_page.dart';
import 'package:tsmc/theme.dart';


void main() {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState(),
  );

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  
  const MyApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        home: const Scaffold(
          body: Center(
            child: BleSetup(),
          ),
        ),
        theme: AppTheme.darkTheme,
      ),
    );
  }
}