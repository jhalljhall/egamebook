part of egb_scripter;


/**
 * In the context of [EgbScripter], we also have the actual data + logic of
 * the page in the [blocks] list.
 */
class EgbScripterPage extends EgbPage {
  /// The text and/or logic of each block inside this page.
  final List blocks;

  /// Number of times this page has been visited by player.
  int visitCount = 0;
  /// Getter for whether or not this page has been visited by player.
  bool get visited => visitCount > 0;

  /**
   * Creates new EgbScripterPage and takes only blocks List, and optionally
   * page options. Page options are [visitOnce] and [showOnce].
   *
   * Name is copied from Map key when added to [EgbScripterPageMap].
   */
  EgbScripterPage(
      this.blocks,
      {bool visitOnce: false, bool showOnce: false}) :
        super(visitOnce: visitOnce, showOnce: showOnce);
}

/**
 * Class used to store information about an exact point in the book -- page and
 * block. 
 */
class EgbScripterBlockPointer {
  /// Scripter page.
  final EgbScripterPage page;
  /// Block index.
  final int blockIndex;

  /// Creates new EgbScripterBlockPointer with [page] and [blockIndex].
  EgbScripterBlockPointer(this.page, this.blockIndex); 
}

/**
 * [EgbScripterPageMap] is the container for the whole of the text and logic
 * content of each book.
 *
 * It contains a Map of [EgbScripterPage]s which are accessible through
 * their names.
 */
class EgbScripterPageMap {
  /// A Map of page name -> page object.
  final Map<String, EgbScripterPage> pages = new Map<String, EgbScripterPage>();

  /// Creates new EgbScripterPageMap.
  EgbScripterPageMap();

  /// Returns page of exactly the name [key].
  EgbScripterPage operator [](String key) => pages[key];

  /**
   * Returns page with name [name]. If [currentGroupName] is given, then 
   * the function will first search for key in a format [:groupName: name:].
   *
   * Returns [:null:] if there is no page of any compatible name.
   */
  EgbScripterPage getPage(String name, {String currentGroupName: null}) {
    if (currentGroupName != null &&
        pages.containsKey(_getCurrentGroupName(name, currentGroupName))) {
      return pages[_getCurrentGroupName(name, currentGroupName)];
    } else if (pages.containsKey(name)) {
      return pages[name];
    } else {
      return null;
    }
  }
  
  /// Returns current group name string in a format [:groupName: name:].
  String _getCurrentGroupName(String name, String currentGroupName) 
      => "$currentGroupName: $name";

  /// Saves EgbScripterPage [newPage] on [key] to the Map of [pages].
  /// Also sets a [key] as a name for the given page.
  operator []=(String key, EgbScripterPage newPage) {
    pages[key] = newPage;
    // Copy the "key" to the name of the page. This is here so that we don't
    // need to duplicate the page name in the scripter data.
    newPage.name = key;
  }

  /// Exports state containing [page.visitCount] for every page in a Map of [pages].
  Map<String, dynamic> exportState() {
    var pageMapState = new Map<String, dynamic>();
    pages.forEach((name, page) {
      pageMapState[name] = {
          "visitCount": page.visitCount
      };
    });
    return pageMapState;
  }

  /// Imports state from a Map [pageMapState].
  /// Sets [page.visitCount] for every page in a Map of [pages] from a given Map.
  void importState(Map<String, dynamic> pageMapState) {
    pageMapState.forEach((name, map) {
      if (pages.containsKey(name)) {
        pages[name].visitCount = map["visitCount"];
      }
    });
  }

  /**
   * Clears play state of the page map. (Play state is the data that change
   * while the egamebook is played by the player, e.g. the 
   * [EgbScripterPage.visitCount] of every page. The actual texts and scripts 
   * stay.)
   * 
   * Useful when restarting an egamebook from scratch.
   */
  void clearState() {
    pages.forEach((name, page) {
      page.visitCount = 0;
    });
  }
}