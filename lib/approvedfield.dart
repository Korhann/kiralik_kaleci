import 'package:hive/hive.dart';
part 'approvedfield.g.dart';

@HiveType(typeId: 0)
class ApprovedField {
  @HiveField(0)
  final List<String> fields;

  ApprovedField({
    required this.fields,
  });

  static Future<void> approvedFields() async {
    var localDb = await Hive.openBox<ApprovedField>('approved_fields');

    await localDb.clear();

    final List<ApprovedField> fields = [
      ApprovedField(
        fields: ['Hasan Özaydın Halı Saha','Şampiyon Halı Saha']
      )
    ];

    for (var field in fields) {
      await localDb.add(field);
    }
  }
}