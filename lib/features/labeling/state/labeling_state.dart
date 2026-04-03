part of 'labeling_cubit.dart';

enum LabelingStatus { initial, loading, loaded, error, exporting, exported }

class LabelingState {
  final LabelingStatus status;
  final SignalData? signalData;
  final String? fileName;

  // Temporary coordinates for when the user is actively dragging
  final int? currentDragStart;
  final int? currentDragEnd;

  final double zoomFactor;
  final bool isLabelingMode;
  final String? errorMessage;

  LabelingState({
    this.status = LabelingStatus.initial,
    this.signalData,
    this.fileName,
    this.currentDragStart,
    this.currentDragEnd,
    this.zoomFactor = 1.0, // Default to 1x zoom
    this.isLabelingMode = false,
    this.errorMessage,
  });

  LabelingState copyWith({
    LabelingStatus? status,
    SignalData? signalData,
    String? fileName,
    int? currentDragStart,
    int? currentDragEnd,
    double? zoomFactor,
    bool? isLabelingMode,
    String? errorMessage,
  }) {
    return LabelingState(
      status: status ?? this.status,
      signalData: signalData ?? this.signalData,
      fileName: fileName ?? this.fileName,
      // We use a specific check to allow nullifying the drag states
      currentDragStart: currentDragStart != -1 ? currentDragStart : null,
      currentDragEnd: currentDragEnd != -1 ? currentDragEnd : null,
      zoomFactor: zoomFactor ?? this.zoomFactor,
      isLabelingMode: isLabelingMode ?? this.isLabelingMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
