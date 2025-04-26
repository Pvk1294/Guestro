import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(String) onSpeak;

  const MessageBubble({
    required this.message,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: message.isMe 
                ? Colors.blue[200] 
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2,'0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isMe 
                          ? Colors.black54 
                          : Colors.grey[700],
                    ),
                  ),
                  if (!message.isMe)
                    IconButton(
                      icon: Icon(Icons.volume_up, size: 16),
                      onPressed: () => onSpeak(message.text),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}