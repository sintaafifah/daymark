
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
static Stream<DocumentSnapshot<Map<String, dynamic>>> watchTask(
  String taskId,
) {
  return _tasksRef.doc(taskId).snapshots();
}
  // UID pengguna yang sedang login
  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.uid;
  }

  // Referensi koleksi tugas pengguna
  static CollectionReference<Map<String, dynamic>>
      get _tasksRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('tasks');
  }

  // Referensi koleksi notifikasi pengguna
static CollectionReference<Map<String, dynamic>>
    get _notificationsRef {
  return _firestore
      .collection('users')
      .doc(_uid)
      .collection('notifications');
}

  // Mengambil tugas secara real-time
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      getTasks() {
    return _tasksRef
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mengambil satu tugas berdasarkan ID
  static Future<DocumentSnapshot<Map<String, dynamic>>>
      getTask(String taskId) {
    return _tasksRef.doc(taskId).get();
  }

  // Menambahkan tugas baru
  
  // Menambahkan tugas baru sekaligus membuat notifikasi
    // Menambahkan tugas baru sekaligus membuat notifikasi
  static Future<void> addTask({
    required String title,
    String description = '',
    required DateTime date,
    String time = '',
    String category = 'Pribadi',
    String priority = 'Sedang',
    int? reminderMinutesBefore,
    List<Map<String, dynamic>> checklist = const [],
    String? attachmentPath,
    String? attachmentName,
  }) async {
    final now = Timestamp.now();

    final taskRef = _tasksRef.doc();
    final notificationRef = _notificationsRef.doc();

    final batch = _firestore.batch();

    // Menyimpan tugas
    batch.set(taskRef, {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'category': category,
      'priority': priority,
      'reminderMinutesBefore': reminderMinutesBefore,
      'checklist': checklist,
      'attachmentPath': attachmentPath,
      'attachmentName': attachmentName,
      'isCompleted': false,
      'status': 'Belum dimulai',
      'activity': [
        {
          'action': 'Tugas dibuat',
          'createdAt': now,
        }
      ],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Membuat notifikasi
    batch.set(notificationRef, {
      'title': 'Tugas baru ditambahkan',
      'message': 'Tugas "$title" berhasil ditambahkan.',
      'type': 'task',
      'isRead': false,
      'taskId': taskRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }


  // Memperbarui informasi tugas
  static Future<void> updateTask({
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    await _tasksRef.doc(taskId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Menambahkan item checklist
  static Future<void> addChecklistItem({
    required String taskId,
    required String title,
  }) async {
    await _tasksRef.doc(taskId).update({
      'checklist': FieldValue.arrayUnion([
        {
          'title': title,
          'isCompleted': false,
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logActivity(
      taskId: taskId,
      action: 'Checklist ditambahkan',
    );
  }

  // Mengubah status checklist
  static Future<void> updateChecklistItem({
    required String taskId,
    required int index,
    required bool isCompleted,
  }) async {
    final doc = await _tasksRef.doc(taskId).get();
    final data = doc.data();

    if (data == null) return;

    final checklist = List<Map<String, dynamic>>.from(
      (data['checklist'] ?? []).map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );

    if (index < 0 || index >= checklist.length) return;

    checklist[index]['isCompleted'] = isCompleted;

    final allCompleted = checklist.isNotEmpty &&
        checklist.every((item) => item['isCompleted'] == true);

    await _tasksRef.doc(taskId).update({
      'checklist': checklist,
      'status': allCompleted
          ? 'Selesai'
          : checklist.any(
              (item) => item['isCompleted'] == true,
            )
              ? 'Sedang dikerjakan'
              : 'Belum dimulai',
      'isCompleted': allCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logActivity(
      taskId: taskId,
      action: isCompleted
          ? 'Checklist diselesaikan'
          : 'Checklist dibuka kembali',
    );
  }

  // Menghapus tugas
  static Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  // Menandai tugas selesai atau belum selesai
  static Future<void> setTaskCompleted({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _tasksRef.doc(taskId).update({
      'isCompleted': isCompleted,
      'status': isCompleted ? 'Selesai' : 'Belum dimulai',
      'updatedAt': FieldValue.serverTimestamp(),
      'activity': FieldValue.arrayUnion([
        {
          'action': isCompleted
              ? 'Tugas diselesaikan'
              : 'Tugas dibuka kembali',
          'createdAt': Timestamp.now(),
        }
      ]),
    });
  }

  // Mencatat aktivitas tugas
  static Future<void> logActivity({
    required String taskId,
    required String action,
  }) async {
    await _tasksRef.doc(taskId).update({
      'activity': FieldValue.arrayUnion([
        {
          'action': action,
          'createdAt': Timestamp.now(),
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
