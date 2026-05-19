import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/movie.dart';
import 'services/movie_service.dart';
import 'screens/detail_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Movie? featured;
  List<Movie> popularMovies = [];
  List<Movie> popularTV = [];

  int _moviesPage = 1;
  int _tvPage = 1;
  bool _loadingMoreMovies = false;
  bool _loadingMoreTV = false;

  final ScrollController _moviesScroll = ScrollController();
  final ScrollController _tvScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();

    // Detect fin de liste Movies → charger plus
    _moviesScroll.addListener(() {
      if (_moviesScroll.position.pixels >= _moviesScroll.position.maxScrollExtent - 200) {
        _loadMoreMovies();
      }
    });

    // Detect fin de liste TV → charger plus
    _tvScroll.addListener(() {
      if (_tvScroll.position.pixels >= _tvScroll.position.maxScrollExtent - 200) {
        _loadMoreTV();
      }
    });
  }

  @override
  void dispose() {
    _moviesScroll.dispose();
    _tvScroll.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final results = await Future.wait([
      MovieService.getTrending(),
      MovieService.getPopularMovies(page: 1),
      MovieService.getPopularTV(page: 1),
    ]);
    setState(() {
      featured = results[0].isNotEmpty ? results[0].first : null;
      popularMovies = results[1];
      popularTV = results[2];
    });
  }

  Future<void> _loadMoreMovies() async {
    if (_loadingMoreMovies) return;
    _loadingMoreMovies = true;
    _moviesPage++;
    final more = await MovieService.getPopularMovies(page: _moviesPage);
    setState(() => popularMovies.addAll(more));
    _loadingMoreMovies = false;
  }

  Future<void> _loadMoreTV() async {
    if (_loadingMoreTV) return;
    _tvPage++;
    final more = await MovieService.getPopularTV(page: _tvPage);
    setState(() => popularTV.addAll(more));
    _loadingMoreTV = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── HERO ──
          SliverToBoxAdapter(child: _buildHero()),

          // ── POPULAR MOVIES ──
          SliverToBoxAdapter(child: _buildSectionTitle("Popular Movies")),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                controller: _moviesScroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularMovies.length + 1, // +1 pour le loader
                itemBuilder: (context, index) {
                  // Dernier item = loader
                  if (index == popularMovies.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.deepOrange, strokeWidth: 2),
                      ),
                    );
                  }
                  return _buildCard(popularMovies[index]);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ── POPULAR TV SHOWS ──
          SliverToBoxAdapter(child: _buildSectionTitle("Popular TV Shows")),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                controller: _tvScroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularTV.length + 1,
                itemBuilder: (context, index) {
                  if (index == popularTV.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Colors.deepOrange, strokeWidth: 2),
                      ),
                    );
                  }
                  return _buildCard(popularTV[index]);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── CARD ──
  Widget _buildCard(Movie movie) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => DetailScreen(id: movie.id, mediaType: movie.mediaType),
      )),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: movie.posterUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey[800]),
            errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
          ),
        ),
      ),
    );
  }

  // ── HERO ──
  Widget _buildHero() {
    return Stack(
      children: [
        SizedBox(
          height: 500,
          width: double.infinity,
          child: featured != null
            ? CachedNetworkImage(
                imageUrl: featured!.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[900]),
              )
            : Container(color: Colors.grey[900]),
        ),
        Container(
          height: 500,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: const [
                Icon(Icons.add, color: Color.fromARGB(255, 183, 179, 179)),
                SizedBox(height: 5),
                Text("My List", style: TextStyle(color: Color.fromARGB(255, 205, 201, 201))),
              ]),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () {
                  if (featured != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DetailScreen(id: featured!.id, mediaType: featured!.mediaType),
                    ));
                  }
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text("Play", style: TextStyle(color: Colors.white)),
              ),
              GestureDetector(
                onTap: () {
                  if (featured != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DetailScreen(id: featured!.id, mediaType: featured!.mediaType),
                    ));
                  }
                },
                child: Column(children: const [
                  Icon(Icons.info_outline, color: Color.fromARGB(255, 183, 179, 179)),
                  SizedBox(height: 5),
                  Text("Info", style: TextStyle(color: Color.fromARGB(255, 205, 201, 201))),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── TITRE SECTION ──
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("See All", style: TextStyle(color: Colors.deepOrange, fontSize: 14)),
        ],
      ),
    );
  }
}