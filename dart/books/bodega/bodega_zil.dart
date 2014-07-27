library bodega_zil;

import '../libraries/zil.dart';
import '../libraries/timeline.dart';
import 'package:egamebook/src/shared/stat.dart';
import 'package:egamebook/src/book/scripter_typedefs.dart';
import 'package:egamebook/src/book/scripter.dart' show EgbScripter, PointsCounter;
import '../libraries/storyline.dart';

class BodegaZil {
  BodegaZil(this.goto, this.echo, this.choice, this.vars, EgbScripter scripter) 
      : zil = new Zil(scripter) {
    points = vars["points"];
    
    setupExploration();
    setupActors();
    setupRooms();
  }
  
  void setupExploration() {
    exploration = zil.timeline;
    exploration.mainLoop = () {
      clock.value += 1;
      // TODO: Exploration timeline - no jumping, no rescheduling
    };
    
    exploration.schedule(MAX_TIME_BEFORE_NAP, () {
      roomBeforeOvercameBySleepiness = zil.player.location.name;
      goto("Bridge: OvercomeBySleepiness");
    });
    
    exploration.schedule(MAX_TIME_BEFORE_HYPERDRIVE_READY, () {
      jumpToSpaceStationUnity.isActive = true;
      echo("""\n\nThe ship's PA system makes a short bleep, then Bodega """
          """says: "The hyperdrive is fully operational. We are ready to """
          """jump, $salutation$name." """);
    });
  }
  
  void setupActors() {
    gorilla = new AIActor(zil, "Gorilla", pronoun: Pronoun.HE);
  }
  
  void setupRooms() {
    setupBridge();
    setupNose();
    setupCorridorLeftNextToCaptainsCabin();
    setupCaptainsCabin();
    setupCorridorLeftNextToAirlock();
    setupStaffRoom();
    setupCorridorLeftNextToBunks();
    setupBunks();
    setupCorridorLeftJunction();
    setupGuts();
    setupEngineRoom();
    setupCorridorRightNextToComputerRoom();
    setupComputerRoom();
    setupCorridorRightNextToAirlock();
    setupMedicalBay();
    setupCorridorRightNextToBunks();
    setupCorridorRightJunction();
    setupCargoBayLeft();
    setupExplodedContainer();
    setupCargoCenter();
    setupCargoBayRight();
    setupPlaceOfBreach();
    setupGorillasDen();
  }
  
  void setupGorillasDen() {
    gorillasDen = new Room(zil, "Explore: GorillasDen",
        "cargo bay",
        [new Exit("Explore: CargoBayLeft", 
            "go back to entrance to Corridor Left",
            "you arrive at the entrance to Corridor Left")],
        descriptionPage: "GorillasDen.description",
        coordinates: [-10, -70, 0]
    );
  }
  
  Room gorillasDen;
  
  void setupPlaceOfBreach() {
    new Room(zil, "Explore: PlaceOfBreach",
        "cargo bay",
        [new Exit("Explore: CargoBayRight", 
            "go back to entrance to Corridor Right",
            "you arrive at the entrance to Corridor Right")],
        descriptionPage: "PlaceOfBreach.description",
        coordinates: [10, -70, 0]
    );
  }
  
  void setupCargoBayRight() {
    /*
    TODO
    exits: hull breach == Nearby, a spy robot
     */

    // EXITS
    exitToHullBreach = new Exit("Explore: PlaceOfBreach", 
        "go to the hull breach",
        "you arrive at the place of the breach");
    exitToHullBreach.isActive = false;

    // ROOM
    new Room(zil, "Explore: CargoBayRight",
        "cargo bay",
        [new Exit("Explore: CorridorRightJunction", "enter Corridor Right",
             "<subject> leave<s> the cargo bay and walk<s> up to the right "
             "junction"),
         new Exit("Explore: CargoCenter", 
             "go to the other side of the cargo bay",
             "after a few moments, <subject> arrive<s> at the cargo bay "
             "console, located at the front center of the bay", cost: 2),
         exitToHullBreach],
        descriptionPage: "CargoBayRight.description",
        coordinates: [10, -55, 0]
    );
  }
  
