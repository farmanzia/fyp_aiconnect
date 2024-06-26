import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp_social_app/screens/mainscreen.dart';
import 'package:fyp_social_app/utils/firebase.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, String> answers = {};
  int score = 0;

  void answerQuestion(String question, String answer) {
    setState(() {
      answers[question] = answer;
      // Update the score based on correct answers (this is a placeholder logic)
      // You should implement the actual scoring logic
      if (correctAnswers[question] == answer) {
        score++;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:const Text('AI Expert Quiz'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ...questions.map((q) => QuizQuestion(
              question: q['question'].toString(),
              options: q['options'] as List<String>,
              onAnswerSelected: (answer) {
                answerQuestion(q['question'].toString(), answer);
              },
            )).toList(),
            ElevatedButton(
              onPressed: () {
                // Display the score and rating here
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Quiz Complete'),
                      content: const Text("Oops! You didn't pass the questionnaire.\nDon't worry! Learning takes time and try again later"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            if(firebaseAuth.currentUser?.uid!=null){
                              firestore.collection("users").doc(firebaseAuth.currentUser?.uid).update(
                                  {'isAiExpert':true,
                                    'score':score.toString()
                                  }).then((value){
                                     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>TabScreen()), (route) => false);
                              });
                            }
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(String) onAnswerSelected;
  QuizQuestion({required this.question, required this.options, required this.onAnswerSelected});

  @override
  _QuizQuestionState createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.question,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Column(
            children: widget.options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                    widget.onAnswerSelected(value!);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

final questions = [
  {
    'question': 'What is the primary objective of unsupervised learning?',
    'options': [
      'Minimize prediction errors',
      'Discover patterns or structures in data',
      'Classify data into predefined categories',
      'Learn from labeled examples'
    ],
  },
  {
    'question': 'What is the purpose of an activation function in a neural network?',
    'options': [
      'Normalize input data',
      'Regularize the model',
      'Introduce non-linearity',
      'Reduce computational complexity'
    ],
  },
  {
    'question': 'Which of the following is a commonly used regularization technique in machine learning to prevent model overfitting?',
    'options': [
      'Gradient boosting',
      'K-means clustering',
      'Lasso regression',
      'Naive Bayes'
    ],
  },
  {
    'question': 'In K-nearest neighbors (KNN) algorithm, the value of K determines:',
    'options': [
      'The number of features used in classification',
      'The distance metric used for clustering',
      'The number of clusters in the data',
      'The number of nearest neighbors to consider'
    ],
  },
  {
    'question': 'Which of the following is a characteristic of regression algorithms in supervised learning?',
    'options': [
      'They are used for classifying input data into discrete categories.',
      'They predict continuous values as output.',
      'They require labeled data for training.',
      'They are insensitive to outliers in the dataset.'
    ],
  },
  {
    'question': 'What is the main advantage of ensemble learning techniques such as Random Forests or Gradient Boosting?',
    'options': [
      'They are less prone to overfitting compared to single models.',
      'They require fewer computational resources for training.',
      'They perform better on small datasets.',
      'They are easier to interpret than single models.'
    ],
  },
  {
    'question': 'What is the primary metric used to evaluate a classification model\'s performance when dealing with imbalanced datasets?',
    'options': [
      'Accuracy',
      'Precision',
      'Recall',
      'F1-score'
    ],
  },
  {
    'question': 'What is the role of regularization techniques in machine learning?',
    'options': [
      'To prevent model overfitting',
      'To increase model complexity',
      'To reduce training time',
      'To remove outliers from the dataset'
    ],
  },
];

final correctAnswers = {
  'What is the primary objective of unsupervised learning?': 'Discover patterns or structures in data',
  'What is the purpose of an activation function in a neural network?': 'Introduce non-linearity',
  'Which of the following is a commonly used regularization technique in machine learning to prevent model overfitting?': 'Lasso regression',
  'In K-nearest neighbors (KNN) algorithm, the value of K determines:': 'The number of nearest neighbors to consider',
  'Which of the following is a characteristic of regression algorithms in supervised learning?': 'They predict continuous values as output.',
  'What is the main advantage of ensemble learning techniques such as Random Forests or Gradient Boosting?': 'They are less prone to overfitting compared to single models.',
  'What is the primary metric used to evaluate a classification model\'s performance when dealing with imbalanced datasets?': 'F1-score',
  'What is the role of regularization techniques in machine learning?': 'To prevent model overfitting',
};