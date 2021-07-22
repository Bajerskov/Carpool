import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/settings.dart';

/* 
  Class responsible for reading, saving and creating a valid Agora token
*/
class TokenGen {
  int agorauid;
  final prefKey = 'token';

  //require Agora asigned user id to generate a valid token for this user.
  TokenGen({this.agorauid}) {
    _readToken();
  }

  //ToDo: error handling if http request fails
  Future<String> requestToken() async {
    // Sending a POST request
    dynamic url = "xxx";
    http.Response response = await http.post(url,
        body: {'channelname': Channel, 'agorauid': agorauid.toString()});

    String jsonResponse = response.body;

    Map<String, dynamic> jsonDecoded = jsonDecode(jsonResponse);

    String newToken = jsonDecoded[prefKey];

    return await _saveToken(newToken);
  }

  //save token in local system storage (key, value) pairs
  Future<String> _saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(prefKey, newToken);
    return newToken;
  }

  Future<String> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(prefKey) ?? null;

    return (value == null) ? requestToken() : value;
  }

  Future<String> get getToken async {
    return await _readToken();
  }
}
