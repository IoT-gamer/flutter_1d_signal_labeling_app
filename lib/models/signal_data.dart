import 'signal_region.dart';

class SignalData {
  final List<double> values;
  final List<SignalRegion> regions;

  SignalData(this.values, [this.regions = const []]);
}
