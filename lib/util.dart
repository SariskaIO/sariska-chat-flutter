import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

Future<String> fetchToken() async {
  final body = convert.jsonEncode(
      {"apiKey": "24926faa88ca145d7466c2e123aca790768002ff8faf338e29ca"});
  final headers = {"Content-Type": "application/json"};
  var url = 'https://api.sariska.io/api/v1/misc/get-presigned';
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var body = convert.jsonDecode(response.body);
    print(body);
    return body.token;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
