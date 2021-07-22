import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logger.dart';

class QuestionnaireWidget extends StatefulWidget {
  final fireID;

  QuestionnaireWidget({this.fireID});

  @override
  _QuestionnaireState createState() => _QuestionnaireState();
}

class _QuestionnaireState extends State<QuestionnaireWidget> {
  List<String> questions = [
    "Skete der noget uforventet under turen som gjorde dig ked af det?",
    "Følte du dig nervøs eller stresset under turen?",
    "Gik tingene i din retning under turen?",
    "Var du i stand til at kontrollere irritationer under turen?",
    "Følte du dig på toppen under turen?",
    "Blev du vred over noget du ikke kunne kontrollere?"
  ];

  List<String> likertscale = ["Nej slet ikke", "Lidt", "Nogenlunde", "Meget"];

  bool skipQuestion = false;
  bool isDisabled = true;
  Map<String, dynamic> answers = {};
  List<int> questionValues = [];

  void _questionValue(String question, int answer) {
    setState(() {
      //add answer to answer map
      if (answers.containsKey(question))
        answers.update(question, (value) => answer);
      else
        answers.addAll({question: answer});

//check if all questions have been answered, and enable finish button
      if (!questionValues.contains(-1)) isDisabled = false;
    });
  }

//Alert button to notify if they really want to skip
  Future<void> _alertSkipQuestion() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Er du sikker på du vil springe over?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Spørgeskemaet skal være udfyldt inden kl 23.59.'),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text("Ja, Spring over"),
              onPressed: () {
                Logger().logQuestionnaireSkip(widget.fireID);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            ElevatedButton(
              child: Text(
                'Nej, fortsæt',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //build list of values to control interface
    if (questionValues.length == 0) {
      for (var i = 0; i < questions.length; i++) {
        questionValues.add(-1);
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Hvordan var din køretur?"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Spørgeskemaet tager max 2 minutter",
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Scrollbar(
                  child: _questionBuilder(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: _skipQuestionnaire,
                  child: Text(
                    'Spring over',
                  ),
                ),
                ElevatedButton(
                  onPressed: isDisabled ? null : _questionnaireFinished,
                  child: Text(
                    'Færdig',
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  List<Container> _radioButtonBuilder(int question) {
    List<Container> wlist = [];
    for (int i = 0; i < likertscale.length; i++) {
      wlist.add(
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Radio(
                    value: i,
                    groupValue: questionValues[question],
                    onChanged: (int value) {
                      questionValues[question] = value;
                      _questionValue(question.toString(), value);
                    }),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  likertscale[i],
                ),
                // RichText(
                //   textAlign: TextAlign.center,
                //   text:
                //   TextSpan(
                //     text: likertscale[i],

                //     recognizer: TapGestureRecognizer()
                //       ..onTap = () {
                //         questionValues[question] = i;
                //         _questionValue(question.toString(), i);
                //       },
                //   ),
                // ),
              ),
            ],
          ),
        ),
      );
    }

    return wlist;
  }

  ListView _questionBuilder() {
    return ListView.builder(
        itemCount: questions.length,
        scrollDirection: Axis.vertical,
        addRepaintBoundaries: true,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int row) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questions[row],
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20),
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _radioButtonBuilder(row)),
                ],
              ),
            ),
          );
        });
  }

  void _questionnaireFinished() {
    if (!isDisabled) {
      updatePrefs();
      Logger logger = Logger();
      logger.logQuestionnaire(widget.fireID, answers);
      Navigator.pop(context);
    }
  }

  void updatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("lastQuestionnaire", DateTime.now().toString());
  }

  void _skipQuestionnaire() {
    _alertSkipQuestion();
  }
}
