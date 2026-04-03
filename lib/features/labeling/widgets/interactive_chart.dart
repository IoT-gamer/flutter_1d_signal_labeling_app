import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/labeling_cubit.dart';
import 'signal_painter.dart';
import 'class_selector.dart';

class InteractiveChart extends StatelessWidget {
  const InteractiveChart({super.key});

  /// Converts a physical screen X coordinate to an array index
  int _getIndexFromX(double x, double width, int dataLength) {
    int index = ((x / width) * dataLength).round();
    return index.clamp(0, dataLength - 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelingCubit, LabelingState>(
      builder: (context, state) {
        if (state.status == LabelingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.signalData == null || state.signalData!.values.isEmpty) {
          return const Center(child: Text('Please load a CSV file.'));
        }

        final dataLength = state.signalData!.values.length;

        return Column(
          children: [
            // Mode Toggle UI
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.pan_tool),
                    label: Text('Scroll / Navigate'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.edit),
                    label: Text('Draw Labels'),
                  ),
                ],
                selected: {state.isLabelingMode},
                onSelectionChanged: (Set<bool> newSelection) {
                  context.read<LabelingCubit>().toggleMode(newSelection.first);
                },
              ),
            ),

            // The Scrollable Chart Area
            LayoutBuilder(
              builder: (context, constraints) {
                double canvasWidth = constraints.maxWidth * state.zoomFactor;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // Lock scrolling when in labeling mode!
                  physics: state.isLabelingMode
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  child: GestureDetector(
                    // ONLY trigger pan events if we are in labeling mode
                    onPanStart: state.isLabelingMode
                        ? (details) {
                            int index = _getIndexFromX(
                              details.localPosition.dx,
                              canvasWidth,
                              dataLength,
                            );
                            context.read<LabelingCubit>().updateDragSelection(
                              index,
                              index,
                            );
                          }
                        : null,
                    onPanUpdate: state.isLabelingMode
                        ? (details) {
                            int index = _getIndexFromX(
                              details.localPosition.dx,
                              canvasWidth,
                              dataLength,
                            );
                            int startIndex = state.currentDragStart ?? index;
                            context.read<LabelingCubit>().updateDragSelection(
                              startIndex,
                              index,
                            );
                          }
                        : null,
                    onPanEnd: state.isLabelingMode
                        ? (details) async {
                            if (state.currentDragStart != null &&
                                state.currentDragEnd != null) {
                              final selectedClass =
                                  await showClassSelectorDialog(context);
                              if (selectedClass != null) {
                                if (!context.mounted) return;
                                context.read<LabelingCubit>().commitRegion(
                                  selectedClass.name,
                                  selectedClass.id,
                                );
                              } else {
                                if (!context.mounted) return;
                                context
                                    .read<LabelingCubit>()
                                    .updateDragSelection(-1, -1);
                              }
                            }
                          }
                        : null,
                    child: Container(
                      width: canvasWidth,
                      height: 350,
                      color: Colors.grey[50],
                      child: CustomPaint(
                        painter: SignalPainter(
                          data: state.signalData!,
                          currentDragStart: state.currentDragStart,
                          currentDragEnd: state.currentDragEnd,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // The Zoom Control Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(Icons.zoom_out, color: Colors.grey),
                  Expanded(
                    child: Slider(
                      value: state.zoomFactor,
                      min: 1.0,
                      max: 10.0, // Safely supports 10x magnification
                      divisions: 90,
                      label: '${state.zoomFactor.toStringAsFixed(1)}x',
                      onChanged: (val) {
                        context.read<LabelingCubit>().updateZoom(val);
                      },
                    ),
                  ),
                  const Icon(Icons.zoom_in, color: Colors.grey),
                  const SizedBox(width: 16),
                  Text(
                    '${state.zoomFactor.toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
