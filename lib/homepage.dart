import 'package:animeapp/api.dart';
import 'package:animeapp/details.dart';
import 'package:animeapp/FavoritesScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: const Text(
          "Webtoon Genres",
          style: TextStyle(color: Colors.white),
        )),
        actions: [
          IconButton.filled(
              color: Colors.pink,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Favorite()));
              },
              icon: Icon(Icons.favorite))
        ],
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
      ),
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.separated(
                itemCount: diffcat.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color.fromARGB(255, 25, 25, 112),
                  thickness: 2,
                  height: 30,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Details(titl: diffcat[index].title)));
                    },
                    child: Card(
                      color: Colors.grey.shade400,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                diffcat[index].image,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
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
                                diffcat[index].title.toUpperCase(),
                                style: GoogleFonts.borel(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              diffcat[index].desc,
                              maxLines:
                                  4, 
                              overflow: TextOverflow
                                  .ellipsis, 
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors
                                    .black, 
                              ),
                              textAlign: TextAlign
                                  .justify, 
                            ),
                          ],
                        ),
                      ),
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
