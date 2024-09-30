import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../modelos/personagem.dart';

class MarvelApi {
  final String publicKey;
  final String privateKey;

  MarvelApi(this.publicKey, this.privateKey);

  String generateMD5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<List<Character>> fetchCharacters(
      {String searchTerm = '',
      required int offset,
      bool isSearch = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Tentar buscar personagens em cache
    String cacheKey = 'characters_$offset';
    if (!isSearch) {
      String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final data = json.decode(cachedData);
        List<Character> characters = (data['data']['results'] as List)
            .map((character) => Character.fromJson(character))
            .toList();
        return characters;
      }
    }

    // Caso não haja cache, fazer a chamada à API
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String hash = generateMD5('$timestamp$privateKey$publicKey');

    String url;

    if (isSearch) {
      url =
          'https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&limit=20&offset=$offset&nameStartsWith=${Uri.encodeComponent(searchTerm)}';
    } else {
      url =
          'https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&limit=20&offset=$offset';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Armazenar o resultado no cache
      if (!isSearch) {
        prefs.setString(cacheKey, response.body);
      }

      List<Character> characters = (data['data']['results'] as List)
          .map((character) => Character.fromJson(character))
          .toList();
      return characters;
    } else {
      throw Exception('Falha ao carregar personagens');
    }
  }
}