  Exit exitToHullBreach;
  
  void setupCargoCenter() {
    new Room(zil, "Explore: CargoCenter",
        "cargo bay",
        [new Exit("Explore: CargoBayLeft", 
            "go to the left side of the cargo bay",
            "<subject> arrive<s> at the left side of the cargo bay", cost: 2),
         new Exit("Explore: CargoBayRight", "go to the right side of the "
             "cargo bay",
             "<subject> arrive<s> at the right side of the cargo bay", 
             cost: 2)],
        descriptionPage: "CargoCenter.description",
        coordinates: [0, -55, 0],
        actions: [new Action.Goto("approach the console", 
            "CargoCenter.console",
            onlyOnce: false)]
    );
  }
  
  void setupExplodedContainer() {
    new Room(zil, "Explore: ExplodedContainer",
        "cargo bay",
        [new Exit("Explore: CargoBayLeft", "go to the Corridor Left entrance",
            "<subject> arrive<s> at the front left side of the cargo bay", 
            cost: 2)],
        descriptionPage: "ExplodedContainer.description",
        coordinates: [-10, -100, -10],
        actions: [new Action.Goto("Search [~30 minutes]", 
            "ExplodedContainer.search", 
            onlyOnce: true)]
    );
  }
  
  void setupCargoBayLeft() {
    /*
    TODO
    hasSteelRod - "You pick up the steel rod. It's quite heavy, but still easy to wield. The men used it for prying crates open, for propping things in place, and for reaching into narrow openings. It has a cross-shaped tip that fits into the head of the big screws around here."
    exits: damaged Sentaco container - NOT YET!
     */

    // TODO: scavenge - let player choose row+column ("A245") and either give random thing or something specific (medical supplies)

    // ROOM
    cargoBayLeft = new Room(zil, "Explore: CargoBayLeft",
        "cargo bay",
        [new Exit("Explore: CorridorLeftJunction", "enter Corridor Left",
             "<subject> leave<s> the cargo bay and walk<s> up to the left "
             "junction"),
         new Exit("Explore: CargoCenter", 
             "go to the other side of the cargo bay",
             "after a few moments, <subject> arrive<s> at the cargo bay "
             "console, located at the front center of the bay", cost: 2),
         new Exit("Explore: ExplodedContainer", 
             "go to the place of the explosion",
             "you head deep into the cargo bay and after about 2 minutes, "
             "you arrive at the site of the explosion", cost: 2)
        ],
        descriptionPage: "CargoBayLeft.description",
        coordinates: [-10, -55, 0]
    );
  }
  
  Room cargoBayLeft;
  
  void setupCorridorRightJunction() {
    new Room(zil, "Explore: CorridorRightJunction",
        "right junction",
        [new Exit("Explore: CorridorRightNextToBunks", 
            "walk towards the bridge",
            "after quite a walk, <subject> arrive<s> to the entrance to the "
            "bunks"),
         new Exit("Explore: Guts", "enter the guts",
            "<subject> open<s> the door and step<s> through a narrow hatchway"),
         new Exit("Explore: EngineRoom", "enter the engine room",
            "<subject> open<s> the bigger door and enter<s> into the engine "
             "room"),
         new Exit("Explore: CargoBayRight", "go into the cargo bay",
            "<subject> walk<s> to the very end of Corridor Right and enter<s> "
             "the cargo bay through a huge {entrance|door}")
        ],
        descriptionPage: "CorridorRightJunction.description",
        coordinates: [5, -45, 0]
    );
  }
  
  void setupCorridorRightNextToBunks() {
    new Room(zil, "Explore: CorridorRightNextToBunks",
        "Corridor Right",
        [new Exit("Explore: CorridorRightNextToAirlock", 
            "walk towards the {bridge|front of the ship}",
            "<subject> walk<s> towards the front of the ship"),
         new Exit("Explore: Bunks", "enter the bunks",
             "<subject> enter<s> the bunks"),
         new Exit("Explore: CorridorRightJunction", 
             "walk {toward the cargo bay|to the {aft|back} of the ship}",
             "after walking for 3 minutes, <subject> arrive<s> at the right "
             "junction", 
            cost: 2)],
        descriptionPage: "CorridorRightNextToBunks.description",
        coordinates: [5, -25, 0]
    );
  }
  
