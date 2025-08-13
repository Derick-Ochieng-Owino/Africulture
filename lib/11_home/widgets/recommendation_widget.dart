// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
//   final GlobalKey appBarNotificationKey = GlobalKey();
//   final GlobalKey appBarSearchKey = GlobalKey();
//   final GlobalKey _homeKey = GlobalKey();
//   final GlobalKey _menuKey = GlobalKey();
//   final GlobalKey _appBarKey = GlobalKey();
//   final GlobalKey _aiAssistantKey = GlobalKey();
//   final List<GlobalKey> bottomNavKeys = List.generate(3, (_) => GlobalKey());
//   final List<GlobalKey> quickActionKeys = List.generate(8, (_) => GlobalKey());
//   bool _showHelp = true;
//
//   late TutorialCoachMark tutorialCoachMark;
//
//   int myIndex = 0;
//   late PageController _pageController;
//   late ScrollController _scrollController;
//   bool _isBottomBarVisible = true;
//   late AnimationController _fabAnimationController;
//
//   String username = '';
//   String userEmail = '';
//   String profileImageUrl = '';
//   String userLocation = 'Loading...';
//
//   Future<void> getUserInfo(String uid) async {
//     final doc = await FirebaseFirestore.instance
//         .collection('farmers')
//         .doc(uid)
//         .get();
//     final data = doc.data();
//     if (data != null) {
//       setState(() {
//         username = data['name'] ?? '';
//         userEmail = data['email'] ?? '';
//         profileImageUrl = data['photoUrl'] ?? '';
//         userLocation = data['village'] ?? 'Unknown location';
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pageController = PageController();
//     _scrollController = ScrollController();
//     //_scrollController.addListener(_scrollListener);
//     _fabAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       getUserInfo(currentUser.uid);
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         checkProfileAndShowModal(context, currentUser.uid);
//       });
//     }
//
//     _fabAnimationController.forward();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(Duration(seconds: 1), () {
//         setState(() => _showHelp = true);
//       });
//     });
//   }
//
//   //
//   // void _scrollListener() {
//   //   if (_scrollController.position.userScrollDirection ==
//   //       ScrollDirection.reverse) {
//   //     if (_isBottomBarVisible) {
//   //       setState(() => _isBottomBarVisible = false);
//   //       _fabAnimationController.reverse();
//   //     }
//   //   } else if (_scrollController.position.userScrollDirection ==
//   //       ScrollDirection.forward) {
//   //     if (!_isBottomBarVisible) {
//   //       setState(() => _isBottomBarVisible = true);
//   //       _fabAnimationController.forward();
//   //     }
//   //   }
//   // }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _scrollController.dispose();
//     _fabAnimationController.dispose();
//     super.dispose();
//   }
//
//   void onTabTapped(int index) {
//     setState(() {
//       myIndex = index;
//       _pageController.jumpToPage(index);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final helpSteps = OnboardingHelper.homePageHelpSteps(
//     //   homeKey: _homeKey,
//     //   menuKey: _menuKey,
//     //   aiAssistantKey: _aiAssistantKey,
//     //   bottomNavKeys: bottomNavKeys,
//     //   quickActionKeys: quickActionKeys,
//     //   appBarNotificationKey: appBarNotificationKey,
//     //   appBarSearchKey: appBarSearchKey,
//     // );
//
//     final scaffold = Scaffold(
//       backgroundColor: const Color(0xFFF5F9F3),
//       drawer: username.isNotEmpty
//           ? CustomDrawer(
//         userName: username,
//         userEmail: userEmail,
//         profileImageUrl: profileImageUrl,
//         location: userLocation,
//       )
//           : null,
//       appBar: AppBar(
//         key: _appBarKey,
//         backgroundColor: Colors.teal,
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         leading: Builder(
//           builder: (context) => IconButton(
//             key: _menuKey,
//             icon: const Icon(Icons.menu),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/app_logo.png',
//               height: 30,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Africulture',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             key: appBarNotificationKey,
//             icon: const Icon(Icons.notifications_none),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const NotificationPage()),
//             ),
//           ),
//           IconButton(
//             key: appBarSearchKey,
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // Implement search functionality
//             },
//           ),
//         ],
//       ),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) => setState(() => myIndex = index),
//         children: [
//           KeyedSubtree(
//             key: _homeKey,
//             child: HomePageContent(
//               scrollController: _scrollController,
//               userName: username,
//               location: userLocation,
//               quickActionKeys: quickActionKeys,
//             ),
//           ),
//           const NewsPage(showAppBar: false),
//           FirebaseAuth.instance.currentUser != null
//               ? ProfilePage(user: FirebaseAuth.instance.currentUser!, showAppBar: false)
//               : const Center(child: Text("Please login to view profile")),
//         ],
//       ),
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         height: _isBottomBarVisible ? 70 : 0,
//         child: Wrap(
//           children: [
//             BottomNavigationBar(
//               backgroundColor: Colors.white,
//               currentIndex: myIndex,
//               selectedItemColor: const Color(0xFF2E7D32),
//               unselectedItemColor: Colors.grey.shade600,
//               selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
//               type: BottomNavigationBarType.fixed,
//               onTap: onTabTapped,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_outlined, key: bottomNavKeys[0]),
//                   activeIcon: const Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.article_outlined, key: bottomNavKeys[1]),
//                   activeIcon: const Icon(Icons.article),
//                   label: 'News',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_outline, key: bottomNavKeys[2]),
//                   activeIcon: const Icon(Icons.person),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: ScaleTransition(
//         scale: _fabAnimationController,
//         child: FloatingActionButton(
//           key: _aiAssistantKey,
//           backgroundColor: const Color(0xFF4CAF50),
//           onPressed: () => showDialog(
//             context: context,
//             barrierDismissible: true,
//             builder: (BuildContext context) => const AIAssistantPopup(),
//           ),
//           child: const Icon(Icons.assistant, color: Colors.white),
//         ),
//       ),
//     );
//
//     // return _showHelp
//     //     ? HelpWidgetOverlay(
//     //   scrollController: _scrollController,
//     //   //steps: helpSteps,
//     //   onComplete: () {
//     //     setState(() => _showHelp = false);
//     //     // Save to SharedPreferences that onboarding was completed
//     //   },
//     //   child: scaffold,
//     // )
//     //     : scaffold;
//   }
// }