import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_reader/sim_reader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIM Reader Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: SimReaderExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimReaderExample extends StatefulWidget {
  const SimReaderExample({super.key});

  @override
  _SimReaderExampleState createState() => _SimReaderExampleState();
}

class _SimReaderExampleState extends State<SimReaderExample> {
  List<SimInfo> simCards = [];
  NetworkInfo? networkInfo;
  bool hasSimCard = false;
  bool isLoading = false;
  bool permissionGranted = false;
  String? error;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
  }

  Future<void> checkAndRequestPermissions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Check if permission is already granted
      PermissionStatus status = await Permission.phone.status;

      if (status.isDenied) {
        // Request permission
        status = await Permission.phone.request();
      }

      if (status.isGranted) {
        setState(() {
          permissionGranted = true;
        });
        await loadSimInfo();
      } else if (status.isPermanentlyDenied) {
        setState(() {
          error =
              'Phone permission is permanently denied. Please enable it in app settings.';
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Phone permission is required to read SIM card information.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to request permissions: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadSimInfo() async {
    if (!permissionGranted) {
      await checkAndRequestPermissions();
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Check if device has SIM card
      final hasSim = await SimReader.hasSimCard();

      List<SimInfo> allSimInfo = [];
      NetworkInfo? netInfo;

      if (hasSim) {
        // Get all SIM cards info
        allSimInfo = await SimReader.getAllSimInfo();

        // Get network information
        netInfo = await SimReader.getNetworkInfo();
      }

      setState(() {
        hasSimCard = hasSim;
        simCards = allSimInfo;
        networkInfo = netInfo;
        isLoading = false;
      });
    } on SimReaderException catch (e) {
      setState(() {
        error = 'SIM Reader Error: ${e.message}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Unexpected error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIM Reader Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: loadSimInfo,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Permission Status Card
              Card(
                color: permissionGranted
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            permissionGranted
                                ? Icons.check_circle
                                : Icons.warning,
                            color: permissionGranted
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          SizedBox(width: 8),
                          Text(
                            permissionGranted
                                ? 'Permissions Granted'
                                : 'Permissions Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: permissionGranted
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (!permissionGranted) ...[
                        SizedBox(height: 8),
                        Text(
                          'Phone permission is required to read SIM card information.',
                          style: TextStyle(color: Colors.orange.shade600),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: checkAndRequestPermissions,
                          child: Text('Grant Permission'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              if (isLoading)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading SIM information...'),
                    ],
                  ),
                )
              else if (error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          error!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                if (!permissionGranted) {
                                  openAppSettings();
                                }
                              },
                              child: Text('Open Settings'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: loadSimInfo,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else if (permissionGranted) ...[
                // Device SIM Status
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              hasSimCard
                                  ? Icons.sim_card
                                  : Icons.sim_card_outlined,
                              color: hasSimCard ? Colors.green : Colors.grey,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              hasSimCard ? 'SIM Card Present' : 'No SIM Card',
                              style: TextStyle(
                                color: hasSimCard ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Network Information
                if (networkInfo != null) ...[
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Network Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow(
                            'Operator',
                            networkInfo!.networkOperatorName ?? 'Unknown',
                          ),
                          _buildInfoRow(
                            'Network Type',
                            networkInfo!.networkType ?? 'Unknown',
                          ),
                          _buildInfoRow(
                            'Network Available',
                            networkInfo!.isNetworkAvailable ? 'Yes' : 'No',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // SIM Cards Information
                if (simCards.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'SIM Cards (${simCards.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...simCards.asMap().entries.map((entry) {
                    final index = entry.key;
                    final simInfo = entry.value;

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sim_card, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'SIM ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (simInfo.simSlotIndex != null)
                                  Text(
                                    ' (Slot ${simInfo.simSlotIndex})',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                            Divider(height: 24),
                            _buildInfoRow(
                              'Carrier',
                              simInfo.carrierName ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'Country',
                              simInfo.countryCode?.toUpperCase() ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'Phone Number',
                              simInfo.phoneNumber ?? 'Not available',
                            ),
                            _buildInfoRow(
                              'MCC',
                              simInfo.mobileCountryCode ?? 'Unknown',
                            ),
                            _buildInfoRow(
                              'MNC',
                              simInfo.mobileNetworkCode ?? 'Unknown',
                            ),
                            if (simInfo.simSerialNumber != null)
                              _buildInfoRow(
                                'Serial Number',
                                simInfo.simSerialNumber!,
                              ),
                            if (simInfo.subscriberId != null)
                              _buildInfoRow(
                                'Subscriber ID',
                                _maskSubscriberId(simInfo.subscriberId!),
                              ),
                            _buildInfoRow(
                              'Roaming',
                              simInfo.isNetworkRoaming ? 'Yes' : 'No',
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ] else if (!isLoading && hasSimCard) ...[
                  SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'No SIM Information Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'SIM card detected but information could not be retrieved. This may be due to device restrictions or carrier limitations.',
                            style: TextStyle(color: Colors.orange.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // iOS Limitations Notice
                if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                  SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              SizedBox(width: 8),
                              Text(
                                'iOS Limitations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'On iOS, phone numbers, SIM serial numbers, and subscriber IDs are not available due to Apple\'s privacy restrictions.',
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: permissionGranted
          ? FloatingActionButton(
              onPressed: loadSimInfo,
              tooltip: 'Refresh SIM Information',
              child: Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }

  String _maskSubscriberId(String subscriberId) {
    if (subscriberId.length <= 4) return subscriberId;
    return subscriberId.substring(0, 3) +
        '*' * (subscriberId.length - 6) +
        subscriberId.substring(subscriberId.length - 3);
  }
}
