import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});
  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, String>> cardData = [];

  void _addCard(String cardTitle, String cardContent, String cardState) {
    setState(() {
      cardData.add({
        'title': cardTitle,
        'content': cardContent,
        'state': cardState,
      });
    });
  }

  final List<PopupMenuEntry<String>> _menuItems = [
    const PopupMenuItem(
      value: 'clear',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 4),
          Text(
            '清空筆記',
            style: TextStyle(color: Colors.red, fontFamily: "微软雅黑"),
          ),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'about',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info),
          SizedBox(width: 4),
          Text('关于Re: Note', style: TextStyle(fontFamily: "微软雅黑")),
        ],
      ),
    ),
  ];

  final List<PopupMenuEntry<String>> _CardMenuItems = [
    const PopupMenuItem(
      value: 'edit',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.edit),
          SizedBox(width: 4),
          Text('修改筆記', style: TextStyle(fontFamily: "微软雅黑")),
        ],
      ),
    ),

    const PopupMenuItem(
      value: 'copy',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.copy),
          SizedBox(width: 4),
          Text('複製筆記', style: TextStyle(fontFamily: "微软雅黑")),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.close, color: Colors.red),
          SizedBox(width: 4),
          Text(
            '刪除筆記',
            style: TextStyle(fontFamily: "微软雅黑", color: Colors.red),
          ),
        ],
      ),
    ),
  ];

  void _clearAllNotes() async {
    File _noteFile = File('C:/Users/Public/note_files/notelist.json');
    _noteFile.writeAsString(jsonEncode({"itemCount": 0}), mode: FileMode.write);
    setState(() {
      cardData.clear();
    });
  }

  void _handleMenuItemSelected(String value) {
    switch (value) {
      case 'clear':
        showAnimatedDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.warning, size: 36),
                  SizedBox(width: 4),
                  Text('清空筆記？', style: TextStyle(fontFamily: "微软雅黑")),
                ],
              ),
              content: Text('該操作不可回退！', style: TextStyle(fontFamily: "微软雅黑")),
              actions: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消', style: TextStyle(fontFamily: "微软雅黑")),
                ),

                FilledButton(
                  onPressed: () {
                    _clearAllNotes();
                    Navigator.of(context).pop();
                  },
                  child: Text('確定', style: TextStyle(fontFamily: "微软雅黑")),
                ),
              ],
            );
          },
          animationType: DialogTransitionType.fadeScale,
          curve: Curves.fastEaseInToSlowEaseOut,
          duration: Duration(milliseconds: 500),
        );
        break;
      case 'about':
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
          applicationLegalese: '@2025 Dinix_NeverOSC, all rights reserved.',
        );
        break;
    }
  }

  Future<void> _loadNotes() async {
    try {
      File _noteFile = File('C:/Users/Public/note_files/notelist.json');
      if (!await _noteFile.exists()) {
        await _noteFile.parent.create(recursive: true); // 创建父目录
        await _noteFile.writeAsString(jsonEncode({'itemCount': 0})); // 初始化空数据
      }
      String _noteString = await _noteFile.readAsString();

      Map<String, dynamic> _noteMap = jsonDecode(_noteString);
      setState(() {
        cardData.clear(); // 清空现有数据
        int itemCount = _noteMap['itemCount'] ?? 0;
        // 批量添加数据
        for (int i = 1; i <= itemCount; i++) {
          cardData.add({
            'title': _noteMap['title$i'] ?? '',
            'content': _noteMap['content$i'] ?? '',
            'state': _noteMap['state$i'] ?? 'normal',
          });
        }
      });
    } catch (e) {
      //File _noteFile = File('C:/Users/Public/note_files/notelist.json');
      //_noteFile.create();

      //Map<String, dynamic> _settleNoteMap = {
      //"itemCount":0
      //};

      //String _settleNoteString = jsonEncode(_settleNoteMap);
      //_noteFile.writeAsString(_settleNoteString);

      print(e);
    }
  }

  void _removeNotes() {
    setState(() {
      cardData.clear();
    });
  }

  Future<void> _deleteCardIndex(int index) async {
    try {
      File noteFile = File(r'C:\Users\Public\note_files\notelist.json');
      String str = await noteFile.readAsString();
      Map<String, dynamic> existingData = jsonDecode(str);

      int num = index + 1;
      existingData.remove('title$num');
      existingData.remove('content$num');
      existingData.remove('state$num');

      Map<String, dynamic> newData = {};
      newData['itemCount'] = existingData['itemCount'] - 1;
      int newIndex = 1;
      for (int i = 1; i <= cardData.length; i++) {
        if (i != num) {
          newData['title$newIndex'] = existingData['title$i'];
          newData['content$newIndex'] = existingData['content$i'];
          newData['state$newIndex'] = existingData['state$i'];
          newIndex++;
        }
      }

      await noteFile.writeAsString(jsonEncode(newData), mode: FileMode.write);
      _loadNotes();
    } catch (e) {
      print('Error loading cards: $e');
    }
    cardData.removeAt(index);
  }

  static const WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      });

  static const WidgetStateProperty<Icon> thumbIconTH =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.video_collection),
        WidgetState.any: Icon(Icons.video_collection_outlined),
      });

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('筆記', style: TextStyle(fontFamily: "微软雅黑")),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
            ),
            onSelected: _handleMenuItemSelected,
            itemBuilder: (BuildContext context) => _menuItems,
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: cardData.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: index == 0
                        ? Radius.circular(24)
                        : Radius.circular(8),
                    topRight: index == 0
                        ? Radius.circular(24)
                        : Radius.circular(8),
                    bottomLeft: index == cardData.length - 1
                        ? Radius.circular(24)
                        : Radius.circular(8),
                    bottomRight: index == cardData.length - 1
                        ? Radius.circular(24)
                        : Radius.circular(8),
                  ),
                  side: cardData[index]['state'] == "highlight"
                      ? BorderSide(
                          width: 4,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : BorderSide.none
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: ListTile(
                    title: Text(
                      cardData[index]['title']!,
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: cardData[index]["state"] == "image"
                        ? Image.file(File(cardData[index]["content"]!))
                        : MarkdownBlock(
                            data: cardData[index]['content']!,
                            config: MarkdownConfig(
                              configs: [
                                PConfig(
                                  textStyle: TextStyle(
                                    fontFamily: "微软雅黑",
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

              /*ExpandableMenu(
                width: 48,
                height: 48,
                backgroundColor: Theme.of(context).primaryColor,
                items: [
                  IconButton(
                    onPressed: () {
                      showAnimatedDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.warning, size: 36),
                                SizedBox(width: 4),
                                Text(
                                  '刪除這份筆記？',
                                  style: TextStyle(fontFamily: "微软雅黑"),
                                ),
                              ],
                            ),
                            content: Text("該操作不可回退！"),
                            actions: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  _deleteCardIndex(index);
                                  /*setState(() {
                                    cardData.clear();
                                  });*/
                                  //_loadNotes();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  '確定',
                                  style: TextStyle(fontFamily: "微软雅黑"),
                                ),
                              ),
                            ],
                          );
                        },
                        animationType: DialogTransitionType.fadeScale,
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: Duration(milliseconds: 500),
                      );
                    },
                    icon: Icon(Icons.close, size: 20, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: cardData[index]['content']!),
                      );

                      showAnimatedDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.check, size: 36),
                                SizedBox(width: 4),
                                Text(
                                  '複製成功！',
                                  style: TextStyle(fontFamily: "微软雅黑"),
                                ),
                              ],
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  '確定',
                                  style: TextStyle(fontFamily: "微软雅黑"),
                                ),
                              ),
                            ],
                          );
                        },
                        animationType: DialogTransitionType.fadeScale,
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: Duration(milliseconds: 500),
                      );
                    },
                    icon: Icon(Icons.copy, size: 20, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      TextEditingController _thisNoteTitleController =
                          TextEditingController(
                            text: cardData[index]['title']!,
                          );
                      TextEditingController _thisNoteContentController =
                          TextEditingController(
                            text: cardData[index]['content']!,
                          );
                      bool _thisNoteHighlighted =
                          cardData[index]['state'] == 'normal' ? false : true;

                      showAnimatedDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    title: Text(
                                      '修改筆記',
                                      style: TextStyle(fontFamily: "微软雅黑"),
                                    ),

                                    actions: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,

                                        children: [
                                          TextField(
                                            controller:
                                                _thisNoteTitleController,
                                            maxLines: 1,
                                            minLines: 1,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('標題'),
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          TextField(
                                            controller:
                                                _thisNoteContentController,
                                            maxLines: 8,
                                            minLines: 1,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('内容'),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text('    選項'),
                                          SwitchListTile(
                                            title: Text('高亮便簽？',style: TextStyle(fontFamily: "微软雅黑",fontSize: 20),),
                                            subtitle: Text('變更高亮狀態',style: TextStyle(fontFamily: "微软雅黑"),),
                                            value: _thisNoteHighlighted,
                                            thumbIcon: thumbIcon,
                                            onChanged: (value) {
                                              setState(() {
                                                _thisNoteHighlighted = value;
                                              });
                                            },
                                          ),
                                          SizedBox(height: 12,)
                                        ],
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('取消'),
                                      ),
                                    ],
                                  );
                                },
                          );
                        },
                        animationType: DialogTransitionType.fadeScale,
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: Duration(milliseconds: 500),
                      );
                    },
                    icon: Icon(Icons.edit, size: 20, color: Colors.black),
                  ),
                ],
              ),*/
              Positioned(
                top: 8,
                right: 8,
                child: Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shadowColor: Colors.transparent,
                  shape: CircleBorder(),
                  child: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0)),
                    ),

                    //shadowColor: Colors.transparent,
                    //color: Colors.transparent,
                    onSelected: (String value) {
                      switch (value) {
                        case 'edit':
                          TextEditingController _thisNoteTitleController =
                              TextEditingController(
                                text: cardData[index]['title']!,
                              );
                          TextEditingController _thisNoteContentController =
                              TextEditingController(
                                text: cardData[index]['content']!,
                              );
                          bool _thisNoteHighlighted =
                              cardData[index]['state'] == 'normal'
                              ? false
                              : true;

                          showAnimatedDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    title: Text(
                                      '修改筆記',
                                      style: TextStyle(fontFamily: "微软雅黑"),
                                    ),

                                    actions: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,

                                        children: [
                                          TextField(
                                            controller:
                                                _thisNoteTitleController,
                                            maxLines: 1,
                                            minLines: 1,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('標題'),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          TextField(
                                            controller:
                                                _thisNoteContentController,
                                            maxLines: 8,
                                            minLines: 1,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              label: Text('内容'),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text('    選項'),
                                          SizedBox(height: 12),

                                          SwitchListTile(
                                            contentPadding: EdgeInsets.only(
                                              top: 8,
                                              right: 16,
                                              bottom: 8,
                                              left: 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(48),
                                            ),
                                            tileColor: Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                            title: Text(
                                              '高亮便簽',
                                              style: TextStyle(
                                                fontFamily: "微软雅黑",
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),

                                            value: _thisNoteHighlighted,
                                            thumbIcon: thumbIcon,
                                            onChanged: (value) {
                                              setState(() {
                                                _thisNoteHighlighted = value;
                                              });
                                            },
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('取消'),
                                          ),

                                          SizedBox(width: 6),

                                          FilledButton(
                                            onPressed: () async {
                                              File _originFile = File(
                                                r'C:\Users\Public\note_files\notelist.json',
                                              );
                                              String _originString =
                                                  await _originFile
                                                      .readAsString();
                                              Map<String, dynamic> _originMap =
                                                  jsonDecode(_originString);

                                              _originMap['title${index + 1}'] =
                                                  _thisNoteTitleController.text;
                                              _originMap['content${index + 1}'] =
                                                  _thisNoteContentController
                                                      .text;
                                              _originMap['state${index + 1}'] =
                                                  _thisNoteHighlighted
                                                  ? "highlight"
                                                  : "normal";

                                              _originFile.writeAsString(
                                                jsonEncode(_originMap),
                                                mode: FileMode.write,
                                              );
                                              _loadNotes();

                                              Navigator.of(context).pop();
                                            },
                                            child: Text('確定'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            animationType:
                                DialogTransitionType.slideFromTopFade,
                            curve: Curves.fastEaseInToSlowEaseOut,
                            duration: Duration(milliseconds: 500),
                          );
                          break;
                        case 'copy':
                          Clipboard.setData(
                            ClipboardData(text: cardData[index]['content']!),
                          );

                          showAnimatedDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                title: Center(child: Text("Copy succeed.")),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,

                                  children: [
                                    Icon(Icons.copy, size: 128),
                                    SizedBox(height: 16),
                                    ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                          bottomLeft: Radius.circular(24),
                                          bottomRight: Radius.circular(24),
                                        ),
                                      ),
                                      tileColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      title: Center(child: Text("Got it")),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            animationType:
                                DialogTransitionType.slideFromTopFade,
                            curve: Curves.fastEaseInToSlowEaseOut,
                            duration: Duration(milliseconds: 500),
                          );
                          break;
                        case 'delete':
                          if (cardData[index]['state'] == "thv") {
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  title: Text("This action is not allowed."),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,

                                    children: [
                                      Icon(Icons.block, size: 128),
                                      SizedBox(height: 16),
                                      ListTile(
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
                                        ).colorScheme.surfaceContainerHighest,
                                        title: Center(child: Text("Got it")),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      SizedBox(height: 4),

                                      ListTile(
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
                                        ).colorScheme.surfaceContainerHighest,
                                        title: Center(
                                          child: Text(
                                            "Why I encountered this?",
                                          ),
                                        ),
                                        onTap: () {
                                          //Navigator.of(context).pop();
                                        },
                                      ),

                                      SizedBox(height: 4),
                                      ListTile(
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
                                        ).colorScheme.surfaceContainerHighest,
                                        title: Center(
                                          child: Text("Send feedback"),
                                        ),
                                        onTap: () {
                                          //Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              animationType:
                                  DialogTransitionType.slideFromTopFade,
                              curve: Curves.fastEaseInToSlowEaseOut,
                              duration: Duration(milliseconds: 500),
                            );
                          } else {
                            showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.warning, size: 36),
                                      SizedBox(width: 4),
                                      Text(
                                        '刪除這份筆記？',
                                        style: TextStyle(fontFamily: "微软雅黑"),
                                      ),
                                    ],
                                  ),
                                  content: Text("該操作不可回退！"),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('取消'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        _deleteCardIndex(index);
                                        /*setState(() {
                                    cardData.clear();
                                  });*/
                                        //_loadNotes();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '確定',
                                        style: TextStyle(fontFamily: "微软雅黑"),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              animationType: DialogTransitionType.fadeScale,
                              curve: Curves.fastEaseInToSlowEaseOut,
                              duration: Duration(milliseconds: 500),
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => _CardMenuItems,
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Please select an image file."),
                        actions: [
                          Center(
                            child: LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(24),
                              minHeight: 48,
                            ),
                          ),
                          
                        ],
                      );
                    },
                  );
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.image);
                  if (result != null) {
                    File imgFile = File(result.files.single.path!);

                    try {
                      File _writeFile = File(
                        'C:/Users/Public/note_files/notelist.json',
                      );
                      String _writeString = await _writeFile.readAsString();
                      Map<String, dynamic> _originMap = jsonDecode(
                        _writeString,
                      );

                      _originMap['itemCount'] = _originMap['itemCount'] + 1;

                      _originMap['content${_originMap['itemCount']}'] =
                          imgFile.path;
                      _originMap['title${_originMap['itemCount']}'] = imgFile.path;
                      _originMap['state${_originMap['itemCount']}'] = "image";

                      await _writeFile.writeAsString(
                        jsonEncode(_originMap),
                        mode: FileMode.write,
                      );
                      _loadNotes();
                    } catch (e) {
                      print('Error: $e');
                    }
                    Navigator.of(context).pop();
                  } else {
                    // User canceled the picker
                    Navigator.of(context).pop();
                  }
                },
                child: Icon(Icons.image),
              ),

              SizedBox(width: 14),
            ],
          ),

          SizedBox(height: 8),

          FloatingActionButton.large(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              final TextEditingController _titleController =
                  TextEditingController();
              final TextEditingController _contentController =
                  TextEditingController();
              bool _isHighLight = false;
              bool _isTouhouVideo = false;
              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Padding(
                          padding: EdgeInsets.only(
                            top: 16,
                            right: 48,
                            left: 48,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '新增筆記',
                                style: TextStyle(
                                  fontFamily: "微软雅黑",
                                  fontSize: 36,
                                ),
                              ),
                              SizedBox(height: 24),
                              TextField(
                                controller: _titleController,
                                minLines: 1,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: "微软雅黑",
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,

                                  //fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 4),
                                      Text(
                                        '輸入標題',
                                        style: TextStyle(fontFamily: "微软雅黑"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Divider(),

                              Card(
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          TextEditingController
                                          _linkNameController =
                                              TextEditingController();
                                          TextEditingController
                                          _linkController =
                                              TextEditingController();
                                          showAnimatedDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.add_a_photo,
                                                      size: 36,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '插入網路圖片',
                                                      style: TextStyle(
                                                        fontFamily: "微软雅黑",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller:
                                                              _linkNameController,
                                                          maxLines: 1,
                                                          minLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                label: Text(
                                                                  '圖片描述',
                                                                ),
                                                              ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      Expanded(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller:
                                                              _linkController,
                                                          maxLines: 1,
                                                          minLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                label: Text(
                                                                  '網路圖片url',
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 12),

                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Text('取消'),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      FilledButton(
                                                        onPressed: () {
                                                          _contentController
                                                                  .text =
                                                              '!${_contentController.text}[${_linkNameController.text}](${_linkController.text})';
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Text('確定'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                            animationType:
                                                DialogTransitionType.fadeScale,
                                            curve:
                                                Curves.fastEaseInToSlowEaseOut,
                                            duration: Duration(
                                              milliseconds: 500,
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.photo),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          TextEditingController
                                          _linkNameController =
                                              TextEditingController();
                                          TextEditingController
                                          _linkController =
                                              TextEditingController();
                                          showAnimatedDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.add_link,
                                                      size: 36,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '插入鏈接',
                                                      style: TextStyle(
                                                        fontFamily: "微软雅黑",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller:
                                                              _linkNameController,
                                                          maxLines: 1,
                                                          minLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                label: Text(
                                                                  '鏈接文字',
                                                                ),
                                                              ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 6),

                                                      Expanded(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller:
                                                              _linkController,
                                                          maxLines: 1,
                                                          minLines: 1,
                                                          decoration:
                                                              InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                label: Text(
                                                                  '鏈接地址',
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 12),

                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Text('取消'),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      FilledButton(
                                                        onPressed: () {
                                                          _contentController
                                                                  .text =
                                                              '${_contentController.text}[${_linkNameController.text}](${_linkController.text})';
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                        },
                                                        child: Text('確定'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                            animationType:
                                                DialogTransitionType.fadeScale,
                                            curve:
                                                Curves.fastEaseInToSlowEaseOut,
                                            duration: Duration(
                                              milliseconds: 500,
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.link),
                                      ),
                                      //Text("Is Touhou Video?", style: TextStyle(fontSize: 16),),
                                      //VerticalDivider(),
                                      Switch(
                                        thumbIcon: thumbIconTH,
                                        value: _isTouhouVideo,
                                        onChanged: (value) {
                                          setState(() {
                                            _isTouhouVideo = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              TextField(
                                controller: _contentController,
                                minLines: 4,
                                maxLines: 4,
                                style: TextStyle(
                                  fontFamily: "微软雅黑",
                                  fontSize: 22,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                              //Divider(),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                shadowColor: Colors.transparent,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                child: Padding(
                                  padding: EdgeInsets.all(0),
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.only(
                                      left: 8,
                                      right: 16,
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    title: Text(
                                      '   高亮便簽',
                                      style: TextStyle(
                                        fontFamily: "微软雅黑",
                                        fontSize: 20,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    /*subtitle: Text(
                                      '     讓這份便簽變得更加顯眼✌',
                                      style: TextStyle(fontFamily: "微软雅黑"),
                                    ),*/
                                    thumbIcon: thumbIcon,
                                    value: _isHighLight,
                                    onChanged: (value) {
                                      setState(() {
                                        _isHighLight = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              //Divider(),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      _titleController.clear();
                                      _contentController.clear();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      '取消',
                                      style: TextStyle(
                                        fontFamily: "微软雅黑",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        File _writeFile = File(
                                          'C:/Users/Public/note_files/notelist.json',
                                        );
                                        String _writeString = await _writeFile
                                            .readAsString();
                                        Map<String, dynamic> _originMap =
                                            jsonDecode(_writeString);

                                        _originMap['itemCount'] =
                                            _originMap['itemCount'] + 1;

                                        _originMap['content${_originMap['itemCount']}'] =
                                            _contentController.text;
                                        _originMap['title${_originMap['itemCount']}'] =
                                            _titleController.text;
                                        _originMap['state${_originMap['itemCount']}'] =
                                            _isHighLight
                                            ? "highlight"
                                            : "normal";
                                        if (_isTouhouVideo) {
                                          _originMap['state${_originMap['itemCount']}'] =
                                              "thv";
                                        }

                                        await _writeFile.writeAsString(
                                          jsonEncode(_originMap),
                                          mode: FileMode.write,
                                        );
                                        //_removeNotes();
                                        _loadNotes();

                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        print('Error: $e');
                                      }
                                    },
                                    child: Text(
                                      '完成',
                                      style: TextStyle(
                                        fontFamily: "微软雅黑",
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),

          SizedBox(height: 12),
        ],
      ),
    );
  }
}
