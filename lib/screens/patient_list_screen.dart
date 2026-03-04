import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'patient_detail_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<dynamic>> patients;
  Map<String, dynamic>? doctor;

  @override
  void initState() {
    super.initState();
    patients = ApiService.getTodayBookedTransactions();
    loadDoctor();
  }

  void loadDoctor() async {
    try {
      final data = await ApiService.getDoctorProfile();
      setState(() {
        doctor = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayFormatted = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7E57C2),
        title: const Text(
          "Cari Pasien",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (doctor != null)
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              icon: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child:
                        doctor!['photo_url'] != null
                            ? ClipOval(
                              child: Image.network(
                                doctor!['photo_url'],
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      doctor!['name'][0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            : Text(
                              doctor!['name'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor!['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor!['specialization'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: "profile",
                      child: Text(
                        "Edit Profil",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: "logout",
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
              onSelected: (value) async {
                if (value == "profile") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(doctor: doctor!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      loadDoctor();
                    }
                  });
                }

                if (value == "logout") {
                  await ApiService.clearToken();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: patients,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "STATUS: MENUNGGU",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Tanggal: $todayFormatted",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child:
                      data.isEmpty
                          ? const Center(
                            child: Text(
                              "Tidak ada pasien hari ini",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];

                              final petName = item['pet']?['name'] ?? '-';
                              final ownerName =
                                  item['pet']?['owner']?['name'] ??
                                  'Pemilik tidak ada';
                              final complaint = item['complaint'] ?? '-';

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PatientDetailScreen(
                                              transaction: item,
                                            ),
                                      ),
                                    );
                                    setState(() {
                                      patients =
                                          ApiService.getTodayBookedTransactions();
                                    });
                                  },
                                  leading: const Icon(
                                    Icons.pets,
                                    color: Color(0xFF7E57C2),
                                    size: 28,
                                  ),
                                  title: Text(
                                    petName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pemilik: $ownerName",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Keluhan: $complaint",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
