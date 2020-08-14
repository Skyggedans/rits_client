import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rits_client/models/qna/qna.dart';

enum QnaResponseStatus { waiting_for_input, done, error, not_set }

class QnaStatus extends Equatable {
  final QnaResponseStatus status;
  final List<QnaStatusItem> items;

  QnaStatus({@required this.status, this.items})
      : assert(status != null),
        assert(items != null),
        super([status, items]);

  factory QnaStatus.fromJson(Map<String, dynamic> json) {
    QnaResponseStatus status;

    switch (json['QnAResponse'] as String) {
      case 'WaitingForInput':
        status = QnaResponseStatus.waiting_for_input;

        break;
      case 'Done':
        status = QnaResponseStatus.done;

        break;
      case 'Error':
        status = QnaResponseStatus.error;

        break;
      case 'NotSet':
      default:
        {
          status = QnaResponseStatus.not_set;
        }
    }

    return QnaStatus(
        status: status,
        items: List<Map<String, dynamic>>.from(json['Status'] as List)
            .map((itemJson) {
          return QnaStatusItem.fromJson(itemJson);
        }).toList());
  }
}
