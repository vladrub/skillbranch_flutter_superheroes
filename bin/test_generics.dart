void main() {
  final Prestoheads prestoheads = Prestoheads.init([
    Member(
      firstName: "Станислав",
      lastName: "Сметанин",
      post: SEO(),
    ),
    Member(
      firstName: "Артем",
      lastName: "Максименко",
      post: Developer(),
    ),
  ])
    ..addMember(Member(
      firstName: "Анна",
      lastName: "Томашевская",
      post: Developer(),
    ));

  // print(prestoheads.members);

  final Member member1 = prestoheads.getMemberByName("Анна Томашевская");
  final Member member2 = prestoheads.getMemberByName("Анна Томашевская");
  final Member member3 = prestoheads.getMemberByName("Артем Максименко");

  print(member1 == member3);
}

class Prestoheads {
  static Prestoheads? _instance;
  List<Member> members = [];

  factory Prestoheads.init(List<Member> members) {
    return _instance ??= Prestoheads._(members);
  }

  Iterable<Member> addMember(Member member) {
    members.add(member);
    return members;
  }

  Member getMemberByName(String name) {
    return members.firstWhere((member) => member.name == name);
  }

  void removeMemberByName(String name) {
    members.removeWhere((member) => member.name == name);
  }

  Prestoheads._(this.members);
}

class Member<T extends Post> {
  final String name;
  final T post;

  Member({
    required String firstName,
    required String lastName,
    required this.post,
  }) : name = "${firstName} ${lastName}";

  @override
  String toString() => 'Member(name: $name, post: $post)';
}

abstract class Post {
  String name;

  Post(this.name);

  @override
  String toString() => 'Post(name: $name)';
}

class SEO extends Post {
  SEO() : super("Seo");
}

class Developer extends Post {
  Developer() : super("Developer");
}
