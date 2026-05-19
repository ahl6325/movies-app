import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final int id;
  final String mediaType;
  const DetailScreen({super.key, required this.id, required this.mediaType});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const _apiKey = '8bb1bc74dbccf6c2a6b98d61291633fd';
  Map<String, dynamic>? details;
  List cast = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final base = 'https://api.themoviedb.org/3/${widget.mediaType}/${widget.id}';
    final responses = await Future.wait([
      http.get(Uri.parse('$base?api_key=$_apiKey&language=fr-FR')),
      http.get(Uri.parse('$base/credits?api_key=$_apiKey&language=fr-FR')),
    ]);
    setState(() {
      details = jsonDecode(responses[0].body);
      cast = (jsonDecode(responses[1].body)['cast'] as List).take(10).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    final title = details!['title'] ?? details!['name'] ?? '';
    final overview = details!['overview'] ?? 'Aucune description.';
    final rating = (details!['vote_average'] ?? 0).toStringAsFixed(1);
    final year = (details!['release_date'] ?? details!['first_air_date'] ?? '').toString().length >= 4
        ? (details!['release_date'] ?? details!['first_air_date']).toString().substring(0, 4)
        : '';
    final genres = (details!['genres'] as List?)?.map((g) => g['name'] as String).toList() ?? [];
    final runtime = details!['runtime'] as int?;
    final seasons = details!['number_of_seasons'] as int?;
    final backdrop = details!['backdrop_path'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── IMAGE EN HAUT ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdrop != null)
                    CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w1280$backdrop',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[900]),
                    )
                  else
                    Container(color: Colors.grey[900]),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── TITRE ──
                  Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // ── NOTE / ANNÉE / DURÉE ──
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      if (year.isNotEmpty)
                        Text(year, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      if (runtime != null)
                        Text('${runtime ~/ 60}h ${runtime % 60}min',
                          style: const TextStyle(color: Colors.grey))
                      else if (seasons != null)
                        Text('$seasons saison${seasons > 1 ? 's' : ''}',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── BOUTONS My List / Play / Info ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: const [
                        Icon(Icons.add, color: Color.fromARGB(255, 183, 179, 179)),
                        SizedBox(height: 5),
                        Text("My List", style: TextStyle(color: Color.fromARGB(255, 205, 201, 201), fontSize: 12)),
                      ]),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text("Play", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      Column(children: const [
                        Icon(Icons.share_outlined, color: Color.fromARGB(255, 183, 179, 179)),
                        SizedBox(height: 5),
                        Text("Partager", style: TextStyle(color: Color.fromARGB(255, 205, 201, 201), fontSize: 12)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── GENRES ──
                  if (genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genres.map((g) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(g, style: const TextStyle(color: Colors.deepOrange, fontSize: 12)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── SYNOPSIS ──
                  const Text("Synopsis",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(overview,
                    style: const TextStyle(color: Color.fromARGB(255, 180, 180, 180), height: 1.6, fontSize: 14)),
                  const SizedBox(height: 24),

                  // ── ACTEURS ──
                  if (cast.isNotEmpty) ...[
                    const Text("Acteurs",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 115,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        itemBuilder: (_, i) {
                          final actor = cast[i];
                          final photo = actor['profile_path'];
                          return Container(
                            width: 75,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: photo != null
                                    ? CachedNetworkImageProvider(
                                        'https://image.tmdb.org/t/p/w185$photo')
                                    : null,
                                  child: photo == null
                                    ? const Icon(Icons.person, color: Colors.grey)
                                    : null,
                                ),
                                const SizedBox(height: 6),
                                Text(actor['name'] ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 10)),
                                Text(actor['character'] ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 9)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}