import 'package:flutter/material.dart';
import 'add_parking_screen.dart';
import '../models/parking_location.dart';
import '../services/storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final listKey = GlobalKey<_ParkingLocationListState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('주차 어디했지?'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleThemeMode();
            },
          ),
        ],
      ),
      body: ParkingLocationList(key: listKey),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddParkingScreen(),
            ),
          );

          if (result == true) {
            listKey.currentState?.refreshList();
          }
        },
        icon: const Icon(Icons.local_parking),
        label: const Text('주차 위치 저장'),
      ),
    );
  }
}

class ParkingLocationList extends StatefulWidget {
  const ParkingLocationList({super.key});

  @override
  State<ParkingLocationList> createState() => _ParkingLocationListState();
}

class _ParkingLocationListState extends State<ParkingLocationList> {
  final _storageService = StorageService();
  List<ParkingLocation> _locations = [];
  static const int maxDisplayCount = 5; // 히스토리 표시 개수 제한

  @override
  void initState() {
    super.initState();
    _loadParkingLocations();
  }

  Future<void> _loadParkingLocations() async {
    final locations = await _storageService.getParkingLocations();
    setState(() {
      _locations = locations;
    });
  }

  void refreshList() {
    _loadParkingLocations();
  }

  @override
  Widget build(BuildContext context) {
    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_rental,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 주차 위치가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 주차 위치를 저장해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // 현재 주차 위치 (가장 최근)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '현재 주차 위치',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_parking,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_locations[0].floor} - ${_locations[0].section}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(
                                            _locations[0].createdAt),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_locations[0].memo != null &&
                                _locations[0].memo!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _locations[0].memo!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8), // 여백 축소
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: SvgPicture.asset(
                          'assets/car.svg',
                          width: 120,
                          height: 80,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 이전 주차 기록
        if (_locations.length > 1) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                '이전 주차 기록',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final location = _locations[index + 1];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('${location.floor} - ${location.section}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDateTime(location.createdAt)),
                        if (location.memo != null && location.memo!.isNotEmpty)
                          Text(
                            location.memo!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final delete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('주차 기록 삭제'),
                            content: const Text('이 주차 기록을 삭제하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('삭제'),
                              ),
                            ],
                          ),
                        );

                        if (delete == true) {
                          await _storageService
                              .deleteParkingLocation(location.id);
                          _loadParkingLocations();
                        }
                      },
                    ),
                    isThreeLine:
                        location.memo != null && location.memo!.isNotEmpty,
                  ),
                );
              },
              childCount: _locations.length > maxDisplayCount + 1
                  ? maxDisplayCount
                  : _locations.length - 1,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
