import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      home: PlayerSetupScreen(),
    );
  }
}

class PlayerSetupScreen extends StatefulWidget {
  @override
  _PlayerSetupScreenState createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  bool _playWithAI = false;

  void _startGame() {
    if (_player1Controller.text.isNotEmpty &&
        (_playWithAI || _player2Controller.text.isNotEmpty)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicTacToeGame(
            player1: _player1Controller.text,
            player2: _playWithAI ? "IA" : _player2Controller.text,
            playWithAI: _playWithAI,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa los nombres de los jugadores')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Jugadores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _player1Controller,
              decoration: InputDecoration(
                labelText: 'Jugador 1 (X)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            if (!_playWithAI)
              TextField(
                controller: _player2Controller,
                decoration: InputDecoration(
                  labelText: 'Jugador 2 (O)',
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _playWithAI,
                  onChanged: (value) {
                    setState(() {
                      _playWithAI = value!;
                    });
                  },
                ),
                Text('Jugar contra la IA'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startGame,
              child: Text('Iniciar Juego'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final String player1;
  final String player2;
  final bool playWithAI;

  TicTacToeGame({
    required this.player1,
    required this.player2,
    required this.playWithAI,
  });

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> with TickerProviderStateMixin {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  bool _isGameOver = false;
  late String _currentPlayerName;

  @override
  void initState() {
    super.initState();
    _currentPlayerName = widget.player1;
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
      _isGameOver = false;
      _currentPlayerName = widget.player1;
    });
  }

  void _makeMove(int index) {
    if (_board[index] == '' && !_isGameOver) {
      setState(() {
        _board[index] = _currentPlayer;
        _checkWinner();
        if (!_isGameOver) {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
          _currentPlayerName = _currentPlayer == 'X'
              ? widget.player1
              : widget.playWithAI
                  ? "IA"
                  : widget.player2;

          if (widget.playWithAI && _currentPlayer == 'O' && !_isGameOver) {
            _makeAIMove();
          }
        }
      });
    }
  }

  void _makeAIMove() {
    final emptyIndexes = _board.asMap().entries.where((e) => e.value == '').map((e) => e.key).toList();
    if (emptyIndexes.isNotEmpty) {
      final randomIndex = emptyIndexes[Random().nextInt(emptyIndexes.length)];
      _makeMove(randomIndex);
    }
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]            // Diagonals
    ];

    for (var combo in winningCombinations) {
      if (_board[combo[0]] != '' &&
          _board[combo[0]] == _board[combo[1]] &&
          _board[combo[1]] == _board[combo[2]]) {
        _isGameOver = true;
        _winner = _board[combo[0]];
        return;
      }
    }

    if (!_board.contains('')) {
      _isGameOver = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _winner != null
                ? 'Ganador: $_winner (${_winner == 'X' ? widget.player1 : widget.player2})'
                : _isGameOver
                    ? 'Es un empate'
                    : 'Es turno de: $_currentPlayerName',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _makeMove(index),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _board[index] == 'X' ? Colors.blue : Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: Text('Reiniciar Juego'),
          ),
        ],
      ),
    );
  }
}
