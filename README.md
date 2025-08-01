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
- OpenAI (optional for NLP summarization)
- Flutter packages: `http`, `geolocator`, `url_launcher`, `flutter_dotenv`

## 🔐 API Keys

To run this app, you'll need API keys from:

- [Google Cloud Platform (Places API)](https://console.cloud.google.com/)
- [Yelp Fusion](https://www.yelp.com/developers/v3/manage_app)

Add them to a `.env` file in your root directory:

```env
GOOGLE_MAPS_API_KEY=your_google_key
YELP_API_KEY=your_yelp_key
