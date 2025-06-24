import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopware_products/presentation/bloc/product_bloc.dart';
import 'package:shopware_products/presentation/pages/product_list_page.dart';

import 'injection/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Shopware App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => getIt<ProductBloc>(),
        child: ProductListPage(),
      ),
    );
  }
}
