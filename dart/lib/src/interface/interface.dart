library egb_interface;

import 'dart:async';
import 'dart:isolate';

import '../shared/user_interaction.dart';
import '../persistence/savegame.dart';

abstract class EgbInterface {
  ReceivePort _receivePort;
  SendPort _scripterPort;
  
  /**
   * Outputs the text (in it's pure, non-HTMLified form) that has been shown
   * so far since the last savegame (or beginning of book).
   */
  String getTextHistory();
  
  /// Called on startup to create the interface environment.
  void setup();
  /// Called when there is no more options to take in the book, and so it has
  /// ended. Interface can choose to show a message, call-to-action, etc.
  void endBook();
  /// Called when interface is not needed anymore. This is not necessarily the
  /// same time when the book ends ([endBook()]) -- a player can still choose
  /// to use the interface to retry (restart or load).
  void close();

  /**
   * Displays the HTML-formated text.
   */
  Future<bool> showText(String text);
  
  /**
   * Interface gets choices, presents them to user. When user selects 
   * the choice, the returned Future completes with the selected choice's
   * hash.
   * 
   * This also displays the HTML-formated question, if it is set in ChoiceList. 
   * The question hould disappear after one of the choices is picked.
   * 
   * Completes with null when user wants to quit.
   */
  Future<int> showChoices(EgbChoiceList choices);
  
  /**
   * Marks the point at which the gameplay is saved. Interface should relay
   * the information to the player and make it possible to reload the position
   * later. (Communicated to the Runner via [stream].)
   */
  Future<bool> addSavegameBookmark(EgbSavegame savegame);
  
  /// Stream that sends player's interactions (apart from choice selection).
  /// These interactions include loading game states, starting a gamebook
  /// from scratch, etc.
  Stream<PlayerIntent> get stream;
}

abstract class EgbInterfaceBase implements EgbInterface {
  StreamController<PlayerIntent> streamController;
  Stream<PlayerIntent> get stream => streamController.stream;
  
  EgbInterfaceBase() {
    streamController = new StreamController();
  }
}
