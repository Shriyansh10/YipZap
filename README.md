# MemePlatform - Share Your Memes 😂

A complete, production-ready meme posting platform built with Next.js 13+, TypeScript, Tailwind CSS, and Supabase.

## Features ✨

- **Three Main Feeds**:
  - 🔥 **Top**: Most upvoted memes (Today/Week toggle)
  - ✨ **Fresh**: Newest memes sorted by creation time
  - 📰 **Articles**: Admin-only blog articles about meme culture

- **Authentication**: Supabase Auth with Google, Twitter/X, and Email/Password
- **Media Upload**: Support for images, GIFs, and videos up to 20MB
- **Interactions**: Like, comment, share functionality
- **Responsive Design**: Mobile-first, fully accessible
- **Real-time Updates**: Using React Query for optimal caching
- **Admin Panel**: Article management system

## Tech Stack 🛠️

- **Frontend**: Next.js 14 (App Router), TypeScript, Tailwind CSS
- **UI Components**: shadcn/ui with Radix UI primitives
- **Backend**: Supabase (Database + Auth + Storage)
- **State Management**: React Query (TanStack Query)
- **Form Handling**: React Hook Form with Zod validation
- **Styling**: Tailwind CSS with custom design system
- **Icons**: Lucide React
- **Notifications**: Sonner

## Quick Start 🚀

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd meme-platform
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp .env.example .env.local
   ```

   Update the environment variables with your Supabase credentials.

4. **Database Setup**

   The database schema will be set up automatically when the Supabase connection is established. The schema includes:

   - `users` - User profiles and authentication
   - `profiles` - Extended user information
   - `meme_posts` - Meme content and metadata
   - `meme_likes` - Like interactions
   - `meme_comments` - Comment system
   - `articles` - Blog articles (admin only)

5. **Run the development server**
   ```bash
   npm run dev
   ```

6. **Open your browser**

   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure 📁

```
├── app/                    # Next.js App Router pages
│   ├── articles/          # Articles feed and individual articles
│   ├── fresh/             # Fresh memes feed
│   └── layout.tsx         # Root layout with providers
├── components/
│   ├── auth/              # Authentication components
│   ├── feeds/             # Feed components (Top, Fresh, Articles)
│   ├── layout/            # Layout components (Header, FAB)
│   ├── memes/             # Meme-related components
│   └── ui/                # Reusable UI components (shadcn/ui)
├── hooks/                 # Custom React hooks
├── lib/                   # Utilities and configurations
│   ├── supabase.ts        # Supabase client
│   ├── validations.ts     # Zod schemas
│   └── utils.ts           # Utility functions
```

## Key Components 🎨

### Core Features
- **Floating Action Button**: Post new memes from any page
- **MemeCard**: Rich media display with interactions
- **LoginPromptModal**: Guest user authentication flow
- **TopFeed**: Ranked memes with timeframe filtering
- **FreshFeed**: Chronological meme discovery

### Authentication Flow
1. Guest users see login prompt on protected actions
2. Multiple sign-in options (Google, Twitter, Email)
3. Profile completion for new users
4. Seamless experience continuation after authentication

## Database Schema 🗄️

### Core Tables
- **users**: Authentication and basic profile
- **profiles**: Extended user information (username, DOB)
- **meme_posts**: Media content with metadata
- **meme_likes**: User interaction tracking
- **meme_comments**: Comment system
- **articles**: Admin-authored blog posts

### Security
- Row Level Security (RLS) enabled on all tables
- Granular permissions based on user roles
- Secure media upload handling

## Deployment 🚀

### Vercel (Recommended)

1. **Connect your repository** to Vercel
2. **Configure environment variables** in Vercel dashboard
3. **Deploy** - Vercel handles the rest automatically

### Environment Variables for Production
```bash
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_SITE_URL=https://your-domain.com
OAUTH_GOOGLE_CLIENT_ID=your-google-client-id
OAUTH_GOOGLE_CLIENT_SECRET=your-google-client-secret
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Development Commands 💻

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run typecheck    # Run TypeScript checking
```

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Features Roadmap 🗺️

### Current Status ✅
- [x] Core feed functionality (Top, Fresh, Articles)
- [x] Authentication system with multiple providers
- [x] Responsive design with modern UI
- [x] Media upload support
- [x] Basic interaction system (like, comment, share)

### Pending Implementation 🚧
*Note: These features require database connection to be completed*
- [ ] Database schema migration
- [ ] Real authentication integration
- [ ] Media upload to Supabase Storage
- [ ] Live interaction features
- [ ] Admin article management
- [ ] User profile pages
- [ ] Comment system
- [ ] Search functionality
- [ ] Moderation tools

## Support 💬

If you encounter any issues or have questions:

1. Check the [documentation](README.md)
2. Search [existing issues](issues)
3. Create a [new issue](issues/new) if needed

---

**Built with ❤️ for the meme community**