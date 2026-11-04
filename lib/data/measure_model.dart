class MeasureModel {
  final double data;
  final DateTime date;

  const MeasureModel({required this.data, required this.date});

  Map<String, Object?> toMap() {
    return {'data': data, 'date': date};
  }

  @override
  String toString() {
    return 'MeasureModel{data: $data, name: $date}';
  }
}
