import 'package:clearsale/src/domain/models/order_model.dart';

class OrderModelMapper {
  static Map<String, dynamic> toMap(OrderModel model) => {
        if (model.orderCode != null) 'code': model.orderCode,
        if (model.status != null) 'status': model.status,
        if (model.score != null) 'score': model.score,
      };

  static OrderModel fromMap(Map<String, dynamic> map) {
    double? score;
    if (map['score'] != null) {
      score = double.parse(map['score'].toString());
    }
    return OrderModel(orderCode: map['code'], status: map['status'], score: score);
  }
}
