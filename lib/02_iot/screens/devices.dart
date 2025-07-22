class Device {
  final String id;
  final String name;
  final String status;

  Device({required this.id, required this.name, this.status = 'unknown'});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? 'unknown',
    );
  }
}
