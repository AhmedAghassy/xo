import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xo/game_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //xo
  bool _isSwitchedTwoPlayer = false;

  String _activePlayer = 'O';
  String _result = '';
  bool _isGameOver = false;
  int _turn = 0;

  final Game _game = Game();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (layoutContext, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            return (constraints.maxWidth < 180 || constraints.maxHeight < 260)
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 16 : 12,
                      vertical: isLandscape ? 12 : 16,
                    ),
                    child: !isLandscape
                        ? Column(
                            children: [
                              _turnOnOffBlock(isLandscape, theme),
                              const SizedBox(height: 16),
                              _isGameOver || _turn == 9
                                  ? _endTurnsBlock(isLandscape, theme)
                                  : _turnBlock(isLandscape, theme),
                              const SizedBox(height: 8),
                              _boardBlock(theme),
                              const SizedBox(height: 16),
                              _resultBlock(isLandscape, theme),
                              const SizedBox(height: 8),
                              _restartBlock(isLandscape, theme),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _turnOnOffBlock(isLandscape, theme),
                                    const SizedBox(height: 16),
                                    _isGameOver || _turn == 9
                                        ? _endTurnsBlock(isLandscape, theme)
                                        : _turnBlock(isLandscape, theme),
                                    const SizedBox(height: 16),
                                    _resultBlock(isLandscape, theme),
                                    const SizedBox(height: 8),
                                    _restartBlock(isLandscape, theme),
                                  ],
                                ),
                              ),
                              _boardBlock(theme),
                            ],
                          ),
                  );
          },
        ),
      ),
    );
  }

  SizedBox _restartBlock(bool isLandscape, ThemeData theme) {
    return SizedBox(
      height: isLandscape ? 42 : 48,
      child: ElevatedButton.icon(
        onPressed: _restartGame,
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Restart the game',
            style: GoogleFonts.quicksand(
              color: theme.highlightColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        icon: Icon(Icons.replay_rounded, color: theme.highlightColor),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(theme.splashColor),
        ),
      ),
    );
  }

  SizedBox _resultBlock(bool isLandscape, ThemeData theme) {
    return SizedBox(
      height: isLandscape ? 35 : 45,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _result,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            color: _result == 'X is the winner'
                ? theme.disabledColor
                : _result == 'O is the winner'
                ? theme.primaryColorDark
                : theme.highlightColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Expanded _boardBlock(ThemeData theme) {
    return Expanded(
      child: Center(
        child: LayoutBuilder(
          builder: (boardLayoutContext, boardConstraints) {
            final boardSize = math.min(
              boardConstraints.maxWidth,
              boardConstraints.maxHeight,
            );

            return SizedBox(
              width: boardSize,
              height: boardSize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (gridContext, index) {
                  return InkWell(
                    radius: 16,
                    overlayColor: WidgetStateProperty.all(theme.shadowColor),
                    splashColor: theme.shadowColor,
                    highlightColor: theme.shadowColor,
                    hoverColor: theme.shadowColor,
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isGameOver || _turn == 9
                        ? null
                        : () => _onTapBoard(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.shadowColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Player.playerX.contains(index)
                                ? 'X'
                                : Player.playerO.contains(index)
                                ? 'O'
                                : '',
                            style: GoogleFonts.quicksand(
                              color: Player.playerX.contains(index)
                                  ? theme.disabledColor
                                  : theme.primaryColorDark,
                              fontSize: 62,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SizedBox _turnBlock(bool isLandscape, ThemeData theme) {
    return SizedBox(
      height: isLandscape ? 35 : 50,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.quicksand(
              color: theme.highlightColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            children: [
              const TextSpan(text: 'IT\'S '),
              TextSpan(
                text: _activePlayer,
                style: GoogleFonts.quicksand(
                  color: _activePlayer == 'X'
                      ? theme.disabledColor
                      : theme.primaryColorDark,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' TURN'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SizedBox _endTurnsBlock(bool isLandscape, ThemeData theme) {
    return SizedBox(
      height: isLandscape ? 35 : 50,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'End of the turns',
          style: GoogleFonts.quicksand(
            color: theme.focusColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  SizedBox _turnOnOffBlock(bool isLandscape, ThemeData theme) {
    return SizedBox(
      height: isLandscape ? 45 : 60,
      child: SwitchListTile.adaptive(
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        contentPadding: EdgeInsets.zero,
        dense: true,
        activeTrackColor: theme.splashColor,
        activeThumbColor: theme.primaryColor,
        value: _isSwitchedTwoPlayer,
        onChanged: Player.playerX.isNotEmpty || Player.playerO.isNotEmpty
            ? null
            : (newValue) {
                setState(() {
                  _isSwitchedTwoPlayer = newValue;
                });
              },
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Turn on/off two players',
            style: GoogleFonts.quicksand(
              color: theme.highlightColor,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _onTapBoard(int index) async {
    if ((Player.playerX.isEmpty || !Player.playerX.contains(index)) &&
        (Player.playerO.isEmpty || !Player.playerO.contains(index))) {
      _game.playGame(index, _activePlayer);
      await _updateState();

      if (!_isSwitchedTwoPlayer && !_isGameOver && _turn != 9) {
        await _game.autoPlay(_activePlayer);
        _updateState();
      }
    }
  }

  Future<void> _updateState() async {
    setState(() {
      _activePlayer = _activePlayer == 'X' ? 'O' : 'X';
      _turn = _turn + 1;
      String winner = _game.checkWinner();
      if (winner != '') {
        _isGameOver = true;
        _result = '$winner is the winner';
      } else if (!_isGameOver && _turn == 9) {
        _result = 'It\'s draw';
      }
    });
  }

  void _restartGame() {
    setState(() {
      Player.playerX = [];
      Player.playerO = [];
      _activePlayer = 'O';
      _result = '';
      _isGameOver = false;
      _turn = 0;
    });
  }
}
