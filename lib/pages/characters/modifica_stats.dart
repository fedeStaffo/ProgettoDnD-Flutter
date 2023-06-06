import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificaStatsFragment extends StatefulWidget {
  final String? nome;
  final String? classe;
  final String? razza;
  final String? utenteId;

  ModificaStatsFragment({
    this.nome,
    this.classe,
    this.razza,
    this.utenteId,
  });

  @override
  _ModificaStatsFragmentState createState() => _ModificaStatsFragmentState();
}

class _ModificaStatsFragmentState extends State<ModificaStatsFragment> {
  String? campoSelezionato;
  String? statoSelezionato;
  TextEditingController modificheController = TextEditingController();

  List<String> campiPersonaggio = [
    'Forza',
    'Destrezza',
    'Costituzione',
    'Intelligenza',
    'Saggezza',
    'Carisma',
    'Vita',
    'VitaMax',
    'Stato',
    'Classe Armatura',
  ];

  List<String> statiPersonaggio = [
    'Accecato',
    'Affascinato',
    'Afferrato',
    'Assordato',
    'Avvelenato',
    'Incapacitato',
    'Invisibile',
    'Paralizzato',
    'Pietrificato',
    'Privo di sensi',
    'Prono',
    'Spaventato',
    'Stordito',
    'Trattenuto',
    'Nessuno',
  ];

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Statistiche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: campoSelezionato,
              onChanged: (newValue) {
                setState(() {
                  campoSelezionato = newValue;
                });
              },
              items: campiPersonaggio.map((campo) {
                return DropdownMenuItem<String>(
                  value: campo,
                  child: Text(campo),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Campo da modificare',
              ),
            ),
            const SizedBox(height: 16),
            if (campoSelezionato == 'Vita' ||
                campoSelezionato == 'VitaMax' ||
                campoSelezionato == 'Forza' ||
                campoSelezionato == 'Destrezza' ||
                campoSelezionato == 'Costituzione' ||
                campoSelezionato == 'Intelligenza' ||
                campoSelezionato == 'Saggezza' ||
                campoSelezionato == 'Carisma' ||
                campoSelezionato == 'Classe Armatura')
              TextFormField(
                controller: modificheController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Modifiche',
                  errorText: errorMessage,
                ),
              ),
            if (campoSelezionato == 'Stato')
              DropdownButtonFormField<String>(
                onChanged: (newValue) {
                  setState(() {
                    statoSelezionato = newValue;
                  });
                },
                items: statiPersonaggio.map((stato) {
                  return DropdownMenuItem<String>(
                    value: stato,
                    child: Text(stato),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Modifiche',
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorMessage = null;
                });

                if (campoSelezionato != null &&
                    modificheController.text.isNotEmpty) {
                  final String campo = campoSelezionato!;
                  final String modifiche = modificheController.text.trim();

                  if (campo == 'Vita' ||
                      campo == 'VitaMax' ||
                      campo == 'Forza' ||
                      campo == 'Destrezza' ||
                      campo == 'Costituzione' ||
                      campo == 'Intelligenza' ||
                      campo == 'Saggezza' ||
                      campo == 'Carisma' ||
                      campo == 'Classe Armatura') {
                    final int modificheValue = int.tryParse(modifiche) ?? 0;

                    if (modificheValue < 0) {
                      setState(() {
                        errorMessage =
                        'Inserisci un valore maggiore o uguale a zero';
                      });
                      return;
                    }

                    if (campo == 'Forza' ||
                        campo == 'Destrezza' ||
                        campo == 'Costituzione' ||
                        campo == 'Intelligenza' ||
                        campo == 'Saggezza' ||
                        campo == 'Carisma') {
                      if (modificheValue < 0 || modificheValue > 20) {
                        setState(() {
                          errorMessage =
                          'Inserisci un valore compreso tra 0 e 20';
                        });
                        return;
                      }
                    }

                    if (campo == 'VitaMax' && modificheValue <= 0) {
                      setState(() {
                        errorMessage = 'Inserisci un valore maggiore di zero';
                      });
                      return;
                    }
                  }

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Conferma'),
                        content: const Text(
                            'Sei sicuro di voler modificare il campo selezionato?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              salvaModifiche();
                              Navigator.pop(context); // Chiudi dialog
                            },
                            child: const Text('Salva'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Chiudi dialog
                            },
                            child: const Text('Annulla'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Errore'),
                        content: const Text(
                            'Seleziona un campo da modificare e inserisci le modifiche.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Chiudi dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Salva modifiche'),
            ),
          ],
        ),
      ),
    );
  }

  void salvaModifiche() {
    String? campo = campoSelezionato ?? '';
    final String modifiche = modificheController.text.trim();

    String campoFirestore = campo; // Inizializza il campo Firestore con il campo selezionato

    if (campo == 'Classe Armatura') {
      campoFirestore = 'classeArmatura'; // Aggiorna il campo Firestore per la classe armatura
      campo = statoSelezionato;
    } else {
      campoFirestore = campo.toLowerCase(); // Converte il campo selezionato in minuscolo per altri campi
    }

    // Crea una variabile numerica se il campo su Firestore è numerico
    int? modificheValueNum;
    if (campo == 'Vita' ||
        campo == 'VitaMax' ||
        campo == 'Forza' ||
        campo == 'Destrezza' ||
        campo == 'Costituzione' ||
        campo == 'Intelligenza' ||
        campo == 'Saggezza' ||
        campo == 'Carisma' ||
        campo == 'Classe Armatura') {
      modificheValueNum = int.tryParse(modifiche) ?? 0;
    }

    // Cerca il personaggio utilizzando nome, classe e razza come criteri di ricerca
    FirebaseFirestore.instance
        .collection('personaggi')
        .where('nome', isEqualTo: widget.nome)
        .where('classe', isEqualTo: widget.classe)
        .where('razza', isEqualTo: widget.razza)
        .where('utenteId', isEqualTo: widget.utenteId)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot personaggio = snapshot.docs.first;

        // Aggiorna il campo selezionato con le modifiche nel personaggio trovato
        if (modificheValueNum != null) {
          personaggio.reference.update({
            campoFirestore: modificheValueNum,
          });
        } else {
          personaggio.reference.update({
            campoFirestore: modifiche,
          });
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Successo'),
              content: Text('Modifiche salvate con successo.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Chiudi dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Personaggio non trovato
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Errore'),
              content: Text('Personaggio non trovato.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Chiudi dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      // Si è verificato un errore durante la ricerca del personaggio
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Errore'),
            content: Text('Si è verificato un errore durante la ricerca del personaggio.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Chiudi dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }


}

