import 'package:auto_size_text/auto_size_text.dart';
import 'package:biju_forms/appbar_biju.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class FormPage extends StatefulWidget {
  bool lottery;
  bool tournament;
  FormPage({
    super.key,
    required this.lottery,
    required this.tournament,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController firstnameController = TextEditingController(text: "");
  TextEditingController usernameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  TextEditingController teamNameController = TextEditingController(text: "");
  TextEditingController gameNameController = TextEditingController(text: "");

  bool tournament = false;
  bool lottery = false;
  bool hasAccepted = false;

  callback(bool newValue, bool variable) {
    variable = newValue;
    setState(() {});
  }

  @override
  void initState() {
    tournament = widget.tournament;
    lottery = widget.lottery;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const BijuAppBar(
          title: 'S\'inscrire à la lotterie ou au tournoi',
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                maxHeight: MediaQuery.of(context).size.height + 100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InputField(
                    label: "Nom*",
                    controller: nameController,
                  ),
                  InputField(
                    label: "Prénom*",
                    controller: firstnameController,
                  ),
                  InputField(
                    label: "Email*",
                    controller: emailController,
                  ),
                  InputField(
                    label: "Téléphone*",
                    controller: phoneController,
                  ),
                  InputField(
                    label: "Ville*",
                    controller: cityController,
                  ),
                  if (tournament) ...[
                    InputField(
                      label: "Pseudo*",
                      controller: usernameController,
                    ),
                    InputField(
                      label: "Sur quel jeu*",
                      controller: gameNameController,
                    ),
                    InputField(
                      label: "Nom d'équipe*",
                      controller: teamNameController,
                    ),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: mCheckBox(
                          height: MediaQuery.of(context).size.width / 2,
                          text: "Je participe au tournoi",
                          callback: (value) {
                            setState(() {
                              tournament = value;
                            });
                          },
                          variable: tournament,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: mCheckBox(
                          height: MediaQuery.of(context).size.width / 2,
                          text: "Je participe à la lotterie",
                          callback: (value) {
                            setState(() {
                              lottery = value;
                            });
                          },
                          variable: lottery,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: mCheckBox(
                          height: MediaQuery.of(context).size.width / 2,
                          text: "J'accepte que mes données soient utilisées pour me contacter dans le cadre du tournoi ou de la lotterie*",
                          callback: (value) {
                            setState(() {
                              hasAccepted = value;
                            });
                          },
                          variable: hasAccepted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 70,
                    child: MaterialButton(
                      onPressed: () {
                        // TODO: CHECK IF EXISTS AND PATCH, ELSE INSERT
                        if (!canRegister()) {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  AlertDialog(title: Text("Erreur"), content: Text("Veuillez remplir tous les champs obligatoires")));
                          return;
                        }
                        // TODO: CHECK EMPTY FIELDS
                        // IF TOURNAMENT -> TEAM_NAME MANDATORY
                        database.query("person", where: "email = ?", whereArgs: [emailController.text]).then((value) {
                          print(value);
                          if (value.isNotEmpty) {
                            print("UPDATING");
                            print(value[0]);
                            database
                                .update(
                                    "person",
                                    {
                                      "name": (nameController.text.isEmpty) ? value[0]['name'] : nameController.text,
                                      "firstname": (firstnameController.text.isEmpty) ? value[0]['firstname'] : firstnameController.text,
                                      "username": (usernameController.text.isEmpty && tournament) ? value[0]['firstname'] : usernameController.text,
                                      "email": value[0]['email'],
                                      "phone": value[0]['phone'],
                                      "city": (cityController.text.isEmpty) ? value[0]['city'] : cityController.text,
                                      "lottery": "$lottery",
                                      "tournament": "$tournament",
                                      "team_name": (teamNameController.text.isEmpty && tournament) ? value[0]['team_name'] : teamNameController.text,
                                      "game_name": (gameNameController.text.isEmpty && tournament) ? value[0]['game_name'] : gameNameController.text,
                                      "registered_at": value[0]['registered_at'],
                                      "last_modified": "${DateTime.now()}"
                                    },
                                    where: "email = ? AND registered_at = ?",
                                    whereArgs: [emailController.text, value[0]['registered_at']])
                                .then((value) {
                              Navigator.of(context).pop();
                            }).catchError((error) {
                              print("GOT ERROR");
                              print(error);
                            });
                          } else {
                            database.insert("person", {
                              "name": nameController.text,
                              "firstname": firstnameController.text,
                              "username": (tournament) ? usernameController.text : "",
                              "email": emailController.text,
                              "phone": phoneController.text,
                              "city": cityController.text,
                              "lottery": "$lottery",
                              "tournament": "$tournament",
                              "team_name": (tournament) ? teamNameController.text : "",
                              "game_name": (tournament) ? gameNameController.text : "",
                              "registered_at": "${DateTime.now()}",
                              "last_modified": "${DateTime.now()}"
                            }).then((value) {
                              Navigator.of(context).pop();
                            }).catchError((error) {
                              print("GOT ERROR");
                              print(error);
                            });
                          }
                        });
                      },
                      color: Colors.black.withOpacity(0.8),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffff6b87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool canRegister() {
    if (!hasAccepted) {
      return false;
    }
    if (lottery &&
        (nameController.text.isEmpty ||
            firstnameController.text.isEmpty ||
            emailController.text.isEmpty ||
            phoneController.text.isEmpty ||
            cityController.text.isEmpty)) {
      return false;
    }
    if (tournament &&
        (nameController.text.isEmpty ||
            firstnameController.text.isEmpty ||
            emailController.text.isEmpty ||
            phoneController.text.isEmpty ||
            cityController.text.isEmpty ||
            usernameController.text.isEmpty ||
            gameNameController.text.isEmpty ||
            teamNameController.text.isEmpty)) {
      return false;
    }
    return true;
  }
}

class mCheckBox extends StatefulWidget {
  final String text;
  final Function(bool) callback;
  final double height;
  bool variable;

  mCheckBox({
    super.key,
    required this.text,
    required this.callback,
    required this.variable,
    required this.height,
  });

  @override
  State<mCheckBox> createState() => _mCheckBoxState();
}

class _mCheckBoxState extends State<mCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.variable,
          activeColor: const Color(0xffff6b87),
          onChanged: (value) {
            widget.callback(value!);
          },
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: widget.height,
          child: AutoSizeText(
            widget.text,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}

class InputField extends StatefulWidget {
  String label;
  TextEditingController controller;

  InputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 5),
      child: TextFormField(
        cursorColor: const Color(0xffff6b87),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: Colors.black.withOpacity(0.8),
            fontSize: 20,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xffff6b87),
              width: 2,
            ),
          ),
          border: const OutlineInputBorder(),
        ),
        controller: widget.controller,
      ),
    );
  }
}