  void setupMedicalBay() {
    /*
    TODO: precision chainsaw (??)
    // recollections about how the contagion started
    // TODO: repair something?
    // living tissue on petri dish */

    // ROOM
    new Room(zil, "Explore: MedicalBay",
        "medical bay",
        [new Exit("Explore: StaffRoom", "use the little door",
            "<subject> walk<s> through a narrow corridor and arrive<s> at "
            "the staff room"),
         new Exit("Explore: CorridorRightNextToAirlock", 
             "exit to Corridor Right",
            "<subject> walk<s> out of the medical bay onto Corridor Right")],
        descriptionPage: "MedicalBay.description",
        coordinates: [5, -15, 0]
    );
  }
  
  void setupCorridorRightNextToAirlock() {
    // ACTIONS
    pullLever = new Action.Goto("pull the lever to let the captain's body out", 
        "CorridorRightNextToAirlock.PullLever",
        onlyOnce: true,
        isActive: false);

    // ROOM
    new Room(zil, "Explore: CorridorRightNextToAirlock",
        "Corridor Right",
        [new Exit("Explore: CorridorRightNextToComputerRoom", 
            "walk towards the bridge",
            "<subject> arrive<s> at the door to the computer room"),
         new Exit("Explore: MedicalBay", "enter the medical bay",
            "<subject> enter<s> the medical bay"),
         new Exit("Explore: CorridorRightNextToBunks", 
             "walk {toward the cargo bay|to the {aft|back} of the ship}",
            "<subject> {stride|walk}<s> towards the {{aft|back} of the "
             "ship|cargo bay}")],
        descriptionPage: "CorridorRightNextToAirlock.description",
        coordinates: [10, -15, 0],
        actions: [
            new Action.Goto("look into the airlock", 
                "CorridorRightNextToAirlock.Look", onlyOnce: true),
            pullLever
        ]
    );
  }
  
  Action pullLever;
  
  void setupComputerRoom() {
    // ACTIONS
    // just look around
    // go through latest internal ship memos
    // later: break stuff
    // change RAID - makes bodega happier

    // ROOM
    new Room(zil, "Explore: ComputerRoom",
        "Computer Room",
        [new Exit("Explore: CorridorRightNextToComputerRoom", "leave",
            "<subject> {walk|step}<s> out to Corridor Right")
        ],
        descriptionPage: "ComputerRoom.description",
        coordinates: [7, -10, 0]
    );
  }
  
  void setupCorridorRightNextToComputerRoom() {
    new Room(zil, "Explore: CorridorRightNextToComputerRoom",
        "Corridor Right",
        [new Exit("Explore: Bridge", "walk to the bridge",
            "<subject> {enter<s>|arrive<s> at} the bridge"),
         new Exit("Explore: ComputerRoom", "enter the Computer Room",
            "<subject> {walk|step}<s> through the door"),
         new Exit("Explore: CorridorRightNextToAirlock", "walk {toward the cargo bay|to the {aft|back} of the ship}",
            "<subject> {stride|walk}<s> towards the {{aft|back} of the ship|cargo bay}")],
        descriptionPage: "CorridorRightNextToComputerRoom.description",
        coordinates: [5, -10, 0]
    );
  }
  
