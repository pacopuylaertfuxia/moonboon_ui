import 'package:equatable/equatable.dart';

class FoundMonitor extends Equatable {
  final String address;
  final String serialNumber;

  const FoundMonitor({
    required this.address,
    required this.serialNumber,
  });

  @override
  List<Object?> get props => [address, serialNumber];
}
