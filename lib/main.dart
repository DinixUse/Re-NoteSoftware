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
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

import 'note.dart';
import 'score.dart';

Map<String, dynamic> settingMap = {};
Map<String, dynamic> scoreMap = {};

bool isDarkMode = false;

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

    isDarkMode = settingMap["app-dark-theme"];

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(appSeedColor),
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(title: 'Re: Note'),
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
                //margin: EdgeInsets.all(24),
                //gap: 0,
                shape: CircleShape(),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                selectedTab: _selectedIndex,
                tabs: [
                  FloatyTab(
                    unselectedColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    isSelected: _selectedIndex == 0,
                    title: '記錄筆記',
                    icon: Icon(Icons.bookmark),
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() => _selectedIndex = 0);
                    },
                  ),

                  FloatyTab(
                    unselectedColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    isSelected: _selectedIndex == 1,
                    title: '小組積分',
                    icon: Icon(Icons.person),
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() => _selectedIndex = 1);
                    },
                  ),
                  FloatyTab(
                    unselectedColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
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
  Color selectedColor = const Color(0xFF42A5F5);

  static const WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      });

  final Map<ColorSwatch<Object>, String> customColors = {
    ColorTools.createPrimarySwatch(const Color(0xFFE91E63)): "粉色",
    ColorTools.createPrimarySwatch(const Color(0xFF9C27B0)): "紫色",
    ColorTools.createPrimarySwatch(const Color(0xFF673AB7)): "深紫",
    ColorTools.createPrimarySwatch(const Color(0xFF2196F3)): "蓝色",
    ColorTools.createPrimarySwatch(const Color(0xFF00BCD4)): "青色",
    ColorTools.createPrimarySwatch(const Color.fromARGB(255, 58, 160, 61)): "绿",
    ColorTools.createPrimarySwatch(const Color(0xFFFFEB3B)): "黄色",
    ColorTools.createPrimarySwatch(const Color(0xFFFF9800)): "橙色",
    ColorTools.createPrimarySwatch(const Color(0xFFFF5722)): "深橙",
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(12),
      shadowColor: Colors.black,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton.filledTonal(
              onPressed: () {
                showAnimatedDialog(
                  animationType: DialogTransitionType.slideFromTopFade,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: Duration(milliseconds: 500),
                  context: context,
                  builder: (context) {
                    return AboutDialog(
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
                      children: [
                        SizedBox(height: 24),
                        ListTile(
                          minTileHeight: 64,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          title: Center(
                            child: Text(
                              "Visit website",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        SizedBox(height: 4),

                        ListTile(
                          minTileHeight: 64,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          title: Center(
                            child: Text(
                              "Dinix_NeverOSC on Bilibili",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),

                        SizedBox(height: 4),
                        ListTile(
                          minTileHeight: 64,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          tileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          title: Center(
                            child: Text(
                              "Send feedback",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        SizedBox(height: 24),
                        Divider(thickness: 2, radius: BorderRadius.circular(4)),
                      ],
                    );
                  },
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

              SizedBox(height: 8),

              Card(
                shadowColor: Colors.transparent,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                margin: EdgeInsets.all(2),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  title: Text("Change app seed color"),
                  subtitle: Text("Make it colorful as yourself ~"),
                  onTap: () {
                    showAnimatedDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: ColorPicker(
                                      color: selectedColor,
                                      onColorChanged: (Color color) {
                                        setState(() => selectedColor = color);
                                      },
                                      width: 40,
                                      height: 40,
                                      borderRadius: 4,
                                      spacing: 5,
                                      runSpacing: 5,
                                      // 只启用自定义颜色选择器
                                      pickersEnabled: const {
                                        ColorPickerType.custom: true,
                                        ColorPickerType.primary: false,
                                        ColorPickerType.accent: false,
                                        ColorPickerType.wheel: false,
                                        ColorPickerType.bw: false,
                                        ColorPickerType.both: false,
                                      },
                                      // 设置自定义颜色
                                      customColorSwatchesAndNames: customColors,
                                      // 显示颜色名称
                                      showColorName: false,
                                      // 显示颜色代码
                                      showColorCode: false,
                                      // 标题和子标题
                                      heading: Card(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Container(
                                          width: 140,
                                          height: 48,
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                'Pick Colors',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      subheading: Card(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiaryContainer,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Container(
                                          width: 140,
                                          height: 48,
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                'Brightness',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  /*Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(24),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        title: Text(
                                          "取消",
                                          style: TextStyle(fontFamily: "微软雅黑", color: Theme.of(context).colorScheme.onPrimaryContainer),
                                          
                                        ),
                                      ),
                                    ),*/
                                  /*FilledButton(
                                      onPressed: () {},
                                      child: Text("OK"),
                                    ),

                                    OutlinedButton(onPressed: (){}, child: Text("Cancel"))*/
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Card(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        /*ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(24),
                                                  topRight: Radius.circular(8),
                                                  bottomLeft: Radius.circular(
                                                    24,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                              ),

                                              title: Text("Cancel"),
                                              onTap: () {
                                                
                                              },
                                            ),*/
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.close),
                                              SizedBox(width: 2),
                                              Text("Cancel"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(24),
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(24),
                                          ),
                                        ),

                                        child: TextButton(
                                          //focusNode: FocusNode(),
                                          onPressed: () {
                                            try {
                                              String _selectedColorString = "FF${selectedColor.hex}";
                                              print(_selectedColorString);
                                              int _selectedColorInt = 0;
                                              Map<String, int> _woShiGeShaBi = {
                                                "0": 0,
                                                "1": 1,
                                                "2": 2,
                                                "3": 3,
                                                "4": 4,
                                                "5": 5,
                                                "6": 6,
                                                "7": 7,
                                                "8": 8,
                                                "9": 9,
                                                "A": 10,
                                                "B": 11,
                                                "C": 12,
                                                "D": 13,
                                                "E": 14,
                                                "F": 15
                                              };
                                              for(int i = 0; i < _selectedColorString.length; i++){
                                                int _sixteenSquare = 1;
                                                for(int j = 0; j < i; j++){
                                                  _sixteenSquare = _sixteenSquare * 16;
                                                }
                                                _selectedColorInt += _woShiGeShaBi[_selectedColorString[_selectedColorString.length - i - 1]]! * _sixteenSquare;
                                                
                                              }
                                              settingMap["app-seed-color"] = _selectedColorInt;
                                              File('C:/Users/Public/note_files/settings.json',).writeAsStringSync(jsonEncode(settingMap),);
                                            } catch (e) {
                                              print(e);
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.adb,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                "Apply ",
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      animationType: DialogTransitionType.slideFromTopFade,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                ),
              ),

              Card(
                margin: EdgeInsets.all(2),

                shadowColor: Colors.transparent,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: SwitchListTile(
                  thumbIcon: thumbIcon,
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });

                    try {
                      settingMap["app-dark-theme"] = isDarkMode;
                      File(
                        'C:/Users/Public/note_files/settings.json',
                      ).writeAsStringSync(jsonEncode(settingMap));
                    } catch (e) {
                      print(e);
                    }

                    showAnimatedDialog(
                      animationType: DialogTransitionType.slideFromTopFade,
                      curve: Curves.fastEaseInToSlowEaseOut,
                      duration: Duration(milliseconds: 500),
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Restart the app to apply this."),
                          content: IntrinsicHeight(
                            child: Center(
                              child: Icon(Icons.restart_alt, size: 128),
                            ),
                          ),
                          actions: [
                            ListTile(
                              minTileHeight: 64,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              title: Center(
                                child: Text(
                                  "Got it",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              tileColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            SizedBox(height: 4),
                            ListTile(
                              minTileHeight: 64,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              title: Center(
                                child: Text(
                                  "Send Feedback",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              tileColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              onTap: () {},
                            ),
                          ],
                        );
                      },
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  title: Text("Dark theme"),
                  subtitle: Text("Day night mode switch."),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
