# Perspective App

A cross-platform mobile application for perspective sharing and collaboration.

## Project Structure

- `android/` - Android native application
- `ios/` - iOS native application (active project in `ios/Perspective`)
- `backend/` - Node.js backend API server (now vendored in repository)
- `shared/` - Shared assets and resources
- `docs/` - Project documentation

## Getting Started

### Backend (Railway)

The backend is deployed on Railway:
- **Production URL**: https://backend-production-d218.up.railway.app
- **API Base URL**: https://backend-production-d218.up.railway.app/api/v1

### Local Development

To start the backend locally for development:

```bash
cd backend
npm install
npm run dev
```

Run tests with `npm test`.

### Deployment

The backend automatically deploys to Railway when changes are pushed to the main branch. See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

See the [SETUP.md](docs/SETUP.md) file for detailed setup instructions.

## License

See [LICENSE](LICENSE) file for details.
