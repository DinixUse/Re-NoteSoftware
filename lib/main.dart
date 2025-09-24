import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:tofu_expressive/tofu_expressive.dart';
import 'package:floaty_nav_bar/floaty_nav_bar.dart';
import 'package:material_shapes/material_shapes.dart';

import 'note.dart';
import 'score.dart';

Map<String, dynamic> settingMap = {};
Map<String, dynamic> scoreMap = {};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  final SystemTray systemTray = SystemTray();

  // 设置托盘图标（需要准备一个ico文件）
  await systemTray.initSystemTray(
    title: "Re: Note",
    iconPath: "assets/icon/ecnu.ico", // 需要在pubspec.yaml中配置
  );

  // 创建菜单
  final Menu menu = Menu();
  await menu.buildFrom([
    MenuItemLabel(
      label: "顯示窗體",
      onClicked: (menuItem) => windowManager.focus(),
    ),
    MenuItemLabel(
      label: "關閉程式",
      onClicked: (menuItem) => windowManager.close(),
    ),
  ]);

  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventRightClick) {
      systemTray.popUpContextMenu();
    }
  });

  // 设置托盘菜单
  await systemTray.setContextMenu(menu);

  await windowManager.ensureInitialized();

  loadSettings().then((data) {
    int appW = settingMap["app-w"];
    int appH = settingMap["app-h"];
    int appX = settingMap["app-x"];
    int appY = settingMap["app-y"];

    WindowOptions windowOptions = WindowOptions(
      size: Size(appW.toDouble(), appH.toDouble()),
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      windowManager.setPosition(Offset(appX.toDouble(), appY.toDouble()));
      windowManager.setAsFrameless();
    });

    runApp(
      MyApp(
        appSeedColor: settingMap["app-seed-color"],
        isDarkMode: settingMap["app-dark-theme"],
      ),
    );
  });
}

Future<void> loadSettings() async {
  try {
    File _settingFile = File('C:/Users/Public/note_files/settings.json');
    String _settingString = await _settingFile.readAsString();
    settingMap = jsonDecode(_settingString);
  } catch (e) {
    File _settingFile = File('C:/Users/Public/note_files/settings.json');
    _settingFile.create();

    Map<String, dynamic> _settleMap = {
      "window-background-transparent": true,
      "app-dark-theme": false,
      "app-seed-color": 0xff4c662b,
    };

    String _settleString = jsonEncode(_settleMap);
    _settingFile.writeAsString(_settleString);

    settingMap = _settleMap;
  }

  try {
    File _scoreFile = File('C:/Users/Public/note_files/score.json');
    String _scoreString = await _scoreFile.readAsString();
    scoreMap = jsonDecode(_scoreString);
    print(scoreMap);
  } catch (e) {
    print("$e");

    File _scoreFile = File('C:/Users/Public/note_files/score.json');
    _scoreFile.create();

    Map<String, dynamic> _scoreTestMap = {"GS": 0, "MS": 0};

    String _scoreTestString = jsonEncode(_scoreTestMap);
    _scoreFile.writeAsString(_scoreTestString);

    scoreMap = _scoreTestMap;
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.appSeedColor, required this.isDarkMode});
  int appSeedColor;
  bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Re: Note',
      //theme: TofuTheme.light(seedColor: Color(appSeedColor)),
      //darkTheme: TofuTheme.dark(seedColor: Color(appSeedColor)),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(appSeedColor)),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MyHomePage(title: 'Re: Note'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _pages = [NotePage(), ScorePage(), SettingsPage()];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. 获取当前窗口的宽高（关键：绑定布局到窗口尺寸，避免无限大小）
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // 强制容器占满整个窗口，约束 Row 的最大范围
      width: screenWidth,
      height: screenHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // 2. 给每个子组件分配明确宽度，总宽度 = screenWidth
        children: [
          // 内容 Scaffold：用 Expanded 占满剩余宽度（主要内容区）
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: _pages,
              ),
              floatingActionButton: FloatyNavBar(
                shape: CircleShape(),
                selectedTab: _selectedIndex,
                tabs: [
                  FloatyTab(
                    isSelected: _selectedIndex == 0,
                    title: '記錄筆記',
                    icon: Icon(Icons.bookmark),
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() => _selectedIndex = 0);
                    },
                  ),
                  FloatyTab(
                    isSelected: _selectedIndex == 1,
                    title: '小組積分',
                    icon: Icon(Icons.person),
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  FloatyTab(
                    isSelected: _selectedIndex == 2,
                    title: '偏好設定',
                    icon: Icon(Icons.settings),
                    onTap: () {
                      _tabController.animateTo(2);
                      setState(() => _selectedIndex = 2);
                    },
                  ),
                ],
              ),
            ),
          ),
          // 3. Divider：固定宽度 1px，垂直分割线（需设置 height 占满窗口高度）
          /*Container(
            width: 1, // 分割线宽度（可调整）
            height: screenHeight, // 占满窗口高度，避免垂直对齐异常
            child: VerticalDivider(),
          ),
          // 4. 空 Scaffold：固定宽度（后续扩展用），高度占满窗口
          Container(
            width: 90, // 固定宽度（可根据需求调整，如 300px）
            height: screenHeight, // 占满窗口高度，避免拉伸异常
            child: Scaffold(
              
              backgroundColor: Colors.transparent,
              
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)
                      )
                    ),

                    color: Theme.of(context).colorScheme.tertiary,
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Text("課程", style: TextStyle(fontFamily: "微软雅黑", color: Theme.of(context).colorScheme.onTertiary),),
                      ),
                    )
                  )
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton.filledTonal(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: ClipRRect(
                    borderRadius: BorderRadius.circular(24.0),
                    child: Image.asset(
                      'assets/icon/ecnu.jpg',
                      width: 128.0,
                      height: 128.0,
                    ),
                  ),
                  applicationVersion: '9.8.5',
                  applicationName: 'Re: Note',
                  applicationLegalese:
                      '@2025 Dinix_NeverOSC, all rights reserved.',
                );
              },
              icon: Icon(Icons.info_outline),
            ),
            title: Text("Preferences"),
          ),

          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 36),
              Card(
                shadowColor: Colors.transparent,
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  width: 162,
                  child: ListTile(
                    title: Text(
                      "Looks and Feels",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8,),

              Card(
                shadowColor: Colors.transparent,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  title: Text("Change app seed color"),
                  subtitle: Text("Make it colorful as yourself ~"),
                  onTap: () {
                    
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
