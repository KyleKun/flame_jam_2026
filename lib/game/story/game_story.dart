// Single source of truth for the game's written story.
// Edit dialogue here without touching scene flow in `my_game.dart`.

enum StorySceneId {
  salaIntro,
  salaPostTv,
  kitchenIntro,
  kitchenPostMinigame,
  salaChubbyCheck,
  salaChubbyPostTv,
  quintalIntro,
  soccerPostWin,
  soccerPostPhone,
  bathroomIntro,
  bathroomPostMinigame,
  bathroomPostReset,
  bathroomPostPhone,
  musicRoomIntro,
  musicRoomPostMinigame,
  musicRoomPostPhone,
  musicRoomPostSubscription,
  codeRoomIntro,
  codeRoomPostMinigame,
  codeRoomPostNothing,
  codeRoomPostNothingCont,
  frontHouseIntro,
  frontHouseIntroCont,
  frontHousePostMinigame,
  frontHousePostPhone,
  frontHouseChase,
  salaFinale,
  salaFinaleLaugh,
}

enum StoryActorId { bro1, chubby, blonde, big, suit, blue, strong }

enum StoryDialogueSide { left, right }

class StoryLine {
  const StoryLine({
    required this.speaker,
    required this.side,
    required this.text,
    this.actorImagePath,
    this.portraitAssetPath,
    this.flipHorizontally,
    this.portraitOffsetX,
    this.portraitOffsetY,
    this.alsoChangeActor,
    this.alsoChangeActorImagePath,
  });

  final StoryActorId speaker;
  final StoryDialogueSide side;
  final String text;
  final String? actorImagePath;
  final String? portraitAssetPath;
  final bool? flipHorizontally;
  final double? portraitOffsetX;
  final double? portraitOffsetY;
  final StoryActorId? alsoChangeActor;
  final String? alsoChangeActorImagePath;
}

class StorySceneScript {
  const StorySceneScript({
    required this.id,
    required this.label,
    required this.lines,
  });

  final StorySceneId id;
  final String label;
  final List<StoryLine> lines;
}

StoryLine _bro1Line(String text, {String? expression}) {
  return StoryLine(
    speaker: StoryActorId.bro1,
    side: StoryDialogueSide.left,
    text: text,
    actorImagePath: expression,
  );
}

