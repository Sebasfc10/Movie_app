import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:peliculas/heipers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_response.dart';
// ignore: avoid_print
class MoviesProvider extends ChangeNotifier{

  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '418d274a98b894361e863f09771880c7';
  String _language = 'es-ES';

  List<Movies> onDisplayMovies = [];
  List<Movies> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
    //onValue: ( _ ) {}
  );

  final StreamController<List<Movies>> _suggestionStreamController = new StreamController.broadcast();
  Stream<List<Movies>> get suggestionStream => this._suggestionStreamController.stream;

  MoviesProvider() {
    
    print('MoviesProvider inicializado');

    getOnDisplayMovie();
    getPopularMovies();
  }

  Future <String> _getJsonData( String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovie() async {
    final jsonData = await this._getJsonData('3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    
    notifyListeners();
  }

  getPopularMovies() async {

    _popularPage++;

    final jsonData = await this._getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [ ...popularMovies, ...popularResponse.results ];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast ( int movieId ) async {
    
    if( moviesCast.containsKey(movieId) ) return moviesCast[movieId]!;


    final jsonData = await this._getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson( jsonData );

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movies>> searchMovie (String query) async {

    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson( response.body );

    return searchResponse.results;
  }

  void getSuggestionByQuery( String searchTerm ){
    debouncer.value = '';
    debouncer.onValue = (value) async {

      final result = await this.searchMovie(value);
      this._suggestionStreamController.add(result);

    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) { 
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then(( _ ) => timer.cancel());
  }
  
}