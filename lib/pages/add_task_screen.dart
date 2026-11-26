import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _checklistController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  String _category = 'Pribadi';
  String _priority = 'Sedang';
  int? _reminderMinutesBefore;

  final List<String> _checklistItems = [];

  bool _isSaving = false;
  String? _attachmentPath;
  String? _attachmentName;

  final List<String> _categories = [
    'Akademik',
    'Organisasi',
    'Project',
    'Pribadi',
  ];

  final List<String> _priorities = [
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  final Map<int, String> _reminderOptions = {
    5: '5 menit sebelumnya',
    15: '15 menit sebelumnya',
    30: '30 menit sebelumnya',
    60: '1 jam sebelumnya',
    1440: '1 hari sebelumnya',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }


  // Memilih gambar lampiran
  
  // Memilih satu gambar lampiran
  Future<void> _pickImage() async {
    try {
      final selectedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (selectedFile == null || selectedFile.path == null) {
        return;
      }

      final sourceFile = File(selectedFile.path!);
      final directory = await getApplicationDocumentsDirectory();

      final safeName = selectedFile.name.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );

      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_$safeName';

      final targetPath =
          '${directory.path}${Platform.pathSeparator}$fileName';

      await sourceFile.copy(targetPath);

      if (!mounted) return;

      setState(() {
        _attachmentPath = targetPath;
        _attachmentName = selectedFile.name;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }


  // Menghapus gambar yang dipilih
  void _removeImage() {
    setState(() {
      _attachmentPath = null;
      _attachmentName = null;
    });
  }



  void _addChecklistItem() {
    final title = _checklistController.text.trim();

    if (title.isEmpty) return;

    setState(() {
      _checklistItems.add(title);
      _checklistController.clear();
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistItems.removeAt(index);
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await TaskService.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        time: _selectedTime == null
            ? ''
            : _formatTime(_selectedTime!),
        category: _category,
        priority: _priority,
        reminderMinutesBefore: _reminderMinutesBefore,
        checklist: _checklistItems.map((item) {
          return {
            'title': item,
            'isCompleted': false,
          };
        }).toList(),
attachmentPath: _attachmentPath,
attachmentName: _attachmentName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil ditambahkan!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan tugas: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.35,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat tugas baru',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rencanakan langkah kecilmu hari ini.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'Informasi Tugas',
                            'Masukkan informasi dasar tugasmu.',
                          ),
                          const SizedBox(height: 20),

                          
TextFormField(
  controller: _titleController,
  textCapitalization: TextCapitalization.sentences,
  decoration: _inputDecoration(
    'Nama tugas',
    Icons.edit_outlined,
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tugas wajib diisi.';
    }
    return null;
  },
),


                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            textCapitalization:
                                TextCapitalization.sentences,
                            decoration: _inputDecoration(
                              'Deskripsi tugas',
                              Icons.description_outlined,
                            ),
                          ),


const SizedBox(height: 16),

_buildSectionTitle(
  'Lampiran Gambar',
  'Tambahkan gambar pendukung tugas jika diperlukan.',
),

const SizedBox(height: 12),

if (_attachmentPath == null)
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: _isSaving ? null : _pickImage,
      icon: const Icon(Icons.image_outlined),
      label: const Text('Pilih Gambar'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  )
else
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: colors.outlineVariant),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_attachmentPath!),
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.image_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _attachmentName ?? 'Gambar terpilih',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: _removeImage,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              tooltip: 'Hapus gambar',
            ),
          ],
        ),
      ],
    ),
  ),


                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickDate,
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  label: Text(
                                    _formatDate(_selectedDate),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickTime,
                                  icon: const Icon(
                                    Icons.access_time,
                                  ),
                                  label: Text(
                                    _selectedTime == null
                                        ? 'Pilih waktu'
                                        : _formatTime(_selectedTime!),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'Kategori & Prioritas',
                            'Atur jenis dan tingkat kepentingan tugas.',
                          ),
                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: _inputDecoration(
                              'Kategori',
                              Icons.category_outlined,
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _category = value;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: _inputDecoration(
                              'Prioritas',
                              Icons.flag_outlined,
                            ),
                            items: _priorities.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _priority = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'Pengingat',
                            'Pilih kapan kamu ingin diingatkan.',
                          ),
                          const SizedBox(height: 20),

                          DropdownButtonFormField<int?>(
                            initialValue: _reminderMinutesBefore,
                            decoration: _inputDecoration(
                              'Waktu pengingat',
                              Icons.notifications_outlined,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Tanpa pengingat'),
                              ),
                              ..._reminderOptions.entries.map((entry) {
                                return DropdownMenuItem<int?>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _reminderMinutesBefore = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Notifikasi otomatis akan kita aktifkan '
                            'pada tahap integrasi berikutnya.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            'Checklist',
                            'Pecah tugas menjadi langkah-langkah kecil.',
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _checklistController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: _inputDecoration(
                                    'Tambah langkah tugas',
                                    Icons.check_circle_outline,
                                  ),
                                  onSubmitted: (_) {



                                    _addChecklistItem();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _addChecklistItem,
                                icon: const Icon(Icons.add),
                                tooltip: 'Tambah checklist',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (_checklistItems.isEmpty)
                            Text(
                              'Belum ada checklist. Kamu bisa '
                              'menambahkannya jika diperlukan.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),

                          ..._checklistItems.asMap().entries.map((entry) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.check_box_outline_blank,
                                color: colors.primary,
                              ),
                              title: Text(entry.value),
                              trailing: IconButton(
                                onPressed: () {
                                  _removeChecklistItem(entry.key);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                tooltip: 'Hapus checklist',
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveTask,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving
                              ? 'Menyimpan...'
                              : 'Simpan Tugas',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
