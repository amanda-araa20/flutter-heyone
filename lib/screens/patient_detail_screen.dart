import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const PatientDetailScreen({required this.transaction});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final tindakanController = TextEditingController();
  final hargaController = TextEditingController();
  bool _isLoading = false;

  String calculateAge(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString);
    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      days += 30;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return "$years tahun, $months bulan, $days hari";
  }

  Widget buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildInputCard({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
    Widget? prefix,
    String? helperText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: isMultiline ? TextInputType.multiline : keyboardType,
            textInputAction:
                isMultiline ? TextInputAction.newline : TextInputAction.done,
            minLines: isMultiline ? 3 : 1,
            maxLines: isMultiline ? null : 1,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              prefixIcon: prefix,
              helperText: helperText,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(int transactionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text(
              "Apakah tindakan sudah benar dan ingin disimpan?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya, Simpan"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.updateTransaction(
        transactionId,
        tindakanController.text,
        hargaController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tindakan berhasil disimpan"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final pet = transaction['pet'];

    final petName = pet?['name'] ?? '-';
    final ownerName = pet?['owner']?['name'] ?? '-';
    final birthDate = pet?['birth_date'];
    final jenisHewan = pet?['jenis_hewan'] ?? '-';
    final kelamin = pet?['gender'] ?? '-';
    final complaint = transaction['complaint'] ?? '-';
    final clinicName = transaction['clinic']?['name'] ?? '-';
    final doctorName = transaction['doctor']?['name'] ?? '-';
    final usia = birthDate != null ? calculateAge(birthDate) : '-';
    final transactionId = transaction['id'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text(
          "Detail Pasien",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7E57C2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tempat: $clinicName",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Dokter: $doctorName",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildInfoCard("Nama Hewan", petName),
            buildInfoCard("Pemilik", ownerName),
            buildInfoCard("Usia", usia),
            buildInfoCard("Jenis Hewan", jenisHewan),
            buildInfoCard("Kelamin", kelamin),
            buildInfoCard("Keluhan", complaint),

            const SizedBox(height: 20),

            buildInputCard(
              label: "Tindakan",
              controller: tindakanController,
              isMultiline: true,
            ),
            buildInputCard(
              label: "Harga",
              controller: hargaController,
              keyboardType: TextInputType.number,
              prefix: const Padding(
                padding: EdgeInsets.only(top: 14, left: 8),
                child: Text(
                  "Rp ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              helperText: "Masukkan angka tanpa titik. Contoh: 200000",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed:
                    _isLoading ? null : () => _handleSubmit(transactionId),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
