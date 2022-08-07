import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/person_model.dart';

// List of URLs for our persons
enum PersonUrl {
  person1,
  person2,
}

// create an extension to return the real URL string
// relative to the person
extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return "http://10.0.2.2:5500/lib/api/person1.json";
      case PersonUrl.person2:
        return "http://10.0.2.2:5500/lib/api/person2.json";
    }
  }
}

// Events definition
// Parent class
@immutable
abstract class LoadEvent {
  const LoadEvent();
}

@immutable
class LoadPersonEvent implements LoadEvent {
  final PersonUrl url;

  const LoadPersonEvent({required this.url}) : super();
}

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() =>
      "Fetch result (isRetrievedFromCache: $isRetrievedFromCache, persons = $persons";
}

class PersonBloc extends Bloc<LoadEvent, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonBloc() : super(null) {
    on<LoadPersonEvent>((event, emit) async {
      // retrieve the url from the input event
      final url = event.url;
      if (_cache.containsKey(url)) {
        // if the url is in the cache, then we retrieve the person
        // from cache
        final cachedPersons = _cache[url]!;
        final result = FetchResult(
          persons: cachedPersons,
          isRetrievedFromCache: true,
        );
        // produce a new state: every listener to the bloc
        // is updating with the new state
        emit(result);
      } else {
        // the person is not in cache and we retrieve it from server
        // with the url
        // and stock it in the cache
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result = FetchResult(
          persons: persons,
          isRetrievedFromCache: false,
        );
        emit(result);
      }
    });
  }
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));
