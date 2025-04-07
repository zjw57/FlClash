import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:flutter/material.dart';

class MessageManager extends StatefulWidget {
  final Widget child;

  const MessageManager({
    super.key,
    required this.child,
  });

  @override
  State<MessageManager> createState() => MessageManagerState();
}

class MessageManagerState extends State<MessageManager>
    with SingleTickerProviderStateMixin {
  final _messagesNotifier = ValueNotifier<List<CommonMessage>>([]);
  double maxWidth = 0;
  Offset offset = Offset.zero;

  late AnimationController _animationController;

  final animationDuration = commonDuration * 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _messagesNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  message(String text) async {
    final commonMessage = CommonMessage(
      id: other.uuidV4,
      text: text,
    );
    _messagesNotifier.value = List.from(_messagesNotifier.value)
      ..add(
        commonMessage,
      );
    Future.delayed(commonMessage.duration, () {
      _handleRemove(commonMessage);
    });
  }

  _handleRemove(CommonMessage commonMessage) async {
    _messagesNotifier.value = List<CommonMessage>.from(_messagesNotifier.value)
      ..remove(commonMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ValueListenableBuilder(
          valueListenable: _messagesNotifier,
          builder: (_, messages, __) {
            return FadeBox(
              alignment: Alignment.topRight,
              child: messages.isEmpty
                  ? SizedBox()
                  : LayoutBuilder(
                      builder: (_, constraints) {
                        return Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          elevation: 10,
                          margin: EdgeInsets.only(
                            top: kToolbarHeight,
                            left: 12,
                            right: 12,
                          ),
                          color: context.colorScheme.surfaceContainerHigh,
                          child: Container(
                            width: min(
                              constraints.maxWidth,
                              400,
                            ),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              messages.last.text,
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ],
    );
  }
}

// class _MessageItemWrap extends StatefulWidget {
//   final Widget child;
//
//   const _MessageItemWrap({
//     super.key,
//     required this.child,
//   });
//
//   @override
//   State<_MessageItemWrap> createState() => _MessageItemWrapState();
// }
//
// class _MessageItemWrapState extends State<_MessageItemWrap>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: commonDuration * 1.5,
//     );
//   }
//
//   transform(Offset offset) async {
//     await _controller.forward(from: 0);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller.view,
//       builder: (_, child) {
//
//         return FadeBox(
//           offset: offset,
//           child: child!,
//         );
//       },
//       child: widget.child,
//     );
//   }
// }
