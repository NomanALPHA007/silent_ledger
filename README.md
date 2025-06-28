# Silent Ledger

Silent Ledger is a smart financial management application built with Flutter, featuring advanced transaction tracking, AI-powered insights, and comprehensive financial analytics.

## Features

- 📱 **Cross-Platform**: Available on Web, iOS, and Android
- 🤖 **AI-Powered Insights**: Smart transaction categorization and financial recommendations
- 📊 **Advanced Analytics**: Comprehensive financial reports and visualizations
- 🔒 **Secure**: End-to-end encryption with Supabase backend
- 💰 **Monetization Ready**: Built-in revenue tracking and API monetization
- 🏪 **Merchant Support**: Dedicated merchant dashboard and QR payment system

## Live Demo

🌐 **Web App**: [https://your-app.vercel.app](https://your-app.vercel.app)

## Technology Stack

- **Frontend**: Flutter 3.16.0
- **Backend**: Supabase
- **Database**: PostgreSQL
- **Deployment**: Vercel (Web), App Stores (Mobile)
- **State Management**: Provider Pattern
- **Charts**: FL Chart
- **Authentication**: Supabase Auth

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.10
- Dart SDK ≥ 3.0
- Supabase Account
- Vercel Account (for web deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/silent-ledger.git
   cd silent-ledger
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
   
   # For web
   flutter run -d chrome --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
   ```

## Deployment

### Web Deployment (Vercel)

1. **Connect your GitHub repository to Vercel**
2. **Set environment variables in Vercel dashboard**:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. **Deploy automatically on push to main branch**

### Manual Web Build

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --web-renderer canvaskit
```

### Mobile App Deployment

#### Android (Google Play Store)
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

#### iOS (Apple App Store)
```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities and exports
├── presentation/             # UI screens and widgets
│   ├── dashboard_screen/     # Financial dashboard
│   ├── transaction_list_screen/  # Transaction management
│   ├── reports_screen/       # Financial reports
│   ├── settings_screen/      # App settings
│   └── admin_dashboard_screen/   # Admin panel
├── services/                 # Business logic and API services
├── theme/                    # App theming
├── widgets/                  # Reusable UI components
└── routes/                   # Navigation routing
```

## Configuration

### Supabase Setup

1. Create a new Supabase project
2. Run the migration scripts in `supabase/migrations/`
3. Update your environment variables

### GitHub Actions Setup

Add these secrets to your GitHub repository:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@silentledger.com or create an issue in this repository.

## Roadmap

- [ ] Multi-currency support
- [ ] Advanced AI insights
- [ ] Integration with banking APIs
- [ ] Cryptocurrency tracking
- [ ] Export to accounting software
- [ ] Voice-controlled transactions

---

Made with ❤️ using Flutter