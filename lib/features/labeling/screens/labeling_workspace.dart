import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';
import '../state/labeling_cubit.dart';
import '../widgets/interactive_chart.dart';

class LabelingWorkspace extends StatelessWidget {
  const LabelingWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1D Signal Labeler'),
        actions: [
          // Expose actions to Load and Export
          BlocBuilder<LabelingCubit, LabelingState>(
            builder: (context, state) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Load CSV',
                    onPressed: () => context.read<LabelingCubit>().loadCsv(),
                  ),
                  if (state.signalData != null &&
                      state.signalData!.regions.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.save_alt),
                      tooltip: 'Export Labeled Data',
                      onPressed: state.status == LabelingStatus.exporting
                          ? null // Disable while exporting
                          : () => context.read<LabelingCubit>().exportLabels(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      // BlocConsumer allows us to rebuild the UI on state changes AND trigger side-effects like Snackbars
      body: BlocConsumer<LabelingCubit, LabelingState>(
        listener: (context, state) {
          if (state.status == LabelingStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == LabelingStatus.exported) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Labels exported successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == LabelingStatus.initial) {
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Select CSV File'),
                onPressed: () => context.read<LabelingCubit>().loadCsv(),
              ),
            );
          }

          if (state.status == LabelingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.signalData != null) {
            return Column(
              children: [
                // File Info Header
                Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Text(
                    'Active File: ${state.fileName ?? "Unknown"} | Data Points: ${state.signalData!.values.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                // The Interactive Chart
                const InteractiveChart(),

                const Divider(height: 1, thickness: 1),

                // List of Committed Regions
                Expanded(
                  child: state.signalData!.regions.isEmpty
                      ? const Center(
                          child: Text(
                            'Click and drag on the chart above to label regions.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.signalData!.regions.length,
                          itemBuilder: (context, index) {
                            final region = state.signalData!.regions[index];
                            return ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: getColorForClassId(region.classId),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(region.className),
                              subtitle: Text(
                                'Indices: ${region.startIndex} -> ${region.endIndex}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  context.read<LabelingCubit>().removeRegion(
                                    index,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
