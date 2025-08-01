# Revity

**Revity** is a cross-platform mobile app built with Flutter that aggregates ratings, reviews, and social links from platforms like Google and Yelp. Designed for consumers, Revity makes it easy to discover the best local spots based on aggregated reputation and real user feedback.

## 🚀 Features

- 🔍 Search for places by name or use your current location
- ⭐ View aggregated ratings and review counts from Google and Yelp
- 📝 Summarized review highlights from multiple sources
- 🔗 Quick access to Google Maps, Yelp, Instagram, and Facebook pages
- 📱 Runs on iOS and Android

## 📸 Screenshots

*(Coming soon)*

## 🧑‍💻 Tech Stack

- Flutter
- Google Places API
- Yelp Fusion API
- Flutter packages: `http`, `geolocator`, `url_launcher`, `flutter_dotenv`

## 🔐 API Keys Setup

To run this app, you'll need API keys from:

1. **Google Cloud Platform (Places API)**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable the Places API
   - Create credentials (API Key)
   - Restrict the key to Places API only for security

2. **Yelp Fusion API**
   - Go to [Yelp Developers](https://www.yelp.com/developers/v3/manage_app)
   - Create a new app
   - Get your API key

3. **Configure Environment**
   - Copy `env.example` to `.env`
   - Add your API keys:

```env
GOOGLE_MAPS_API_KEY=your_google_key_here
YELP_API_KEY=your_yelp_key_here
```

## 🛠️ Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/revity-app.git
   cd revity-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API keys**
   ```bash
   cp env.example .env
   # Edit .env with your actual API keys
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Platform Setup

### Android
- No additional setup required
- Location permissions are handled automatically

### iOS
- Open `ios/Runner.xcworkspace` in Xcode
- Add location usage descriptions in `Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app needs location access to find places near you</string>
  ```

## 🔧 Usage

1. **Search by name**: Enter a place name (e.g., "Starbucks", "McDonald's")
2. **Use current location**: Tap the location button to search nearby places
3. **View aggregated reviews**: See ratings from both Google and Yelp
4. **Read full reviews**: Tap "View on Google" or "View on Yelp" to see complete reviews
5. **Summary tags**: See what people commonly mention about the place

## 📄 License

This project is **not licensed for commercial use**.  
See the [LICENSE](./LICENSE) file for full terms.

## 🤝 Contributing

Pull requests are welcome for non-commercial purposes. For major changes, please open an issue first to discuss what you'd like to change or improve.

## 🐛 Troubleshooting

**"API key not found" error**
- Make sure you've created the `.env` file
- Verify your API keys are correct
- Check that the keys have the necessary permissions

**"No reviews found" error**
- Try a more specific place name
- Ensure the place exists on both Google and Yelp
- Check your internet connection

**Location not working**
- Grant location permissions when prompted
- Enable location services on your device
- For iOS, ensure location usage descriptions are added

