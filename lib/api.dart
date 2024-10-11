import 'dart:convert';
import 'package:http/http.dart' as http;

class Category {
  String title;
  String image;
  String desc;

  Category({
    required this.title,
    required this.image,
    required this.desc,
  });

  factory Category.fromJson(Map<String, dynamic> json, String categoryTitle) {
    return Category(
      title: categoryTitle,
      image: json['attributes']['posterImage']['small'] ?? '',
      desc: json['attributes']['synopsis'] ?? 'No description available',
    );
  }
}

List<Category> diffcat = [];

List<String> ttl = [
  "isekai",
  "mecha",
  "josei",
  "seinen",
  "kodomomuke",
];

Future<List<Category>> getCategories() async {
  diffcat.clear();

  for (String category in ttl) {
    String link =
        "https://kitsu.io/api/edge/anime?page[limit]=1&filter[categories]=$category";

    try {
      print('Fetching data for category: $category');
      final response = await http.get(Uri.parse(link));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        if (data['data'] != null) {
          for (var i in data['data']) {
            Category cat = Category.fromJson(i, category);
            diffcat.add(cat);
          }
        } else {
          print('No data found for category: $category');
        }
      } else {
        print(
            'Failed to load data for category: $category, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching category $category: $e');
    }
  }

  return diffcat;
}

class Anime {
  String title;
  String image;
  String desc;
  String age;

  Anime({
    required this.title,
    required this.image,
    required this.desc,
    required this.age,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      title: json['attributes']['titles']['en'] ?? 'No title',
      image: json['attributes']['posterImage']['original'] ?? '',
      desc: json['attributes']['synopsis'] ?? 'No description available',
      age: json['attributes']['ageRatingGuide'] ?? 'Not rated',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'desc': desc,
      'age': age,
    };
  }
}

List<Anime> diffanime = [];

Future<List<Anime>> getAnime(String category) async {
  diffanime.clear();

  String link = "https://kitsu.io/api/edge/anime?filter[categories]=$category";

  try {
    print('Fetching anime data for category: $category');
    final response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      if (data['data'] != null) {
        for (var i in data['data']) {
          Anime anime = Anime.fromJson(i);
          diffanime.add(anime);
        }
      } else {
        print('No anime data found for category: $category');
      }
    } else {
      print(
          'Failed to load anime data for category: $category, Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching anime for category $category: $e');
  }

  return diffanime;
}
