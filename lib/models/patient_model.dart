class Patient {
  final int id;
  final String namaHewan;
  final String kategori;
  final String usia;
  final String kelamin;
  final String keluhan;

  Patient({
    required this.id,
    required this.namaHewan,
    required this.kategori,
    required this.usia,
    required this.kelamin,
    required this.keluhan,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      namaHewan: json['nama_hewan'],
      kategori: json['kategori'],
      usia: json['usia'],
      kelamin: json['kelamin'],
      keluhan: json['keluhan'],
    );
  }
}
