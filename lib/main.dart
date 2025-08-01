import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'screens/home_screen.dart';

// Global environment variables map for web mode
final Map<String, String> _webEnvVars = <String, String>{};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables
  await _initializeEnvironment();
  
  runApp(const MyApp());
}

Future<void> _initializeEnvironment() async {
  // For web, we need to handle environment variables differently
  if (kIsWeb) {
    print('Debug: Running in web mode');
    
    // Since .env file loading is problematic in web mode, we'll use a different approach
    // You can manually set your API keys here for testing
    // Replace these with your actual API keys
    _webEnvVars['GOOGLE_MAPS_API_KEY'] = 'AIzaSyA7JFoMUIMjf9WCNsNAZIXbUTopWq4IcZE';
    _webEnvVars['YELP_API_KEY'] = 'Wk_-RvCzbgTTaFjH6C2ceaulN7TPEPOx4zV05mlk4g8w1DA35wgswj-C-pPcCj0I1DY7Wz1tTBom7y0hK-wfk1g9mAaehc41d5FcsyagKXyoSk3GOI3ruAWdNvKMaHYx';
    
    // Check if we have real API keys (not placeholder text)
    final googleKey = _webEnvVars['GOOGLE_MAPS_API_KEY'];
    final yelpKey = _webEnvVars['YELP_API_KEY'];
    
    if (googleKey != null && googleKey.isNotEmpty && 
        googleKey != 'demo_key' && !googleKey.contains('YOUR_ACTUAL_')) {
      print('Debug: Using REAL Google API key');
    } else {
      _webEnvVars['GOOGLE_MAPS_API_KEY'] = 'demo_key';
      print('Debug: Using DEMO Google API key');
    }
    
    if (yelpKey != null && yelpKey.isNotEmpty && 
        yelpKey != 'demo_key' && !yelpKey.contains('YOUR_ACTUAL_')) {
      print('Debug: Using REAL Yelp API key');
    } else {
      _webEnvVars['YELP_API_KEY'] = 'demo_key';
      print('Debug: Using DEMO Yelp API key');
    }
    
    print('Debug: Environment variables initialized for web mode');
  } else {
    // For mobile/desktop, try to load .env file
    try {
      await dotenv.load(fileName: ".env");
      final googleKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      final yelpKey = dotenv.env['YELP_API_KEY'];
      
      print('Debug: Google API Key loaded: ${googleKey?.substring(0, googleKey.length > 10 ? 10 : googleKey.length)}...');
      print('Debug: Yelp API Key loaded: ${yelpKey?.substring(0, yelpKey.length > 10 ? 10 : yelpKey.length)}...');
    } catch (e) {
      print('Warning: .env file not found. Using demo keys. Error: $e');
      // Set default values if .env file is not found
      dotenv.env['GOOGLE_MAPS_API_KEY'] = 'demo_key';
      dotenv.env['YELP_API_KEY'] = 'demo_key';
    }
  }
}

// Helper function to get environment variables that works in both web and mobile
String getEnvVar(String key, {String defaultValue = ''}) {
  if (kIsWeb) {
    return _webEnvVars[key] ?? defaultValue;
  } else {
    return dotenv.env[key] ?? defaultValue;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
