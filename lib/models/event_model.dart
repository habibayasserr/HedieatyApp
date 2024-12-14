class Event {
  final String name;
  //final String category;
  //final String status;
  final DateTime date;
  final String location;
  final String description;

  Event(
      {required this.name,
      //required this.category,
      //required this.status,
      required this.date,
      required this.description,
      required this.location});
}
