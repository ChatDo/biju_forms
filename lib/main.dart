import 'dart:io' show ContentType, HttpServer, InternetAddress, Platform;

import 'package:biju_forms/appbar_biju.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database.dart';
import 'form_page.dart';
import 'network_overlay.dart';

late Database database;
late HttpServer server;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    databaseFactory = databaseFactoryFfi;
    sqfliteFfiInit();
  }
  database = await DatabaseService().database;

  // FULLSCREEN
  // SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forms Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NetworkOverlay networkOverlay;

  @override
  void initState() {
    networkOverlay = NetworkOverlay();
    HttpServer.bind(
      InternetAddress.anyIPv4,
      8080,
    ).then((value) async {
      server = value;
      await for (var request in server) {
        print("REQUEST");
        print(request.uri);
        if (request.uri.path == "/members") {
          var data = await database.query("person");
          String finalTable = "";
          for (var elem in data) {
            finalTable += '''
            <tr>
            <td> ${data.isEmpty ? "Empty" : elem['name']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['firstname']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['email']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['city']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['game_name']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['team_name']} </td>
            <td> ${data.isEmpty ? "Empty" : elem['lottery'] == "true" ? "OUI" : "NON"} </td>
            <td> ${data.isEmpty ? "Empty" : elem['tournament'] == "true" ? "OUI" : "NON"} </td>
            </tr>
              ''';
          }
          request.response.headers.contentType = ContentType("text", "html", charset: "utf-8");
          request.response.write('''
          <html>
          <style>
          table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
          }
          </style>
          <script>
          </script>
          <h1>
          <div id="data">
          <table style="width:100%">
          <tr>
          <th style="width:15%">Nom</th>
          <th style="width:15%">Prénom</th>
          <th style="width:15%">Email</th>
          <th style="width:15%">Ville</th>
          <th style="width:15%">Jeu</th>
          <th style="width:15%">Equipe</th>
          <th style="width:5%">Lotterie</th>
          <th style="width:5%">Tournoi</th>
          </tr>
          ${finalTable.isEmpty ? "" : finalTable.toString().replaceAll(RegExp("[[]]"), "")}
          </table>
          </div>
          </h1>
          </html>
          ''');
          request.response.close();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (networkOverlay.isVisible) {
          networkOverlay.hide();
        }
      },
      child: Scaffold(
        appBar: const BijuAppBar(
          title: "Stand BIJU",
        ),
        body: Stack(
          children: [
            Image.asset(
              "assets/background.jpg",
              fit: BoxFit.cover,
              width: screenWidth,
              height: screenHeight,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight / 4,
                        child: MaterialButton(
                          onPressed: () {
                            if (networkOverlay.isVisible) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FormPage(
                                  lottery: true,
                                  tournament: false,
                                ),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/lottery.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight / 4,
                        child: MaterialButton(
                          onPressed: () {
                            if (networkOverlay.isVisible) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FormPage(
                                  lottery: false,
                                  tournament: true,
                                ),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/tournament.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight / 4,
                        child: MaterialButton(
                          onPressed: () {
                            if (networkOverlay.isVisible) {
                              return;
                            } else {
                              networkOverlay.show(context);
                            }
                          },
                          child: Image.asset(
                            "assets/socials.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
