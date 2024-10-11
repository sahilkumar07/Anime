import 'package:animeapp/api.dart';
import 'package:animeapp/FavoritesScreen.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Details extends StatefulWidget {
  final String titl;
  const Details({super.key, required this.titl});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  late Future<List<Anime>> futureAnime;
  Map<String, double> animeRatings = {}; 
  Map<String, bool> isFavorite = {}; 

  @override
  void initState() {
    super.initState();
    futureAnime = getAnime(widget.titl);
    _loadSavedRatings(); 
    _loadFavoriteStatus(); 
  }

  _loadSavedRatings() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sp.getKeys().forEach((key) {
        if (key.startsWith('animeRating_')) {
          animeRatings[key.replaceFirst('animeRating_', '')] =
              sp.getDouble(key) ?? 0.0;
        }
      });
    });
  }

  _loadFavoriteStatus() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> favoriteTitles = sp.getStringList('favoriteTitles') ?? [];
    setState(() {
      for (var title in favoriteTitles) {
        isFavorite[title] = true; 
      }
    });
  }

  _saveRating(String animeTitle, double rating) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setDouble('animeRating_$animeTitle', rating);
    setState(() {
      animeRatings[animeTitle] = rating; 
    });
  }

  _toggleFavorite(String animeTitle, Anime anime) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> favoriteTitles = sp.getStringList('favoriteTitles') ?? [];

    if (isFavorite[animeTitle] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$animeTitle is already in favorites')),
      );
    } else {
      favoriteTitles.add(animeTitle);
      await sp.setStringList('favoriteTitles', favoriteTitles);

      List<String> favoriteImages = sp.getStringList('favoriteImages') ?? [];
      List<String> favoriteAges = sp.getStringList('favoriteAges') ?? [];
      List<String> favoriteDescriptions =
          sp.getStringList('favoriteDescriptions') ?? [];

      favoriteImages.add(anime.image);
      favoriteAges.add(anime.age);
      favoriteDescriptions.add(anime.desc);

      sp.setStringList('favoriteImages', favoriteImages);
      sp.setStringList('favoriteAges', favoriteAges);
      sp.setStringList('favoriteDescriptions', favoriteDescriptions);

      setState(() {
        isFavorite[animeTitle] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$animeTitle added to favorites')),
      );
    }
  }

  void _viewFavorites() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Favorite()),
    );
    if (result == true) {
      setState(() {
        _loadFavoriteStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Webtoon Lists",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: _viewFavorites, 
          ),
        ],
      ),
      body: FutureBuilder<List<Anime>>(
        future: futureAnime,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.separated(
                itemCount: diffanime.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color.fromARGB(255, 25, 25, 112),
                  thickness: 2,
                  height: 30,
                ),
                itemBuilder: (context, index) {
                  String animeTitle = diffanime[index].title.toUpperCase();
                  double currentRating = animeRatings[animeTitle] ?? 0.0;
                  bool isAnimeFavorite = isFavorite[animeTitle] ?? false;

                  return Container(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            diffanime[index].image,
                            height: 400,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            animeTitle,
                            style: GoogleFonts.borel(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Age Rating: " + diffanime[index].age,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          diffanime[index].desc,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 10),
                        RatingBar.builder(
                          initialRating: currentRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            _saveRating(animeTitle, rating); 
                          },
                        ),
                        Text(
                          'Rating: $currentRating / 5',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                isAnimeFavorite ? Colors.red : Colors.blue),
                          ),
                          onPressed: () {
                            _toggleFavorite(animeTitle, diffanime[index]);
                          },
                          child: Text(
                            isAnimeFavorite
                                ? 'Already Added'
                                : 'Add to Favourites',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
