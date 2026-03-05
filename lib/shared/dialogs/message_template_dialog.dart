import 'package:flutter/material.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/helper/local_helper.dart';

class MessageTemplateDialog extends StatefulWidget {
  const MessageTemplateDialog({super.key});

  @override
  State<MessageTemplateDialog> createState() => _MessageTemplateDialogState();
}

class _MessageTemplateDialogState extends State<MessageTemplateDialog> {
  final messageTemplateController = TextEditingController();

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(messageTitle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width - 16 * 2,
        child: TextField(
          maxLines: 5,
          controller: messageTemplateController,
          decoration: InputDecoration(
            hintText: messageHint,
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Hủy'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, messageTemplateController.text);
                },
                child: Text('Lưu', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> initData() async {
    final result = await LocalHelper.getMessageTemplate();
    messageTemplateController.text = result;
  }
}
