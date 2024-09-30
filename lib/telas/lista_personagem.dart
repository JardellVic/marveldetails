import 'package:flutter/material.dart';
import '../modelos/personagem.dart';
import '../servicos/api_mcu.dart';
import 'detalhes_personagem.dart';

class CharactersListScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback toggleTheme;

  const CharactersListScreen({
    super.key,
    required this.isDarkTheme,
    required this.toggleTheme,
  });

  @override
  _CharactersListScreenState createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  late Future<List<Character>> characters;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<Character> allCharacters = [];
  List<Character> filteredCharacters = [];
  int offset = 0;
  bool isLoadingMore = false;
  List<Character> recentCharacters = [];
  Set<int> loadedCharacterIds = {};

  @override
  void initState() {
    super.initState();
    fetchCharacters();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreCharacters();
      }
    });
  }

  Future<void> fetchCharacters({String searchTerm = ''}) async {
    setState(() {
      isLoadingMore = true;
    });

    characters = MarvelApi(
      '46fde35d90d75ec58d3c9f0ce0d90a94',
      '6ccce8c45d75167f24fedcde1314d444475bc1da',
    ).fetchCharacters(
        offset: offset,
        searchTerm: searchTerm,
        isSearch: searchTerm.isNotEmpty);

    final fetchedCharacters = await characters;

    setState(() {
      allCharacters = fetchedCharacters;
      loadedCharacterIds.clear();
      for (var character in allCharacters) {
        loadedCharacterIds.add(character.id);
      }
      isLoadingMore = false;
    });
  }

  Future<void> fetchMoreCharacters() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
        offset += 20;
      });

      final moreCharacters = await MarvelApi(
        '46fde35d90d75ec58d3c9f0ce0d90a94',
        '6ccce8c45d75167f24fedcde1314d444475bc1da',
      ).fetchCharacters(offset: offset);

      final uniqueCharacters = moreCharacters.where((character) {
        return !loadedCharacterIds.contains(character.id);
      }).toList();

      if (uniqueCharacters.isNotEmpty) {
        setState(() {
          allCharacters.addAll(uniqueCharacters);
          loadedCharacterIds
              .addAll(uniqueCharacters.map((character) => character.id));
        });
      } else {
        offset -= 20;
      }

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void updateRecentCharacters(Character character) {
    setState(() {
      recentCharacters.remove(character);
      recentCharacters.insert(0, character);
      if (recentCharacters.length > 20) {
        recentCharacters.removeLast();
      }
    });
  }

  Future<void> searchCharacters(String searchTerm) async {
    if (searchTerm.isNotEmpty) {
      final fetchedCharacters = await MarvelApi(
        '46fde35d90d75ec58d3c9f0ce0d90a94',
        '6ccce8c45d75167f24fedcde1314d444475bc1da',
      ).fetchCharacters(offset: 0, searchTerm: searchTerm, isSearch: true);

      setState(() {
        filteredCharacters = fetchedCharacters;
      });
    } else {
      setState(() {
        filteredCharacters = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MARVEL',
          style: TextStyle(
            fontFamily: 'Tungsten',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Todos'),
                Tab(text: 'Pesquisar'),
                Tab(text: 'Últimas Visitas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              allCharacters.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == allCharacters.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final character = allCharacters[index];
                            return GestureDetector(
                              onTap: () {
                                updateRecentCharacters(character);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CharacterDetailScreen(
                                        character: character),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(10),
                                child: Container(
                                  height: 310,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        ),
                                        child: Image.network(
                                          character.thumbnailUrl,
                                          height: 300,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              character.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              character.description.isNotEmpty
                                                  ? character.description
                                                              .length >
                                                          50
                                                      ? '${character.description.substring(0, 50)}...'
                                                      : character.description
                                                  : 'Sem descrição',
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Pesquisar personagem',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            searchCharacters(value);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredCharacters.length,
                          itemBuilder: (context, index) {
                            final character = filteredCharacters[index];
                            return GestureDetector(
                              onTap: () {
                                updateRecentCharacters(character);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CharacterDetailScreen(
                                        character: character),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(10),
                                child: Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          character.thumbnailUrl,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          character.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: recentCharacters.length,
                          itemBuilder: (context, index) {
                            final character = recentCharacters[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CharacterDetailScreen(
                                        character: character),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(10),
                                child: Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          character.thumbnailUrl,
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          character.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
