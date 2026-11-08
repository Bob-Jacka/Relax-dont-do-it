
//Model for saving in inner resources
final class MeasureModel {
  final double data;
  final String date;

  const MeasureModel({required this.data, required this.date});

  Map<String, Object?> toMap() {
    return {'data': data, 'date': date};
  }

  @override
  String toString() {
    return 'MeasureModel{data: $data, date: $date}';
  }
}
