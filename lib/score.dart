import 'dart:convert';
import 'dart:ffi';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_shapes/material_shapes.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:re_notesoftware/main.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';

class DateTimeUtils {
  // 获取当前时间并格式化为字符串
  static String getCurrentDateTimeString() {
    // 获取当前时间
    DateTime now = DateTime.now();

    // 定义日期时间格式
    // 常用格式示例：
    // yyyy-MM-dd HH:mm:ss -> 2023-10-05 14:30:45
    // yyyy年MM月dd日 HH:mm -> 2023年10月05日 14:30
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    // 格式化并返回字符串
    return formatter.format(now);
  }

  // 自定义格式获取当前时间字符串
  static String getCurrentDateTimeWithFormat(String format) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat(format);
    return formatter.format(now);
  }
}

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final List<PopupMenuEntry<String>> _menuItems = [
    const PopupMenuItem(
      value: 'history',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.history),
          SizedBox(width: 4),
          Text('分數變動記錄', style: TextStyle(fontFamily: "微软雅黑")),
        ],
      ),
    ),

    const PopupMenuItem(
      value: 'clear',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.clear_all, color: Colors.red),
          SizedBox(width: 4),
          Text(
            '清空分數',
            style: TextStyle(fontFamily: "微软雅黑", color: Colors.red),
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print(scoreMap["GS"]);
    int cardCount = scoreMap["GS"];
    int memberCount = scoreMap["MS"];
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('小組積分', style: TextStyle(fontFamily: "微软雅黑")),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
            ),
            itemBuilder: (BuildContext context) => _menuItems,
            onSelected: (String value) {
              switch (value) {
                case 'history':
                  showAnimatedDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      TextEditingController _myController =
                          TextEditingController();
                      String logText = File(
                        r"C:\Users\Public\note_files\history.txt",
                      ).readAsStringSync();
                      ScrollController _myScroolController = ScrollController(initialScrollOffset: logText.length.toDouble());
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.history),
                            SizedBox(width: 4),
                            Text(
                              "分數變動記錄",
                              style: TextStyle(fontFamily: "微软雅黑"),
                            ),
                          ],
                        ),
                        content: Card(
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          child: SingleChildScrollView(
                            controller: _myScroolController,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              logText,
                              style: TextStyle(
                                fontFamily: "微软雅黑",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          Card(
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
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
                                  "關閉",
                                  style: TextStyle(fontFamily: "微软雅黑"),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Card(
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  TextField(
                                    controller: _myController,
                                    maxLines: 1,
                                    minLines: 1,

                                    decoration: InputDecoration(
                                      label: Text("鍵入Confirm進行確認"),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),

                                  Divider(),

                                  Text(
                                    "清空記錄",
                                    style: TextStyle(fontFamily: "微软雅黑"),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (_myController.text == "Confirm") {
                                  File(
                                    r"C:\Users\Public\note_files\history.txt",
                                  ).writeAsStringSync("");
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    animationType: DialogTransitionType.slideFromTopFade,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: Duration(milliseconds: 500),
                  );
                  break;
                case 'clear':
                  showAnimatedDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      TextEditingController _myController =
                          TextEditingController();
                      return AlertDialog(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "清空分數？",
                              style: TextStyle(
                                fontFamily: "微软雅黑",
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            SizedBox(height: 8),
                            Icon(
                              Icons.clear_all,
                              color: Theme.of(context).colorScheme.error,
                              size: 128,
                            ),
                          ],
                        ),
                        actions: [
                          Card(
                            shadowColor: Colors.transparent,
                            color: Theme.of(context).colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: ListTile(
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
                                  "取消",
                                  style: TextStyle(
                                    fontFamily: "微软雅黑",
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),

                          Card(
                            shadowColor: Colors.transparent,
                            color: Theme.of(context).colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  TextField(
                                    controller: _myController,
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      label: Text(
                                        "鍵入Confirm進行確認",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onError,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  Text(
                                    "清空所有分數",
                                    style: TextStyle(
                                      fontFamily: "微软雅黑",
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onError,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (_myController.text == "Confirm") {
                                  for (var i = 0; i < cardCount; i++) {
                                    for (var j = 0; j < memberCount; j++) {
                                      scoreMap["G$i-M$j-score"] = "0";
                                    }
                                  }
                                  setState(() {});
                                  File(
                                    r"C:\Users\Public\note_files\score.json",
                                  ).writeAsStringSync(jsonEncode(scoreMap));
                                  String nowDate =
                                      DateTimeUtils.getCurrentDateTimeString();
                                  File(
                                    r"C:\Users\Public\note_files\history.txt",
                                  ).writeAsString(
                                    "[$nowDate] 清空了所有分數。\n",
                                    mode: FileMode.append,
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    animationType: DialogTransitionType.slideFromTopFade,
                    curve: Curves.fastEaseInToSlowEaseOut,
                    duration: Duration(milliseconds: 500),
                  );
                  break;
              }
            },
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: cardCount,
        itemBuilder: (BuildContext context, int index) {
          late ExpandedTileController _controller = ExpandedTileController();
          int totalScore = 0;
          int tempScore;
          for (int i = 0; i < scoreMap["MS"]; i++) {
            tempScore = int.parse(scoreMap["G$index-M$i-score"]);
            totalScore += tempScore;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: ExpandedTile(
                        trailing: SizedBox(),
                        theme: ExpandedTileThemeData(
                          headerBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          fullExpandedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            ),
                          ),
                          headerColor: Colors.transparent,
                          contentSeparatorColor: Colors.transparent,
                          contentBackgroundColor: Colors.transparent,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Card(
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(4),
                                    bottomLeft: Radius.circular(24),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                color: Theme.of(context).colorScheme.tertiary,
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  title: Icon(
                                    Icons.expand_circle_down,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiary,
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Card(
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(24),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(24),
                                  ),
                                ),
                                color: Theme.of(context).colorScheme.primary,
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  title: Text(
                                    "第${index + 1}小組",
                                    style: TextStyle(
                                      fontFamily: "微软雅黑",
                                      fontSize: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(flex: 2, child: SizedBox()),
                          ],
                        ),
                        content: SingleChildScrollView(
                          // 可选：如果成员多，添加滚动
                          child: Column(
                            children: List.generate(memberCount, (memberIndex) {
                              // 修复空值问题：使用 ?? 提供默认值
                              String memberName =
                                  scoreMap["G$index-M$memberIndex-name"] ??
                                  "Null";
                              String memberScore =
                                  scoreMap["G$index-M$memberIndex-score"] ??
                                  "-999";
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        memberName,
                                        style: const TextStyle(
                                          fontFamily: "微软雅黑",
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "分數：$memberScore",
                                        style: const TextStyle(
                                          fontFamily: "微软雅黑",
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(4),
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(4),
                                          ),
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(4),
                                              bottomLeft: Radius.circular(24),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          title: Text(
                                            "加分",
                                            style: TextStyle(
                                              fontFamily: "微软雅黑",
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                          tileColor: Colors.transparent,
                                          onTap: () {
                                            int _currentValue = 1;
                                            showAnimatedDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                int dialogValue = _currentValue;

                                                return StatefulBuilder(
                                                  builder: (context, setStateDialog) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "增加分數",
                                                        style: TextStyle(
                                                          fontFamily: "微软雅黑",
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize
                                                            .min, // 重要：避免对话框过大
                                                        children: [
                                                          NumberPicker(
                                                            value: dialogValue,
                                                            minValue: 0,
                                                            maxValue: 100,
                                                            step: 1,
                                                            itemHeight: 100,
                                                            axis:
                                                                Axis.horizontal,
                                                            onChanged: (value) {
                                                              // 使用对话框内部的setState更新值
                                                              setStateDialog(
                                                                () =>
                                                                    dialogValue =
                                                                        value,
                                                              );
                                                            },
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .black26,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        OutlinedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Text(
                                                            "取消",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "微软雅黑",
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                          ),
                                                        ),
                                                        //SizedBox(width: 2,),
                                                        OutlinedButton(
                                                          onPressed: () {
                                                            // 将对话框中的值同步到外部状态
                                                            setState(
                                                              () => _currentValue =
                                                                  dialogValue,
                                                            );

                                                            try {
                                                              setState(() {
                                                                int _tempScore =
                                                                    int.parse(
                                                                      scoreMap["G$index-M$memberIndex-score"],
                                                                    );
                                                                _tempScore +=
                                                                    dialogValue;
                                                                scoreMap["G$index-M$memberIndex-score"] =
                                                                    _tempScore
                                                                        .toString();
                                                              });
                                                              File(
                                                                r"C:\Users\Public\note_files\score.json",
                                                              ).writeAsString(
                                                                jsonEncode(
                                                                  scoreMap,
                                                                ),
                                                              );

                                                              String nowDate =
                                                                  DateTimeUtils.getCurrentDateTimeString();
                                                              File(
                                                                r"C:\Users\Public\note_files\history.txt",
                                                              ).writeAsString(
                                                                "[$nowDate] ${scoreMap["G$index-M$memberIndex-name"]} 增加$dialogValue分， 從Dialog操作。\n",
                                                                mode: FileMode
                                                                    .append,
                                                              );
                                                            } catch (e) {
                                                              print(e);
                                                            }

                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            "确认",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "微软雅黑",
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              animationType:
                                                  DialogTransitionType
                                                      .fadeScale,
                                              curve: Curves
                                                  .fastEaseInToSlowEaseOut,
                                              duration: Duration(
                                                milliseconds: 500,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(24),
                                            bottomLeft: Radius.circular(4),
                                            bottomRight: Radius.circular(24),
                                          ),
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(24),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(24),
                                            ),
                                          ),
                                          title: Text(
                                            "扣分",
                                            style: TextStyle(
                                              fontFamily: "微软雅黑",
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                            ),
                                          ),
                                          tileColor: Colors.transparent,
                                          onTap: () {
                                            int _currentValue = 1;
                                            showAnimatedDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                int dialogValue = _currentValue;

                                                return StatefulBuilder(
                                                  builder: (context, setStateDialog) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "增加分數",
                                                        style: TextStyle(
                                                          fontFamily: "微软雅黑",
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize
                                                            .min, // 重要：避免对话框过大
                                                        children: [
                                                          NumberPicker(
                                                            value: dialogValue,
                                                            minValue: 0,
                                                            maxValue: 100,
                                                            step: 1,
                                                            itemHeight: 100,
                                                            axis:
                                                                Axis.horizontal,
                                                            onChanged: (value) {
                                                              // 使用对话框内部的setState更新值
                                                              setStateDialog(
                                                                () =>
                                                                    dialogValue =
                                                                        value,
                                                              );
                                                            },
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .black26,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        OutlinedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: Text(
                                                            "取消",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "微软雅黑",
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                          ),
                                                        ),
                                                        //SizedBox(width: 2,),
                                                        OutlinedButton(
                                                          onPressed: () {
                                                            // 将对话框中的值同步到外部状态
                                                            setState(
                                                              () => _currentValue =
                                                                  dialogValue,
                                                            );

                                                            try {
                                                              setState(() {
                                                                int _tempScore =
                                                                    int.parse(
                                                                      scoreMap["G$index-M$memberIndex-score"],
                                                                    );
                                                                _tempScore -=
                                                                    dialogValue;
                                                                scoreMap["G$index-M$memberIndex-score"] =
                                                                    _tempScore
                                                                        .toString();
                                                              });
                                                              File(
                                                                r"C:\Users\Public\note_files\score.json",
                                                              ).writeAsString(
                                                                jsonEncode(
                                                                  scoreMap,
                                                                ),
                                                              );

                                                              String nowDate =
                                                                  DateTimeUtils.getCurrentDateTimeString();
                                                              File(
                                                                r"C:\Users\Public\note_files\history.txt",
                                                              ).writeAsString(
                                                                "[$nowDate] ${scoreMap["G$index-M$memberIndex-name"]} 扣除$dialogValue分， 從Dialog操作。\n",
                                                                mode: FileMode
                                                                    .append,
                                                              );
                                                            } catch (e) {
                                                              print(e);
                                                            }

                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            "确认",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "微软雅黑",
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              animationType:
                                                  DialogTransitionType
                                                      .fadeScale,
                                              curve: Curves
                                                  .fastEaseInToSlowEaseOut,
                                              duration: Duration(
                                                milliseconds: 500,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MaterialShapes.fourLeafClover(
                      size: 100,
                      color: index % 2 == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primaryContainer,
                      isStroked: false,
                    ),

                    Text(
                      "$totalScore",
                      style: TextStyle(
                        fontFamily: "微软雅黑",
                        fontSize: 48,
                        color: index % 2 == 0
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
