class ChatModel
{
  String ? UIdSender;
  String ? UIdReciver;
  String ? message;
  String ? dateTime;
  String ? image;
  String ? audio;
  String ? id;
  bool ? read;

  ChatModel({required this.UIdSender, required this.UIdReciver,required this.message,
    required this.dateTime ,required this.image, required this.audio ,required this.id,required this.read});

  ChatModel.fromjson(Map<String,dynamic>?json)
  {
    UIdSender=json!['UIdSender'];
    UIdReciver=json['UIdReciver'];
    message=json['message'];
    dateTime=json['dateTime'];
    image=json['image'];
    audio=json['audio'];
    id=json['id'];
    read=json['read'];
  }

  Map<String,dynamic> toMap()
  {
    return{
      'UIdSender':UIdSender,
      'UIdReciver':UIdReciver,
      'message':message,
      'dateTime':dateTime,
      'image':image,
      'audio':audio,
      'id':id,
      'read':read,

    };
  }
}