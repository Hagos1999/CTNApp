/// Data model representing a single sensor reading from the PZEM-004T.
class SensorReading {
  final String id;
  final DateTime createdAt;
  final double voltage;
  final double current;
  final double power;
  final double energy;
  final double frequency;
  final double powerFactor;
  final String deviceId;
  final bool isMock;

  const SensorReading({
    required this.id,
    required this.createdAt,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energy,
    required this.frequency,
    required this.powerFactor,
    required this.deviceId,
    this.isMock = false,
  });

  /// Parse from Supabase row (JSON map)
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      voltage: _toDouble(json['voltage']),
      current: _toDouble(json['current']),
      power: _toDouble(json['power']),
      energy: _toDouble(json['energy']),
      frequency: _toDouble(json['frequency']),
      powerFactor: _toDouble(json['power_factor']),
      deviceId: json['device_id']?.toString() ?? '',
    );
  }

  /// Parse from Firebase Realtime Database snapshot
  factory SensorReading.fromFirebase(Map<String, dynamic> json, String deviceId) {
    return SensorReading(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['timestamp'] as num).toInt(),
            )
          : DateTime.now(),
      voltage: _toDouble(json['voltage']),
      current: _toDouble(json['current']),
      power: _toDouble(json['power']),
      energy: _toDouble(json['energy']),
      frequency: _toDouble(json['frequency']),
      powerFactor: _toDouble(json['power_factor']),
      deviceId: deviceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'voltage': voltage,
      'current': current,
      'power': power,
      'energy': energy,
      'frequency': frequency,
      'power_factor': powerFactor,
      'device_id': deviceId,
      'is_mock': isMock,
    };
  }

  /// Safely convert any numeric type to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a copy with modified fields
  SensorReading copyWith({
    String? id,
    DateTime? createdAt,
    double? voltage,
    double? current,
    double? power,
    double? energy,
    double? frequency,
    double? powerFactor,
    String? deviceId,
    bool? isMock,
  }) {
    return SensorReading(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      power: power ?? this.power,
      energy: energy ?? this.energy,
      frequency: frequency ?? this.frequency,
      powerFactor: powerFactor ?? this.powerFactor,
      deviceId: deviceId ?? this.deviceId,
      isMock: isMock ?? this.isMock,
    );
  }

  /// Generate a realistic mock reading with random variation.
  factory SensorReading.mock(String deviceId) {
    final rng = DateTime.now().millisecondsSinceEpoch;
    final random = _rngNext(rng);
    return SensorReading(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      voltage: 218.0 + (_rngNext(random * 3) % 20) - 5,
      current: 2.1 + ((_rngNext(random * 7) % 100) / 100.0) - 0.5,
      power: 420.0 + ((_rngNext(random * 11) % 200) - 80),
      energy: 12.345 + ((_rngNext(random * 13) % 1000) / 1000.0),
      frequency: 49.8 + ((_rngNext(random * 5) % 100) / 100.0),
      powerFactor: 0.82 + ((_rngNext(random * 17) % 30) / 100.0),
      deviceId: deviceId,
      isMock: true,
    );
  }

  static int _rngNext(int seed) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed;
  }

  @override
  String toString() =>
      'SensorReading(voltage: $voltage V, current: $current A, power: $power W, '
      'energy: $energy kWh, freq: $frequency Hz, pf: $powerFactor, device: $deviceId, mock: $isMock)';
}
