import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class DoctorRatingScreen extends StatefulWidget {
  final Map doctor;

  const DoctorRatingScreen({super.key, required this.doctor});

  @override
  State<DoctorRatingScreen> createState() => _DoctorRatingScreenState();
}

class _DoctorRatingScreenState extends State<DoctorRatingScreen> {
  Map<String, dynamic>? ratingData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRating();
  }

  Future<void> fetchRating() async {
    try {
      final data = await ApiService.getDoctorRatingSummary(widget.doctor['id']);

      setState(() {
        ratingData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Rating Saya",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : buildContent(),
    );
  }

  Widget buildContent() {
    final totalRatings = ratingData?['total_ratings'] ?? 0;

    // =============================
    // BELUM ADA RATING
    // =============================
    if (totalRatings == 0) {
      return const Center(
        child: Text(
          "Belum Ada Rating",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    // =============================
    // ADA RATING
    // =============================
    final doctorName = ratingData?['doctor_name'] ?? '-';
    final wrbs = ratingData?['wrbs_index'] ?? 0;
    final category = ratingData?['service_category'] ?? '-';
    final nps = ratingData?['nps'] ?? 0;

    final avg = ratingData?['average_ratings'];
    final avgFriendly = avg?['friendly'] ?? 0;
    final avgPunctual = avg?['punctual'] ?? 0;
    final avgClarity = avg?['clarity'] ?? 0;

    // ⭐ hitung bintang dari rata-rata 3 dimensi
    final starValue = ((avgFriendly + avgPunctual + avgClarity) / 3).toDouble();

    final comments = ratingData?['comments'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================
          // NAMA DOKTER
          // =============================
          Text(
            doctorName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // =============================
          // BINTANG
          // =============================
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                starValue.toStringAsFixed(1),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =============================
          // SKOR PELAYANAN (WRBS)
          // =============================
          Text("Skor Pelayanan: ${wrbs.toString()}"),

          const SizedBox(height: 8),

          // =============================
          // KATEGORI
          // =============================
          Text("Kategori: $category"),

          const SizedBox(height: 8),

          // =============================
          // NPS
          // =============================
          Text("Rekomendasi Pasien (NPS): $nps"),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 8),

          const Text(
            "Komentar Pasien",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // =============================
          // LIST KOMENTAR
          // =============================
          ...comments.map<Widget>((comment) {
            final text = comment['comment'] ?? '';
            final rawDate = comment['rated_at'];
            String formattedDate = '';

            if (rawDate != null && rawDate.toString().isNotEmpty) {
              final parsedDate = DateTime.tryParse(rawDate.toString());
              if (parsedDate != null) {
                formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
              }
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(text)),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
