import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/parking_location.dart';
import '../services/storage_service.dart';

class AddParkingScreen extends StatefulWidget {
  const AddParkingScreen({super.key});

  @override
  State<AddParkingScreen> createState() => _AddParkingScreenState();
}

class _AddParkingScreenState extends State<AddParkingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  String? _floor;
  String? _section;
  String? _memo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주차 위치 저장'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_parking,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '주차 위치 정보',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '층',
                        hintText: 'B2, 1층, 2층 등',
                        prefixIcon: Icon(Icons.layers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '층을 입력해주세요';
                        }
                        return null;
                      },
                      onSaved: (value) => _floor = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '구역',
                        hintText: 'A-1, B-2 등',
                        prefixIcon: Icon(Icons.grid_view),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '구역을 입력해주세요';
                        }
                        return null;
                      },
                      onSaved: (value) => _section = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '메모',
                        hintText: '기억할 만한 특징을 메모하세요',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                      onSaved: (value) => _memo = value,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FilledButton(
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final location = ParkingLocation(
        id: const Uuid().v4(),
        floor: _floor!,
        section: _section!,
        memo: _memo,
        createdAt: DateTime.now(),
      );

      await _storageService.saveParkingLocation(location);
      if (mounted) {
        Navigator.pop(context, true); // true를 반환하여 새로운 위치가 저장되었음을 알림
      }
    }
  }
}
