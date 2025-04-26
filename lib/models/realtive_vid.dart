class RealtiveVid {
  final String session;
  final String? title;
  RealtiveVid({
    required this.session,
    this.title,
  });
  @override
  String toString() {
    return "RealVid(session: $session, title: $title)";
  }
}