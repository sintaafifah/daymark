
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final Color backgroundColor = const Color(0xFFF8F8FE);
  final Color primaryColor = const Color(0xFF3979E8);

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Review materi UTS',
      'time': '09.00',
      'category': 'Akademik',
      'priority': 'Tinggi',
      'color': const Color(0xFFFFE3D2),
      'accent': const Color(0xFFEAA77F),
      'done': false,
    },
    {
      'title': 'Desain poster acara',
      'time': '13.00',
      'category': 'Organisasi',
      'priority': 'Sedang',
      'color': const Color(0xFFEDE7FF),
      'accent': const Color(0xFF9C85ED),
      'done': false,
    },
    {
      'title': 'Kirim revisi proposal',
      'time': '16.30',
      'category': 'Project',
      'priority': 'Tinggi',
      'color': const Color(0xFFDDF4EC),
      'accent': const Color(0xFF65B99B),
      'done': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20, 12, 20, 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RABU, 21 OKTOBER',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9699A9),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Hai, Sinta!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF293347),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ini yang perlu kamu selesaikan.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFFFE4D5),
                          child: const Text(
                            'DS',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFFC58A68),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Weekly Progress
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PROGRES MINGGU INI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '75%',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '6 dari 8 tugas selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              value: 0.75,
                              minHeight: 7,
                              backgroundColor: Color(0xFF91B8F5),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Focus Today
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fokus hari ini',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF293347),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lihat semua ›',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF3979E8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Task List
                    ...tasks.map((task) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E3ED),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: task['color'],
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Checkbox(
                                value: task['done'],
                                onChanged: (value) {
                                  setState(() {
                                    task['done'] = value!;
                                  });
                                },
                                activeColor: task['accent'],
                                side: BorderSide.none,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity:
                                    VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF293347),
                                      decoration: task['done']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${task['time']} · ${task['category']}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF999EAD),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task['color'],
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      task['priority'],
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: task['accent'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              height: 41,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE2E3ED),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home_outlined, 'Beranda', 0),
                  _navItem(Icons.assignment_outlined, 'Tugas', 1),

                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  _navItem(Icons.calendar_month_outlined, 'Kalender', 2),
                  _navItem(Icons.person_outline, 'Profil', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 17,
            color: selected
                ? primaryColor
                : const Color(0xFF9299AA),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              color: selected
                  ? primaryColor
                  : const Color(0xFF9299AA),
            ),
          ),
        ],
      ),
    );
  }
}