class GameStory {
  static final List<StorySceneScript> scenes = [
    StorySceneScript(
      id: StorySceneId.salaIntro,
      label: 'Sala Opening',
      lines: [
        _bro1Line(
          'Sunday mornings are the best.',
          expression: 'chars/bro1_smileface.png',
        ),
        _bro1Line('Wanna know why?', expression: 'chars/bro1_smileface.png'),
        _bro1Line(
          'Because new episodes of my favorite show are released on Brodaflix!',
          expression: 'chars/bro1_wowface.png',
        ),
        _bro1Line(
          'Nothing beats Brodaflix and chill.',
          expression: 'chars/bro1_smileface.png',
        ),
        _bro1Line(
          'Specially when we are talking about "Sponge Brother Rounded Pants."',
          expression: 'chars/bro1_wowface.png',
        ),
        _bro1Line(
          'Enough chatter, let me turn on the TV.',
          expression: 'chars/bro1_smileface.png',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.salaPostTv,
      label: 'Sala After TV Breaks',
      lines: [
        _bro1Line(
          'What? Why is it not working?',
          expression: 'chars/bro1_wowface.png',
        ),
        _bro1Line(
          'No no no, this can\'t be happening, not on a sacred Sunday morning!',
          expression: 'chars/bro1chorando.png',
        ),
        _bro1Line(
          'I need to ask Big Bro, he surely can fix this.',
          expression: 'chars/bro1_noface.png',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.kitchenIntro,
      label: 'Kitchen - TV Emergency',
      lines: [
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          flipHorizontally: true,
          text: 'BIG BRO, BIG BRO, IT\'S AN EMERGENCY!',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          flipHorizontally: true,
          text: 'THE TV IS NOT WORKING AND MY FAVORITE SHOW IS ABOUT TO START!',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/chubbyangry.png',
          flipHorizontally: false,
          text: 'Stop yelling at me, Lil Bro!',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/chubbyangry.png',
          flipHorizontally: false,
          text: "Don't you see I'm busy preparing my lunch?",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_wowface.png',
          flipHorizontally: true,
          text: 'Lunch? You will have fruits for lunch?',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/chubbyangry.png',
          flipHorizontally: false,
          text: 'Listen... I told you I am on a diet.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/chubbyangry.png',
          flipHorizontally: false,
          text: 'And when someone is on a diet, drastic measures are needed.',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          flipHorizontally: true,
          text: 'I see, sorry Big Bro...',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text:
              'Never mind. Just wait a minute and I will go check the TV for you.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: "But first, let me finish what I've started.",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_smileface.png',
          flipHorizontally: true,
          text: 'Okay!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.kitchenPostMinigame,
      label: 'Kitchen After Fruit Salad',
      lines: [
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: "It's done! Let's go help Lil Bro now.",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.salaChubbyCheck,
      label: 'Sala - Chubby Checks TV',
      lines: [
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Okay Lil Bro, I see the issue.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'I will do the obvious thing and it should fix the TV.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Turn it off and turn it on again.',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.salaChubbyPostTv,
      label: 'Sala - Chubby TV Failed',
      lines: [
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Oh well...',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Seems like this is a bigger problem.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'And bigger problems require a bigger bro.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text:
              "Don't worry, I'm sure our Big Bro can fix it. I'll go talk to him.",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          flipHorizontally: true,
          text: 'Okay...',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.quintalIntro,
      label: 'Backyard Meet-Up',
      lines: [
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          text: 'Big Bro, I need your help!',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/blondechallenge.png',
          portraitAssetPath: 'assets/images/chars/blondechallenge.png',
          text: "Stop right there! Don't say another word!",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/blondechallenge.png',
          portraitAssetPath: 'assets/images/chars/blondechallenge.png',
          alsoChangeActor: StoryActorId.chubby,
          alsoChangeActorImagePath: 'chars/chubbyangry.png',
          text:
              'Before I hear what you have to say, you must play soccer with me.',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/blondechallenge.png',
          portraitAssetPath: 'assets/images/chars/blondechallenge.png',
          text: "Yes, this doesn't make any sense, but it is what it is!",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.soccerPostWin,
      label: 'After The Soccer Win',
      lines: [
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/blondechallenge.png',
          portraitAssetPath: 'assets/images/chars/blondechallenge.png',
          text: 'Huh, you made me sweat. Not bad, Lil Bro.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/chubbyangry.png',
          portraitAssetPath: 'assets/images/chars/chubbyangry.png',
          text: 'Can I say it now?',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: 'Yeah, I am all ears.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          text: "Lil Bro was trying to watch Brodaflix but it's not working.",
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          text: "I tried turning it off and on again but didn't work.",
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          text: 'Any ideas?',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text:
              "Hmm, there's just one thing a sensible person would do in a situation like this.",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: 'And of course, that thing is calling the support!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.soccerPostPhone,
      label: 'After The Phone Call',
      lines: [
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: 'Oh no, they are closed on Sundays!',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: "I am sorry, Bro. I don't know what to do now...",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: 'Except asking our Big Bro for help!',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.right,
          text: "Wait a moment, I'll ask him.",
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.left,
          text: 'Alright!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.bathroomIntro,
      label: 'Bathroom Meet-Up',
      lines: [
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text:
              "Big Bro, sorry to enter the bathroom. I'm sure you might be busy...",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/big2.png',
          flipHorizontally: true,
          text: 'Yes, Lil Bro. Very busy. Now go away.',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text: "Wait! I need your help, it's a serious matter.",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/big2.png',
          flipHorizontally: true,
          text: 'No, I need YOUR help.',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/big2.png',
          flipHorizontally: true,
          text: 'See this hair of mine?',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/big2.png',
          flipHorizontally: true,
          text:
              "I have a punk concert to attend tonight. And this hair won't do.",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text:
              "Say no more, I've got you, Bro. I will help you fix your hair and then you help me out. Deal?",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/big2.png',
          flipHorizontally: true,
          text: 'Deal.',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.bathroomPostMinigame,
      label: 'After The Bathroom Styling',
      lines: [
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: "Holy, you've got skills, Lil Bro.",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text:
              "Why don't you become a hairstylist instead of a soccer player?",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/blondechallenge.png',
          flipHorizontally: false,
          portraitOffsetX: 0,
          text: "Hehe, I can be both! But never mind that, listen...",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text:
              "Lil Bro is trying to watch Brodaflix, but there is an issue with the TV or something.",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text:
              "I tried calling support, but they are not working today, so I have no idea what to do.",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'Oh my, oh my, this is simple.',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'See that wifi extender over there?',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text:
              "The TV is connected to it, so it should be the case that it disconnected or something.",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'A simple reset shall fix it. Let me do it for ya.',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.bathroomPostReset,
      label: 'After The Wifi Reset',
      lines: [
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: "Done. Now check with Lil Bro if it's working.",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/blondechallenge.png',
          flipHorizontally: false,
          portraitOffsetX: 0,
          text: "Yay, thanks, Bro! Lemme text him.",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.bathroomPostPhone,
      label: 'After The Text Messages',
      lines: [
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text: "He said nothing changed...",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text:
              "Oh damn... I'll go check with Big Bro. He might know what's going on.",
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          flipHorizontally: false,
          portraitOffsetX: 0,
          text: 'Good luck!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.musicRoomIntro,
      label: 'Music Room Briefing',
      lines: [
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: 'Hey Big Bro, we need your help!',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'SILENCE!',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: "Don't you see I am listening to Mozart?",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'When music like this is playing, no one says a word.',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'So keep quiet!',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: 'But...',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/suit2.png',
          portraitOffsetY: -18,
          text: 'Enough!',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/suit2.png',
          portraitOffsetY: -18,
          text: 'You shall now face the consequences!',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: 'Oh no, here comes another minigame...',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.musicRoomPostMinigame,
      label: 'After The Music Room',
      lines: [
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text:
              "Now that the first movement is over, you've got exactly 6.9 seconds to tell me what you need.",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: "Lil Bro is crying because Brodaflix isn't working...",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.musicRoomPostPhone,
      label: 'After The Subscription Check',
      lines: [
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/suit2.png',
          portraitOffsetY: -18,
          text: "Crying? Okay, I will listen to this piece later.",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/suit2.png',
          portraitOffsetY: -18,
          text: "Tell me, what's going on?",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: 'Basically, the TV shows an error message.',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text:
              'We tried turning it on and off, calling support, resetting the wifi, but nothing worked so far.',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: 'Do you have any idea what it might be?',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text:
              "Let me check the subscription status, though I'm sure I paid it a few days ago...",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.musicRoomPostSubscription,
      label: 'After The Subscription Check',
      lines: [
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text:
              "Yeah, it says the subscription is active, so there's no issues with payment...",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text:
              'Since you guys tried everything else, we will need to take this to our tech Big Bro.',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.left,
          portraitOffsetY: -22,
          text: "I'm counting on you!",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.codeRoomIntro,
      label: 'Code Room Hack Prep',
      lines: [
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          portraitOffsetY: -18,
          text: 'Big Bro, please listen to me!',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: "What's going on?",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          portraitOffsetY: -18,
          text: "Lil Bro said Brodaflix isn't working.",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: 'And I assume you tried everything already, right?',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          portraitOffsetY: -18,
          text: "Exactly! (Oh God, he's so smart!)",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: "Then, there's only one choice.",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          portraitOffsetY: -18,
          text: 'And what is it?',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: 'Simple.',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text:
              "I'm gonna legally hack Brodaflix servers and inject a payload that allows me to monitor their health status, see all their systems code, fix any problems remotely, reallocate resources to the instance our account region is based on, and more. Just wait a bit, it will take 5 minutes.",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          portraitOffsetY: -18,
          text: 'Uhhh, okay then. (Oh God, he is a genius!)',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.codeRoomPostMinigame,
      label: 'After The Hack',
      lines: [
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text:
              'I checked everything, from server logs to commit history, and you know what I found?',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'What?',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.codeRoomPostNothing,
      label: 'The Nothing Reveal',
      lines: [
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          actorImagePath: 'chars/blue2.png',
          portraitAssetPath: 'assets/images/chars/blue2.png',
          text: 'Nothing!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.codeRoomPostNothingCont,
      label: 'After The Nothing Reveal',
      lines: [
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'Oh my...',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: "I didn't want to do this, but seems like we have no choice...",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'Talk to Big Bro, right?',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: 'Yeah. He hates when we ask things about Brodaflix to him.',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: "But since he WORKS there, he's our last hope...",
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.right,
          portraitOffsetY: -18,
          text: 'Good luck with Big Bro, Big Bro!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.frontHouseIntro,
      label: 'Front House Dog Training',
      lines: [
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: "'Sup, Big Bro, what are you doing?",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text: "Yo, I'm training this dog. Just found him!",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.frontHouseIntroCont,
      label: 'Front House Dog Training (cont)',
      lines: [
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text:
              "You're training him? Shouldn't you look for his owner instead?",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text:
              "Maybe, but I bet his owner will be happier if his dog comes back disciplined.",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strong2.png',
          portraitAssetPath: 'assets/images/chars/strong2.png',
          text: 'After all, body and mind training are for everyone!',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: 'Well, if you say so...',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: "Can you help me out after you're done with it?",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strong.png',
          text:
              "Sure, he's learning fast, so we should be done pretty soon. Just wait a bit, okay?",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.frontHousePostMinigame,
      label: 'After The Dog Training',
      lines: [
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text: 'Now tell me, Lil Bro, how can I help you?',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text:
              'You see, I know you hate when I ask you about Brodaflix, but...',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strongangry.png',
          portraitAssetPath: 'assets/images/chars/strongangry.png',
          text: 'I told you a million times before, Lil Bro.',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strongangry.png',
          portraitAssetPath: 'assets/images/chars/strongangry.png',
          text:
              'I work for their Marketing department. I am a model, and nothing else.',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text:
              "I knowwww, but look, Lil Bro is crying right now because he can't watch his favorite show.",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text:
              "And all the bros tried to help, myself included, and we couldn't figure out why Brodaflix isn't working.",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          portraitOffsetY: -16,
          text: 'Can you make a quick call or something? Just this one time...',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text:
              "Alright, since it's Lil Bro's favorite show we are talking about, I will make this a one-time exception.",
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.frontHousePostPhone,
      label: 'After The Phone Messages',
      lines: [
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strongangry.png',
          portraitAssetPath: 'assets/images/chars/strongangry.png',
          text:
              "There's nothing wrong lil bro, so I can assume you just said that to provoke me, huh?",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bluesurprise.png',
          portraitAssetPath: 'assets/images/chars/bluesurprise.png',
          portraitOffsetY: -16,
          text: "No, I'd never do that, I promise you!",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strongangry.png',
          portraitAssetPath: 'assets/images/chars/strongangry.png',
          text:
              "Either way, you got on my nerves and I am kinda mad now, so...",
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bluethink.png',
          portraitAssetPath: 'assets/images/chars/bluethink.png',
          portraitOffsetY: -16,
          text: 'I better run?',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/strongangry.png',
          portraitAssetPath: 'assets/images/chars/strongangry.png',
          text: 'Yeah, you better run!',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.salaFinale,
      label: 'Sala Finale',
      lines: [
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_smileface.png',
          text: 'You guys are all here!',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Of course!',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          text: "Let's end this quickly, I wanna play soccer!",
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'What are we doing here, again?',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          text: 'I am happy you are not crying anymore...',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: 'Big Bro almost killed me, but I am still alive somehow.',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.left,
          text: "Let's just buy another TV!",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          text: 'Wait, brothers, I need to tell you something...',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          text:
              "The TV wasn't working until I got the message from our soccer addict bro.",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          text:
              'Turns out, a few seconds after the Wi-Fi was reset, it went back to normal...',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'I knew it!',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: "Goddamn, I should've just checked the TV itself.",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_wowface.png',
          text: 'BUT!',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          text: 'I originally asked Diet Bro for help.',
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          actorImagePath: 'chars/chubbyangry.png',
          flipHorizontally: false,
          text: 'Diet Bro, huh?',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_noface.png',
          alsoChangeActor: StoryActorId.chubby,
          alsoChangeActorImagePath: 'chars/chubby.png',
          text:
              'But then after I got the message, I noticed you guys were all working together to help me out.',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text:
              "And it's so rare these days for everyone to interact with each other...",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text:
              "Everyone has their own stuff going on, and life just flies, you know?",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text: "We are all so different, but we are still brothers...",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text:
              "Then I decided not to tell anyone that it was already fixed...",
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text:
              'That way, you guys could keep talking to each other some more.',
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text: '...',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/suit2.png',
          text: 'Oh God...',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          text: 'Not gonna lie, Lil Bro, you got me a bit emotional here...',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1chorando.png',
          text: 'So now that we are all here...',
        ),
        StoryLine(
          speaker: StoryActorId.bro1,
          side: StoryDialogueSide.left,
          actorImagePath: 'chars/bro1_smileface.png',
          alsoChangeActor: StoryActorId.suit,
          alsoChangeActorImagePath: 'chars/suit.png',
          text: 'How about we watch the show together?',
        ),
        StoryLine(
          speaker: StoryActorId.big,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -22,
          text: 'Brodaflix and chill?',
        ),
        StoryLine(
          speaker: StoryActorId.blonde,
          side: StoryDialogueSide.left,
          text: "I'm in!",
        ),
        StoryLine(
          speaker: StoryActorId.chubby,
          side: StoryDialogueSide.right,
          flipHorizontally: false,
          text: 'Yay, let me grab lunch!',
        ),
        StoryLine(
          speaker: StoryActorId.suit,
          side: StoryDialogueSide.left,
          text: 'Count me in!',
        ),
        StoryLine(
          speaker: StoryActorId.blue,
          side: StoryDialogueSide.right,
          flipHorizontally: true,
          portraitOffsetY: -16,
          text: "It's been a long time since I watched TV, let's gooo!",
        ),
        StoryLine(
          speaker: StoryActorId.strong,
          side: StoryDialogueSide.right,
          text: 'Alright, but we might need another sofa...',
        ),
      ],
    ),
    StorySceneScript(
      id: StorySceneId.salaFinaleLaugh,
      label: 'Sala Finale Laugh',
      lines: [_bro1Line('HAHAHAHAHAHAHA')],
    ),
  ];

  static StorySceneScript scene(StorySceneId id) {
    return scenes.firstWhere((scene) => scene.id == id);
  }
}
