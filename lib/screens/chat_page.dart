import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:intl/intl.dart';

import '../providers/theme_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final scrollController = ScrollController();
  final text = TextEditingController();
  final streamMsg = FirebaseFirestore.instance
      .collection('rom')
      .orderBy('data', descending: true)
      .snapshots();
  final emojiShowing = ValueNotifier<bool>(false);

  Future<void> enviar() async {
    if (text.text.isEmpty) {
      return;
    }
    final data = {'msg': text.text, 'data': FieldValue.serverTimestamp()};
    try {
      await FirebaseFirestore.instance.collection('rom').add(data);
      emojiShowing.value = false;
    } catch (e) {
      debugPrint('$e');
    }
    text.clear();
  }

  @override
  void dispose() {
    text.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final provider = ThemeProvider.instance;
    return Scaffold(
      backgroundColor: theme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Chat Dom Eliseu'),
        actions: [
          IconButton(
            onPressed: () {
              ColorPicker(
                enableShadesSelection: false,
                color: provider.color,
                onColorChanged: (Color color) async {
                  provider.color = color;
                },
                heading: Text(
                  'Selecione a cor',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                actionButtons: const ColorPickerActionButtons(
                  closeButton: true,
                  dialogActionButtons: false,
                ),
              ).showPickerDialog(
                context,
                constraints: const BoxConstraints(
                  minHeight: 260,
                  maxWidth: 400,
                  minWidth: 400,
                ),
              );
            },
            icon: const Icon(Icons.color_lens_rounded),
          ),
          IconButton(
            isSelected: ThemeProvider.instance.isDark,
            onPressed: () {
              setState(() {
                ThemeProvider.instance.isDark = !ThemeProvider.instance.isDark;
              });
            },
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.brightness_2_outlined),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: streamMsg,
                  builder: (context, snapshot) {
                    return snapshot.when(
                      data: (data) {
                        final items = data?.docs.map((e) => e.data()).toList();
                        return ListView.builder(
                          reverse: true,
                          itemCount: items?.length ?? 0,
                          itemBuilder: (context, index) {
                            final msg = items![index];
                            final date = msg['data'] as Timestamp?;
                            final dateFormat = date == null
                                ? ''
                                : DateFormat.EEEE('pt_BR')
                                    .add_Hm()
                                    .format(date.toDate());
                            return ChatBubble(
                              elevation: 2,
                              shadowColor: Colors.black38,
                              clipper: ChatBubbleClipper1(
                                type: index.isEven
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble,
                              ),
                              alignment: index.isEven
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              margin: const EdgeInsets.only(top: 8),
                              padding: index.isEven
                                  ? const EdgeInsets.only(right: 8)
                                  : const EdgeInsets.only(left: 12),
                              backGroundColor: index.isEven
                                  ? theme.surface
                                  : theme.primaryContainer,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.7,
                                ),
                                child: ListTile(
                                  title: Text(msg['msg']),
                                  subtitle: Text(
                                    dateFormat,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) {
                        return Center(child: Text('$error'));
                      },
                    );
                  },
                ),
              ),
              Ink(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        setState(
                            () => emojiShowing.value = !emojiShowing.value);
                      },
                      icon: const Icon(Icons.emoji_emotions),
                      color: theme.onPrimary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        clipBehavior: Clip.antiAlias,
                        controller: text,
                        scrollController: scrollController,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(left: 24),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4),
                            child: IconButton.filled(
                              onPressed: enviar,
                              icon: const Icon(Icons.send_rounded),
                              color: theme.onPrimary,
                            ),
                          ),
                        ),
                        onSubmitted: (value) => enviar(),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: emojiShowing,
                  builder: (context, value, child) {
                    return Offstage(
                      offstage: !value,
                      child: EmojiPicker(
                        scrollController: scrollController,
                        textEditingController: text,
                        config: Config(
                          emojiViewConfig: EmojiViewConfig(
                            // Issue: https://github.com/flutter/flutter/issues/28894
                            emojiSizeMax: 28 *
                                (foundation.defaultTargetPlatform ==
                                        TargetPlatform.iOS
                                    ? 1.2
                                    : 1.0),
                          ),
                          categoryViewConfig: CategoryViewConfig(
                            backgroundColor: theme.primary,
                            indicatorColor: theme.inversePrimary,
                            iconColorSelected: theme.inversePrimary,
                            iconColor: theme.surfaceDim,
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(
                            backgroundColor: theme.primary,
                            buttonColor: Colors.transparent,
                            buttonIconColor: theme.onPrimary,
                          ),
                          searchViewConfig: const SearchViewConfig(),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

extension AsyncSnapshotWhen<T> on AsyncSnapshot<T> {
  Widget when({
    required Widget Function(T? data) data,
    required Widget Function(Object? error, StackTrace? stackTrace) error,
    Widget loading = const Center(child: CircularProgressIndicator.adaptive()),
  }) =>
      switch (this) {
        AsyncSnapshot(hasData: true) => data(this.data),
        AsyncSnapshot(hasError: true) => error(this.error, stackTrace),
        _ => loading,
      };
}
