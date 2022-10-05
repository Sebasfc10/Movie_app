import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/providers/movies_provider.dart';

class MovieSlider extends StatefulWidget {
  const MovieSlider({ Key? key, required this.movies, this.title, required this.onNextPage }) : super(key: key);

  final List<Movies> movies;
  final String? title;
  final Function onNextPage;

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {

  final ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500){
        widget.onNextPage();
      }
      
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      child: Column(
        children: [
          
          if  ( this.widget.title != null )
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(this.widget.title! , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              itemBuilder: (BuildContext context, int index){
                
                return _MoviePoster(  widget.movies[index], '${ widget.title }-$index-${ widget.movies[index].id }' );

              },
            ),
          ),

        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {

  final Movies movie;
  final String heroId;
  const _MoviePoster( this.movie, this.heroId );
  
 
  @override
  Widget build(BuildContext context) {

    movie.heroId = heroId;


    return Container(
            width: 130,
            height: 190,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, 'details', arguments: movie),
                  child: Hero(
                    tag: movie.heroId!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        placeholder: AssetImage('assets/no-image.jpg'),
                        image: NetworkImage(movie.fullPosterImg),
                        width: 130,
                        height: 185,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                  SizedBox(
                    height: 0,
                  ),

                  Text(movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  )

              ],
     ),
    );
  }
}
