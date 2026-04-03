import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/labeling/screens/labeling_workspace.dart';
import 'features/labeling/state/labeling_cubit.dart';
import 'services/csv_parser_service.dart';
import 'services/export_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Labeler',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => LabelingCubit(CsvParserService(), ExportService()),
        child: const LabelingWorkspace(),
      ),
    );
  }
}
