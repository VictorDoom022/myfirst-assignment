class Note {
  String? id;
  String? title;
  String? content;
  String? createAt;

  Note({this.id, this.title, this.content, this.createAt});

  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    createAt = json['createAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['createAt'] = this.createAt;
    return data;
  }
}
