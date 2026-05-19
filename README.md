# 🎬 StreamVault — Netflix-like Movie App

A mobile application built with Flutter that displays real movies and TV shows 
using the TMDB (The Movie Database) API.

## 📱 Screenshots

<!-- Ajoute tes screenshots ici -->

## ✨ Features

- 🔥 Trending movies & TV shows from TMDB API
- 🎭 Infinite scroll — loads more content automatically
- 🖼️ Dynamic hero banner with real backdrop images
- 📄 Movie detail page with:
  - Title, rating, release year, runtime
  - Genres
  - Full synopsis
  - Cast with photos
- 🎨 Netflix-inspired dark UI design
- ⚡ Fast image loading with caching

## 🛠️ Tech Stack

- **Flutter** — UI framework
- **Dart** — programming language
- **TMDB API** — movie & TV data
- **http** — API requests
- **cached_network_image** — image caching

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- A free TMDB API key → [themoviedb.org](https://www.themoviedb.org)

### Installation

1. Clone the repository
   git clone https://github.com/TON_USERNAME/movies-app.git

2. Navigate to the project
   cd movies-app

3. Install dependencies
   flutter pub get

4. Add your TMDB API key
   In lib/services/movie_service.dart :
   static const _apiKey = 'YOUR_API_KEY_HERE';
   
   In lib/screens/detail_screen.dart :
   static const _apiKey = 'YOUR_API_KEY_HERE';

5. Run the app
   flutter run

## 📁 Project Structure

lib/
├── main.dart                  
├── models/
│   └── movie.dart             
├── services/
│   └── movie_service.dart     
└── screens/
    └── detail_screen.dart     

## 🔑 API

This app uses the [TMDB API](https://www.themoviedb.org/documentation/api).
Get your free API key at [themoviedb.org](https://www.themoviedb.org/settings/api).

## 📄 License

MIT License — feel free to use and modify.