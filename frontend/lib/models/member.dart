class Member {
  final String id;
  final String name;
  final String? photoUrl;
  bool isPresent; // Properti ini untuk status UI, tidak akan disimpan permanen

  Member({
    required this.id,
    required this.name,
    this.photoUrl,
    this.isPresent = false,
  });

  /// Factory constructor untuk membuat instance Member dari Map/JSON.
  /// Ini akan kita gunakan saat mengambil data dari SharedPreferences.
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      // isPresent tidak diikutsertakan karena ini adalah state sementara untuk UI,
      // bukan data permanen dari seorang anggota. Defaultnya akan selalu false.
    );
  }

  /// Method untuk mengubah instance Member menjadi Map/JSON.
  /// Ini akan kita gunakan saat menyimpan data ke SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      // isPresent tidak perlu disimpan.
    };
  }
}
