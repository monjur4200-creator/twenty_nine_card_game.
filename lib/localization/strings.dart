class Strings {
  final String languageCode;

  Strings(this.languageCode);

  bool get isBangla => languageCode == 'bn';

  String get mainMenuTitle => isBangla ? 'মূল মেনু' : 'Main Menu';
  String get startGame => isBangla ? 'খেলা শুরু করুন' : 'Start Game';
  String get createRoom => isBangla ? 'রুম তৈরি করুন' : 'Create Room';
  String get joinRoom => isBangla ? 'রুমে যোগ দিন' : 'Join Room';
  String get enterRoomId => isBangla ? 'রুম আইডি লিখুন' : 'Enter Room ID';
  String get rules => isBangla ? 'নিয়মাবলী' : 'Rules';
  String get settings => isBangla ? 'সেটিংস' : 'Settings';
  String get viewRules => isBangla ? 'নিয়ম দেখুন' : 'View Rules';
  String get pleaseEnterRoomId => isBangla ? 'অনুগ্রহ করে রুম আইডি লিখুন' : 'Please enter a Room ID';
  String get enjoyGame => isBangla ? 'খেলা উপভোগ করুন!' : 'Enjoy the game!';
  String get waitingForPlayers => isBangla ? 'খেলোয়াড়দের জন্য অপেক্ষা করছি...' : 'Waiting for players...';
  String get leaveRoom => isBangla ? 'রুম ছাড়ুন' : 'Leave Room';
  String get connectionFailed => isBangla ? '❌ সংযোগ ব্যর্থ হয়েছে' : '❌ Connection failed';
  String get noDevicesFound => isBangla ? 'কোনো ডিভাইস পাওয়া যায়নি' : 'No Devices Found';
  String get noPairedDevices => isBangla ? 'কোনো পেয়ার করা ব্লুটুথ ডিভাইস পাওয়া যায়নি।' : 'No paired Bluetooth devices were found.';
  String get ok => isBangla ? 'ঠিক আছে' : 'OK';
  String get selectDevice => isBangla ? 'ডিভাইস নির্বাচন করুন' : 'Select a Device';
  String get disconnected => isBangla ? '🔌 সংযোগ বিচ্ছিন্ন হয়েছে' : '🔌 Disconnected';
  String get gameTableTitle => isBangla ? 'গেম টেবিল' : 'Twenty Nine - Game Table';
  String get restartSimulation => isBangla ? 'সিমুলেশন পুনরায় শুরু করুন' : 'Restart Simulation';
  String get simulationPrompt => isBangla ? 'ফলাফল দেখতে "গেম চালান" চাপুন' : 'Tap "Run Game Simulation" to see results';
  String get runSimulation => isBangla ? 'গেম চালান' : 'Run Game Simulation';
  String get connectMultiplayer => isBangla ? 'সংযোগ (মাল্টিপ্লেয়ার)' : 'Connect (Multiplayer)';
  String get disconnect => isBangla ? 'সংযোগ বিচ্ছিন্ন করুন' : 'Disconnect';
  String get goToBiddingScreen => isBangla ? 'বিডিং স্ক্রিনে যান' : 'Go to Bidding Screen';
  String get goToRoundSummary => isBangla ? 'রাউন্ড সারাংশে যান' : 'Go to Round Summary';
  String get firstBatchComplete => isBangla ? 'প্রথম ব্যাচ সম্পন্ন। এখন বিড করুন!' : 'First batch dealt. Time to bid!';
  String get dealNextBatch => isBangla ? 'পরবর্তী ব্যাচ ডিল করুন' : 'Deal Next Batch';
  String get unknownPlayer => isBangla ? 'অজানা খেলোয়াড়' : 'Unknown';
  String get youLabel => isBangla ? '(আপনি)' : '(You)';
  String get lobbyTitle => isBangla ? 'লবির তালিকা' : 'Lobby';
  String get loginAndConnectWarning => isBangla
      ? 'অনুগ্রহ করে লগইন করুন এবং সংযোগ দিন'
      : 'Please log in and connect to continue.';
}