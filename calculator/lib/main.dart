import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ScientificCalculator());
}

class ScientificCalculator extends StatefulWidget {
  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  bool isDarkMode = false;
  ThemeMode currentTheme = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      currentTheme = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      themeMode: currentTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: CalculatorPage(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  CalculatorPage({required this.toggleTheme, required this.isDarkMode});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  List<String> _history = [];
  bool _showAdvancedFunctions = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  void _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', _history);
  }

  void _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('history');
    setState(() {
      _history.clear();
    });
  }

  void _onPressed(String buttonText) {
    setState(() {
      _expression += buttonText;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _delete() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _evaluate() {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(_expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('π', 'pi').replaceAll('√', 'sqrt').replaceAll('ln', 'ln').replaceAll('log', 'log10').replaceAll('sin⁻¹', 'arcsin').replaceAll('cos⁻¹', 'arccos').replaceAll('tan⁻¹', 'arctan').replaceAll('x²', '^2').replaceAll('1/x', '1/').replaceAll('|x|', 'abs').replaceAll('±', '-'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _result = eval.toString();
        _history.add(_expression + ' = ' + _result);
        _saveHistory();
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _toggleAdvancedFunctions() {
    setState(() {
      _showAdvancedFunctions = !_showAdvancedFunctions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scientific Calculator'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _openHistory,
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.brightness_7 : Icons.brightness_2),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _result,
                    style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.black),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Expanded(
      flex: 2,
      child: Column(
        children: <Widget>[
          _buildButtonRow(['7', '8', '9', '÷']),
          _buildButtonRow(['4', '5', '6', '×']),
          _buildButtonRow(['1', '2', '3', '-']),
          _buildButtonRow(['0', '.', '=', '+']),
          if (_showAdvancedFunctions)
            _buildButtonRow(['√', 'ln', 'x²', '^', '1/x', '|x|']),
          if (_showAdvancedFunctions)
            _buildButtonRow(['±', 'π', 'log', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹']),
          _buildButtonRow(['C', 'DEL', 'ADV']),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((buttonText) {
          return Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (buttonText == 'C') {
                  _clear();
                } else if (buttonText == 'DEL') {
                  _delete();
                } else if (buttonText == '=') {
                  _evaluate();
                } else if (buttonText == 'ADV') {
                  _toggleAdvancedFunctions();
                } else if (buttonText == '√') {
                  _onPressed('sqrt(');
                } else if (buttonText == 'ln') {
                  _onPressed('ln(');
                } else if (buttonText == 'x²') {
                  _onPressed('^2');
                } else if (buttonText == '^') {
                  _onPressed('^');
                } else if (buttonText == '1/x') {
                  _onPressed('1/');
                } else if (buttonText == '|x|') {
                  _onPressed('abs(');
                } else if (buttonText == '±') {
                  _onPressed('-');
                } else if (buttonText == 'π') {
                  _onPressed('pi');
                } else if (buttonText == 'log') {
                  _onPressed('log10(');
                } else if (buttonText == 'sin⁻¹') {
                  _onPressed('arcsin(');
                } else if (buttonText == 'cos⁻¹') {
                  _onPressed('arccos(');
                } else if (buttonText == 'tan⁻¹') {
                  _onPressed('arctan(');
                } else {
                  _onPressed(buttonText);
                }
              },
              child: Text(buttonText, style: TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('History'),
              TextButton(
                onPressed: () {
                  _clearHistory();
                  Navigator.of(context).pop();
                },
                child: Text('Clear History', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_history[index]),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