  void setupEngineRoom() {
    // TODO steel something gets attracted
    
    // ACTIONS
    repairEngineAction = new Action.Goto("Take a look at the engine, "
        "try to bring output from 89% back to 100% [~3 hours]", 
        "EngineRoom.RepairEngine",
        onlyOnce: true, isActive: false);

    // ROOM
    new Room(zil, "Explore: EngineRoom",
        "engine room",
        [new Exit("Explore: CorridorLeftJunction", "exit to Corridor Left",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Left"),
         new Exit("Explore: CorridorRightJunction", "exit to Corridor Right",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Right")],
        descriptionPage: "EngineRoom.description",
        coordinates: [0, -50, 0],
        actions: [repairEngineAction]
    );
  }
  
  Action repairEngineAction;
  
  void setupGuts() {
    // TODO toolbox
    // TODO: Defensive turret, shield generator, radar.
    // TODO: allow something hidden from Bodega
    // ROOM
    new Room(zil, "Explore: Guts",
        "guts",
        [new Exit("Explore: CorridorLeftJunction", "exit to Corridor Left",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Left"),
         new Exit("Explore: CorridorRightJunction", "exit to Corridor Right",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Right")],
        descriptionPage: "Guts.description",
        coordinates: [0, -45, 0]
    );
  }
  
  void setupCorridorLeftJunction() {
    new Room(zil, "Explore: CorridorLeftJunction",
        "left junction",
        [new Exit("Explore: CorridorLeftNextToBunks", "walk towards the bridge",
            "after quite a walk, <subject> arrive<s> to the entrance to the "
            "bunks"),
         new Exit("Explore: Guts", "enter the guts",
            "<subject> open<s> the door and step<s> through a narrow hatchway"),
         new Exit("Explore: EngineRoom", "enter the engine room",
            "<subject> open<s> the bigger door and enter<s> into the engine "
             "room"),
         new Exit("Explore: CargoBayLeft", "go into the cargo bay",
            "<subject> walk<s> to the very end of Corridor Left and enter<s> "
             "the cargo bay through a huge {entrance|door}")],
        descriptionPage: "CorridorLeftJunction.description",
        coordinates: [-5, -45, 0]
    );
  }
  
  void setupBunks() {
    
    shabuVials = new Item(zil, "shabu vials", pronoun: Pronoun.THEY,
        count: 2,
        // TODO: Action: use - makes better physically, has withdrawal
        isActive: false);
    
    Action siftThrough = new Action.Goto("sift through lockers [~30 minutes]", 
        "Bunks.SiftThroughLockers", onlyOnce: true);
    // TODO: BreakIntoLockedBoxes - sift through locked lockers => find clues, reminisce about solitude
    //                and find things that are surprising + an item
    //          requirement: strong or has crowbar
    // ROOM
    new Room(zil, "Explore: Bunks",
        "bunks",
        [new Exit("Explore: CorridorLeftNextToBunks", "exit to Corridor Left",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Left"),
         new Exit("Explore: CorridorRightNextToBunks", "exit to Corridor Right",
            "<subject> {{exit|leave}<s>|step<s> out} to Corridor Right")],
        descriptionPage: "Bunks.description",
        coordinates: [0, -25, 0],
        items: [shabuVials],
        actions: [siftThrough]
    );
  }
  
  Item shabuVials;
  
  void setupCorridorLeftNextToBunks() {
    new Room(zil, "Explore: CorridorLeftNextToBunks",
        "corridor left",
        [new Exit("Explore: CorridorLeftNextToAirlock", 
            "walk towards the bridge",
            "<subject> arrive<s> to the Corridor Left airlock and the staff "
            "room"),
         new Exit("Explore: Bunks", "enter the bunks",
            "<subject> step<s> inside the {living quarters|bunks}"),
         new Exit("Explore: CorridorLeftJunction", 
             "walk {toward the cargo bay|to the {aft|back} of the ship}",
            "after walking for 3 minutes, <subject> arrive<s> at the left "
             "junction", 
            cost: 2)],
        descriptionPage: "CorridorLeftNextToBunks.description",
        coordinates: [-5, -25, 0]
    );
  }
  
  void setupStaffRoom() {
    // ITEMS
    banana = new Item(zil, "banana", 
        actions: [
          new Action("eat the banana", 
             () {
               storyline.add("You pull the banana out of your pocket, peel it, "
                   "and eat it. It's delicious. You feel a little bit "
                   "invigorated.");
               // TODO: player.hp++
               stoleOfficersBanana = true; // TODO: bodega doesn't like this
               banana.isActive = false;
             },
             needsToBeCarried: true,
             onlyOnce: true,
             submenu: INVENTORY),
          new Action("give the banana to Gorilla",
              () {
                storyline.add("You hand the banana to Gorilla. He watches it with amazement, than proceeds to peel it eagerly. Before he takes the first bite, though, he gives you a thankful look.\n\nAfter only a few seconds, the banana is no more. But Gorilla seems very happy.");
                gorillaAttitude += 2;
                stoleOfficersBanana = true; // TODO: bodega doesn't like this
                banana.isActive = false;
                points.add(5, "making friends");
              },
              performerCheck: (actor) => actor.isInSameRoomAs(gorilla),
              submenu: INVENTORY)
         ],
         takeable: true,
         isActive: false
    );

    // ROOM
    new Room(zil, "Explore: StaffRoom",
        "staff room",
        [new Exit("Explore: MedicalBay", "go through the little door",
            "<subject> squeeze<s> through a narrow, white passage and "
            "<subject> enter<s> the medbay through another small door"),
         new Exit("Explore: CorridorLeftNextToAirlock", 
             "exit to Corridor Left",
            "<subject> walk<s> out of the room into Corridor Left")],
        descriptionPage: "StaffRoom.description",
        coordinates: [-5, -15, 0],
        items: [banana],
        actions: [new Action.Goto("look for food", "StaffRoom.findFood", 
            onlyOnce: true)]
    );
  }
  
  Item banana;
  
  void setupCorridorLeftNextToAirlock() {
    // ACTIONS
    
    // TODO repair door (search corridorLeftDoorRepaired)
    // TODO: map for visitors: takeable, shown after LeftAirlock.Look

    // ROOM
    new Room(zil, "Explore: CorridorLeftNextToAirlock",
        "Corridor Left",
        [new Exit("Explore: CorridorLeftNextToCaptainsCabin", 
            "walk towards the bridge",
            "<subject> walk<s> towards the bridge up to the point where there "
            "is the door to the captain's cabin on the left hand side"),
         new Exit("Explore: StaffRoom", "enter the staff room",
            "<subject> enter<s> the staff room"),
         new Exit("Explore: CorridorLeftNextToBunks", 
             "walk {toward the cargo bay|to the {aft|back} of the ship}",
            "<subject> arrive<s> at the door to the sleeping quarters")],
        descriptionPage: "CorridorLeftNextToAirlock.description",
        coordinates: [-10, -15, 0],
        actions: [
            new Action.Goto("examine the airlock", "LeftAirlock.Look", 
                onlyOnce: true)
        ]
    );
  }
  
  void setupCaptainsCabin() {
    // ITEMS
    captainsGun = new Item(zil, "captain's gun", 
        actions: [
          new Action("check the gun", 
             () => storyline.add("You pull the gun out of your pocket and heft "
                 "it in your hand. It's heavy, well-built and seems in fine "
                 "condition. It is loaded."),
             needsToBeCarried: true,
             onlyOnce: true,
             submenu: INVENTORY),
          new Action("shoot the Gorilla",
              () {
                storyline.add("You lift the gun and aim at Gorilla. He freezes "
                    "and looks absolutely horrified.");
                choice("Pull the trigger", script: () {
                  storyline.add("You shoot.");
                  gorilla.isActive = false;
                  gorillaCorpse.isActive = true;
                  gorillaCorpse.location = gorilla.location;
                  storyline.add("Gorilla takes it in the chest and falls to "
                      "the ground with a loud thump. A puddle of blood starts "
                      "forming under him almost immediately.");
                  // TODO: Bodega reacts - what the hell
                });
                choice("Put the gun down", script: () {
                  storyline.add("You put the gun down. Gorilla doesn't move. "
                      "He watches you in terror, frozen in place.");
                  // TODO: a new AI 'Goal' - being horrified, frozen
                });
              },
              performerCheck: (actor) => actor.isInSameRoomAs(gorilla),
              needsToBeCarried: true,
              submenu: INVENTORY)
         ],
         takeable: true,
         takeDescription: "<subject> lift<s> the <object> and put<s> it in the "
           "pocket",
         count: 1  // can be >1 for things like bullets
    );
    gorillaCorpse = new Item(zil, "Gorilla's body",
        takeable: true,
        isActive: false
    );

    // ACTIONS
    firstLookAround = new Action.Goto("have a look around [5 minutes]", 
        "CaptainsCabinLookAround", 
        onlyOnce: true);
    secondLookAround = new Action.Goto("continue with the search [5 minutes]",
      "CaptainsCabinLookAroundContinue", onlyOnce: true, isActive: false);
    thirdLookAround = new Action.Goto("search the rest of the room [3 minutes]",
      "CaptainsCabinLookAroundTheRest", onlyOnce: true, isActive: false);
    captainsComputerFirst = new Action.Goto("look at captain's computer screen",
      "CaptainsComputerFirst", onlyOnce: true);
    

    // ROOM
    new Room(zil, "Explore: CaptainsCabin",
        "captain's cabin",
        [new Exit("Explore: CorridorLeftNextToCaptainsCabin", "exit the room",
            "<subject> leave<s> into the corridor")],
        descriptionPage: "CaptainsCabin.description",
        coordinates: [-10, -10, 0],
        /*items: [captainsGun],*/
        actions: [
          firstLookAround,
          secondLookAround,
          thirdLookAround,
          captainsComputerFirst
        ]
    );
  }
  
  Item captainsGun;
  Item gorillaCorpse;
  Action firstLookAround;
  Action secondLookAround;
  Action thirdLookAround;
  Action captainsComputerFirst;
  
  void setupCorridorLeftNextToCaptainsCabin() {
    new Room(zil, "Explore: CorridorLeftNextToCaptainsCabin",
          "Corridor Left",
          [new Exit("Explore: Bridge", "walk to the bridge",
               "<subject> {enter<s>|arrive<s> at} the bridge"),
           new Exit("Explore: CaptainsCabin", "enter Captain's cabin",
               "<subject> open<s> the door to the Captain's cabin and "
               "enter<s>"),
           new Exit("Explore: CorridorLeftNextToAirlock", 
               "walk {toward the cargo bay|to the {aft|back} of the ship}",
               "<subject> {stride|walk}<s> towards the {{aft|back} of the "
               "ship|cargo bay}")],
          descriptionPage: "CorridorLeftNextToCaptainsCabin.description",
          coordinates: [-5, -10, 0]
    );
  }
  
  void setupBridge() {
    lookAtHullBreachFromBridge = 
        new Action.Goto("put up the hull breach on the screen",
        "LookAtHullBreachFromBridge", isActive: false, onlyOnce: true);
    askBodegaQuestions = new Action.Goto("ask Bodega some questions",
        "BodegaQuestions: Start", requirement: () => bodegaTopics.length > 0);
    takeANap = new Action.Goto("Take a nap",
        "Bridge: Nap", onlyOnce: true,
        requirement: () => zil.timeline.time < MAX_TIME_BEFORE_NAP);
    // TODO: add radar on/off
    waitForJumpToUnity = 
        new Action.Goto("Wait until ready to jump to Unity",
        "Bridge: WaitForJump", onlyOnce: true,
        requirement: () => 
            zil.timeline.time >= MESSENGER_CONTACT_TIME &&
            zil.timeline.time < MAX_TIME_BEFORE_HYPERDRIVE_READY &&
            !jumpedToUnity);
    jumpToSpaceStationUnity = 
        new Action.Goto("initiate the jump to Space Station Unity", 
        "Unity: Jump", isActive: false,
        requirement: () => !jumpedToUnity);
    
    // ITEMS
    // TODO: worn out map of the Bodega - near left Airlock
    
    // ROOM
    bridge = new Room(zil, "Explore: Bridge", // corresponds to pagename
       "the bridge",
       [
         new Exit("Explore: Nose", 
             "use the utility corridor to the nose of the ship",
             "<subject> squeeze<s> into the narrow space below the main "
             "'window'"),
         new Exit("Explore: CorridorLeftNextToCaptainsCabin", 
             "leave to Corridor Left",
             "<subject> {go<es>|walk<s>} through the sliding door into "
             "Corridor Left and – after a few more paces – arrive<s> at the "
             "entrance to the captain's cabin"),
         new Exit("Explore: CorridorRightNextToComputerRoom", 
             "leave to Corridor Right",
             "<subject> {go<es>|walk<s>} through the sliding door into "
             "Corridor Right and – after a few more paces – arrive<s> at the "
             "entrance to the computer room")
       ],
       descriptionPage: "Bridge.description",
       coordinates: [0, 0, 0],
       actors: [gorilla],
       actions: [
           waitForJumpToUnity,
           jumpToSpaceStationUnity,
           askBodegaQuestions,
           lookAtHullBreachFromBridge,
           takeANap
       ],
       onUpdate: () {
         // Check whether we just arrived to Unity.
         if (justArrivedAtUnity) {
           goto("Unity: Arrival");
           return false;
         }
         return true;
       }
    );
  }
  
  Room bridge;
  Action lookAtHullBreachFromBridge;
  Action askBodegaQuestions;
  Action takeANap;
  Action waitForJumpToUnity;
  Action jumpToSpaceStationUnity;
  
  void setupNose() {
    // ACTIONS
    scannerLook = new Action.Goto("Take a look at the scanner", 
        "Nose.ScannerLook", onlyOnce: true);
    scannerRepair = new Action.Goto("Repair the scanner", 
        "Nose.ScannerRepair", isActive: false, onlyOnce: true);
    // TODO: laser upgrade
    // TODO: floodlights repair
        
    // ROOM
    new Room(zil, "Explore: Nose",
        "nose of the ship",
        [new Exit("Explore: Bridge", "crawl back to the bridge",
            "<subject> crawl<s> out of the nose hatchway onto the bridge")],
        descriptionPage: "Nose.description",
        coordinates: [0, 5, 0],
        actions: [
            scannerLook,
            scannerRepair
        ]
    );
  }
  
  Action scannerLook;
  Action scannerRepair;
  
  AIActor gorilla;
  
  // Pointers to EgbScripter objects and functions.
  final Zil zil;
  final GotoFunction goto;
  final EchoFunction echo;
  final ChoiceFunction choice;
  final Map<String, Object> vars;
  PointsCounter points;
  Timeline exploration;
  
  // Utility functions.
  String getHoursToHyperdrive() {
      num hours = (MAX_TIME_BEFORE_HYPERDRIVE_READY - exploration.time) / 60;
      if (hours < 0) throw "getHoursToHyperdrive() called after jump";
      if (hours < 1) {
        int tenMinutes = (hours * 6).round();
        if (tenMinutes == 0) return "a few minutes";
        return "about ${tenMinutes}0 minutes";
      }
      return """${hours.round()} hour${hours >= 1.5 ? "s" : ""}""";
  }
  
  void printSleepiness() {
      int index = exploration.time ~/ (MAX_TIME_BEFORE_NAP / 5);
      if (index > 4) return;  // Only report sleepiness before the 'nap'.
      echo("""You are feeling ${tirednessStrings[index]}.""");
  }
  
  // Map saveable vars to strongly typed variables.
  Stat get clock => vars["clock"];
  String get salutation => vars["salutation"];
  String get name => vars["name"];
  List<String> get bodegaTopics => vars["bodegaTopics"];
  bool get jumpedToUnity => vars["jumpedToUnity"];
  bool get justArrivedAtUnity => vars["justArrivedAtUnity"];
  // Read & Write
  String get roomBeforeOvercameBySleepiness => 
      vars["roomBeforeOvercameBySleepiness"];
  set roomBeforeOvercameBySleepiness(String value) {
    vars["roomBeforeOvercameBySleepiness"] = value;
  }
  bool get stoleOfficersBanana => 
      vars["stoleOfficersBanana"];
  set stoleOfficersBanana(bool value) {
    vars["stoleOfficersBanana"] = value;
  }
  int get gorillaAttitude => 
      vars["gorillaAttitude"];
  set gorillaAttitude(int value) {
    vars["gorillaAttitude"] = value;
  }
  
}

const String INVENTORY = "···";  // Middle dots.

const int MAX_TIME_BEFORE_NAP = 148;
const int MESSENGER_CONTACT_TIME = 460;
const int MAX_TIME_BEFORE_HYPERDRIVE_READY = 473;

// Printing how tired the player is.
const List tirednessStrings = const ["quite tired", "really tired", 
                                     "extremely tired", "exhausted", 
                                     "absolutely exhausted"];