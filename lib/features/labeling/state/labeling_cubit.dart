import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/signal_data.dart';
import '../../../models/signal_region.dart';
import '../../../services/csv_parser_service.dart';
import '../../../services/export_service.dart';

part 'labeling_state.dart';

class LabelingCubit extends Cubit<LabelingState> {
  final CsvParserService _parserService;
  final ExportService _exportService;

  LabelingCubit(this._parserService, this._exportService)
    : super(LabelingState());

  // Load the CSV File
  Future<void> loadCsv() async {
    emit(state.copyWith(status: LabelingStatus.loading));
    try {
      final result = await _parserService.pickAndParseCsv();
      if (result != null) {
        emit(
          state.copyWith(
            status: LabelingStatus.loaded,
            signalData: result.data,
            fileName: result.fileName,
          ),
        );
      } else {
        emit(state.copyWith(status: LabelingStatus.initial)); // User canceled
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LabelingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Update the chart zoom level
  void updateZoom(double newZoom) {
    emit(state.copyWith(zoomFactor: newZoom));
  }

  // Handle active dragging on the chart
  void updateDragSelection(int startIndex, int endIndex) {
    emit(
      state.copyWith(currentDragStart: startIndex, currentDragEnd: endIndex),
    );
  }

  // Commit the dragged region as a permanent label
  void commitRegion(String className, int classId) {
    if (state.signalData == null ||
        state.currentDragStart == null ||
        state.currentDragEnd == null) {
      return;
    }

    // Ensure start is always less than end
    int start = state.currentDragStart!;
    int end = state.currentDragEnd!;
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    final newRegion = SignalRegion(
      startIndex: start,
      endIndex: end,
      className: className,
      classId: classId,
    );

    // Create a new list to ensure the state change is detected
    final updatedRegions = List<SignalRegion>.from(state.signalData!.regions)
      ..add(newRegion);
    final updatedData = SignalData(state.signalData!.values, updatedRegions);

    emit(
      state.copyWith(
        signalData: updatedData,
        currentDragStart: -1, // Reset drag state using our copyWith logic
        currentDragEnd: -1,
      ),
    );
  }

  void toggleMode(bool isLabeling) {
    // If we switch back to scrolling, clear any accidental partial drags
    emit(
      state.copyWith(
        isLabelingMode: isLabeling,
        currentDragStart: isLabeling ? state.currentDragStart : -1,
        currentDragEnd: isLabeling ? state.currentDragEnd : -1,
      ),
    );
  }

  void removeRegion(int index) {
    if (state.signalData == null) return;

    // Create a fresh copy of the regions list to ensure immutability
    final updatedRegions = List<SignalRegion>.from(state.signalData!.regions);

    // Safely remove the item if the index is valid
    if (index >= 0 && index < updatedRegions.length) {
      updatedRegions.removeAt(index);

      // Create a new SignalData object with the modified regions list
      final updatedData = SignalData(state.signalData!.values, updatedRegions);

      // Emit the new state
      emit(state.copyWith(signalData: updatedData));
    }
  }

  // Export the labeled data to a new CSV
  Future<void> exportLabels() async {
    if (state.signalData == null || state.fileName == null) return;

    emit(state.copyWith(status: LabelingStatus.exporting));
    try {
      await _exportService.exportLabeledData(
        state.signalData!,
        state.fileName!,
      );
      emit(state.copyWith(status: LabelingStatus.exported));

      // Briefly show exported status, then return to loaded
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: LabelingStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: LabelingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
