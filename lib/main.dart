import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/person_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // BlocProvider provides an instance of the bloc
      // It wraps the HomePage inside a buildContext that has acces to the bloc
      // created with the create parameter
      home: BlocProvider(
        create: (context) => PersonBloc(),
        child: const MyHomePage(title: 'Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // read the context bloc
                    context.read<PersonBloc>().add(
                          const LoadPersonEvent(
                            url: PersonUrl.person1,
                          ),
                        );
                  },
                  child: const Text("Load json #1"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonEvent(
                            url: PersonUrl.person2,
                          ),
                        );
                  },
                  child: const Text("Load json #2"),
                ),
              ],
            ),
            BlocBuilder<PersonBloc, FetchResult?>(
                buildWhen: ((previous, current) {
              return previous?.persons != current?.persons;
            }), builder: ((context, state) {
              final persons = state?.persons;
              if (persons == null) {
                return const Text("No data");
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                      );
                    },
                  ),
                );
              }
            }))
          ],
        ));
  }
}

// create an extension on Iterable since it doessn't have
// the index property []
extension Index<T> on Iterable<T> {
  T? operator [](index) => length > index ? elementAt(index) : null;
}
