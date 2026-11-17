import 'dart:async';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SharoCaptainApp());
}

class SharoCaptainApp extends StatelessWidget {
  const SharoCaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شاڕۆ کاپتن | Sharo Captain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Bahij',
        primaryColor: const Color(0xFF00A86B),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          primary: const Color(0xFF00A86B),
          secondary: const Color(0xFFFF7A00),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SharoCaptainScreen(),
    );
  }
}

class SharoCaptainScreen extends StatefulWidget {
  const SharoCaptainScreen({super.key});

  @override
  State<SharoCaptainScreen> createState() => _SharoCaptainScreenState();
}

class _SharoCaptainScreenState extends State<SharoCaptainScreen> {
  int _currentTab = 0;
  bool isOnline = true;
  int todayEarnings = 32000;
  int completedDeliveries = 10;
  int activeStep = 1; // 1 = Heading to store, 2 = At store, 3 = Heading to customer, 0 = Idle
  Timer? _orderCheckTimer;

  Map<String, dynamic>? currentDelivery = {
    'id': 'SHR-9182',
    'storeName': 'کەبابی دەربەندیخان (Darbandikhan)',
    'storeAddress': 'دەربەندیخان - ناو بازاڕ - تەنیشت فلکەی ناوەند',
    'storePhone': '0770 123 4567',
    'customerName': 'محەمەد کەمال',
    'customerAddress': 'دەربەندیخان - گەڕەکی سەرسیر، کۆڵانی ١٤',
    'customerPhone': '0770 987 6543',
    'fee': 1000,
    'totalCashToCollect': 33000,
    'distance': '1.2 کم',
    'estimatedTime': '10 خولەک',
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveDeliveryOrders();
    _orderCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (isOnline && currentDelivery == null) {
        _fetchLiveDeliveryOrders();
      }
    });
  }

  @override
  void dispose() {
    _orderCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLiveDeliveryOrders() async {
    final orders = await ApiService.getDeliveryOrders();
    if (orders.isNotEmpty && currentDelivery == null && mounted) {
      final o = orders[0];
      setState(() {
        currentDelivery = {
          'id': o['id'] ?? 'SHR-7712',
          'storeName': o['shopName'] ?? 'چێشتخانە',
          'storeAddress': 'دەربەندیخان - ناو بازاڕ',
          'storePhone': '0770 123 4567',
          'customerName': o['customerName'] ?? 'کڕیاری شاڕۆ',
          'customerAddress': o['customerLocation'] ?? 'دەربەندیخان - گەڕەکی سەرسیر',
          'customerPhone': o['customerPhone'] ?? '0770 987 6543',
          'fee': 3500,
          'totalCashToCollect': o['total'] ?? 16000,
          'distance': '2.8 کم',
          'estimatedTime': '12 خولەک',
        };
        activeStep = 1;
      });
    }
  }

  Future<void> advanceStep() async {
    if (currentDelivery == null) return;
    final id = currentDelivery!['id'];

    if (activeStep == 1) {
      setState(() => activeStep = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('گەیشتیتە چێشتخانە. پاکێجەکە بپشکنە و وەریگرە.')),
      );
    } else if (activeStep == 2) {
      await ApiService.pickupOrder(id);
      setState(() => activeStep = 3);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.blue, content: Text('پاکێج وەرگیرا لە سێرڤەر. لە ڕێگایت بەرەو کڕیار.')),
        );
      }
    } else if (activeStep == 3) {
      await ApiService.deliverOrder(id);
      setState(() {
        todayEarnings += (currentDelivery?['fee'] as int? ?? 3500);
        completedDeliveries += 1;
        activeStep = 0;
        currentDelivery = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('گەیاندن تەواو بوو! بڕی پارەی کاش لە کڕیار وەرگیرا.')),
        );
      }
    }
  }

  void receiveNewTestOrder() {
    setState(() {
      currentDelivery = {
        'id': 'SHR-9199',
        'storeName': 'برگرزۆن پرۆ',
        'storeAddress': 'سەرچنار - شەقامی سەرەکی گەشتیاری',
        'storePhone': '0770 333 4455',
        'customerName': 'هەژار محەمەد',
        'customerAddress': 'ڕاپەڕین - بەرامبەر زانکۆ',
        'customerPhone': '0750 111 2233',
        'fee': 4000,
        'totalCashToCollect': 18000,
        'distance': '4.2 کم',
        'estimatedTime': '16 خولەک',
      };
      activeStep = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/icons/ic_launcher.png', width: 32, height: 32),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شاڕۆ کاپتن | لۆجستیك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('ڕێبین ئەحمەد (کاپتنی دەربەندیخان)', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(isOnline ? 'ئۆنلاین' : 'ئۆفلاین', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Switch(
                value: isOnline,
                activeColor: Colors.amberAccent,
                onChanged: (val) => setState(() => isOnline = val),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildDeliveryTab(),
          _buildEarningsTab(),
          _buildHistoryTab(),
          _buildCaptainProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (idx) => setState(() => _currentTab = idx),
        selectedItemColor: const Color(0xFF00A86B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'گەیاندن'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'داهاتەکەم'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'مێژوو'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پرۆفایل'),
        ],
      ),
    );
  }

  Widget _buildDeliveryTab() {
    if (!isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('تۆ ئێستا لە دۆخی ئۆفلاینیت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('بۆ وەرگرتنی داواکاری نوێ لە دەوروبەرت باری خۆت بکە بە ئۆنلاین', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => isOnline = true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B), foregroundColor: Colors.white),
              child: const Text('چوونە سەر هێڵ (Online)'),
            ),
          ],
        ),
      );
    }

    if (currentDelivery == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/ic_amada_user.png', width: 90, height: 90),
              const SizedBox(height: 16),
              const Text('ڕاداری شاڕۆ: چاوەڕوانی داواکاریین...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('سێرڤەری سەرەکی پشکنین دەکرێت بۆ نزیکترین چێشتخانە', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchLiveDeliveryOrders,
                icon: const Icon(Icons.sync),
                label: const Text('پشکنینی داواکاری بەردەست'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B), foregroundColor: Colors.white),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: receiveNewTestOrder,
                child: const Text('تاقیکردنەوەی خێرای داواکاری نوێ'),
              ),
            ],
          ),
        ),
      );
    }

    final d = currentDelivery!;
    String stepTitle = '';
    String actionBtnText = '';
    Color stepColor = Colors.blue;

    if (activeStep == 1) {
      stepTitle = 'لە ڕێگایت بەرەو چێشتخانە';
      actionBtnText = 'گەیشتمە چێشتخانە (ڕاگەیاندن)';
      stepColor = Colors.orange;
    } else if (activeStep == 2) {
      stepTitle = 'لە ناو چێشتخانە (وەرگرتنی خواردن)';
      actionBtnText = 'پاکێجم وەرگرت (دەستپێکردنی ڕێگا)';
      stepColor = Colors.blue;
    } else if (activeStep == 3) {
      stepTitle = 'لە ڕێگایت بەرەو کڕیار';
      actionBtnText = 'تەواوکردنی گەیاندن و وەرگرتنی کاش';
      stepColor = Colors.green;
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: stepColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.two_wheeler, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('داواکاری #${d['id']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(stepTitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text('کرێ: +${d['fee']} د.ع', style: TextStyle(color: stepColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: LinearProgressIndicator(value: activeStep / 3, color: const Color(0xFF00A86B))),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.store, color: Color(0xFF00A86B), size: 20),
                        SizedBox(width: 6),
                        Text('خاڵی وەرگرتن (چێشتخانە)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {}),
                  ],
                ),
                Text('${d['storeName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${d['storeAddress']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_pin_circle, color: Colors.blue, size: 20),
                        SizedBox(width: 6),
                        Text('شوێنی گەیاندن (کڕیار)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.phone, color: Colors.blue), onPressed: () {}),
                  ],
                ),
                Text('${d['customerName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${d['customerAddress']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('بڕی پارەی کاش لە کڕیار:'),
                    Text('${d['totalCashToCollect']} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: advanceStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(actionBtnText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00A86B), Color(0xFF10B981)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('داهاتی ئەمرۆی کاپتن', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text('$todayEarnings د.ع', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('$completedDeliveries', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text('گەیاندنی تەواوکراو', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ]),
                  const Column(children: [
                    Text('4.95 ★', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('ڕەیتینگی کاپتن', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ]),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const ListTile(
            leading: Icon(Icons.account_balance, color: Color(0xFF00A86B)),
            title: Text('پارەی دەستی کاشی کڕیاران'),
            subtitle: Text('بڕی ئەو کاشەی دەبێت ڕادەستی شاڕۆ یان چێشتخانە بکرێت'),
            trailing: Text('148,000 د.ع', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('مێژووی دوایین گەیاندنەکانی شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildHistoryItem("داواکاری #SHR-9170 · چێشتخانەی کەیف", "گەیشت بۆ سەرچنار · ١١:١٥ پ.ن", "+3,500 د.ع"),
        _buildHistoryItem("داواکاری #SHR-9165 · برگرزۆن پرۆ", "گەیشت بۆ تووی مەلیك · ١٠:٤٠ پ.ن", "+3,500 د.ع"),
        _buildHistoryItem("داواکاری #SHR-9160 · شاڕۆ مارکێت", "گەیشت بۆ بەختیاری · ١٠:٠٥ پ.ن", "+3,000 د.ع"),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String subtitle, String amount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFD1FAE5), child: Icon(Icons.check, color: Color(0xFF00A86B))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A86B))),
      ),
    );
  }

  Widget _buildCaptainProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.asset('assets/icons/ic_launcher.png', width: 50, height: 50),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ڕێبین ئەحمەد خدر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('ماتۆڕسکیل هۆندا ١٥٠ سپی', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('مۆڵەت: دەربەندیخان - ٢٩١٨', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
