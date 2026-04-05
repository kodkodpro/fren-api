# Fren API

This app servers as an API server for the Fren iOS app.

Main goals of this app are:
- Act as a reverse proxy for OpenAI API, so that we can add additional features like authorization, caching, rate limiting, etc.
- Verify subscriptions and entitlements for the iOS app, so that we can restrict access to certain features based on the user's subscription status.
- Return dynamic app configuration to the iOS app, so that we can enable/disable features without requiring an app update.
