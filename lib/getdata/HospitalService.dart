import 'package:http/http.dart' as http;
import 'package:data_collection/model/Hospitalmodel.dart';

class  HospitalService{
  //
  static const String url =
      'http://139.59.112.145/api/registration/helper/hospital';

  static Future<List<Division>> getAllData() async {
    try {
      final response = await http.get(url);
      if (200 == response.statusCode) {
        final List<Division> divitions = welcomeFromJson(response.body) as List<Division>;
        return divitions;
      } else {
        // ignore: deprecated_member_use
        return List<Division>();
      }
    } catch (e) {
      // ignore: deprecated_member_use
      return List<Division>();
    }
  }
}
