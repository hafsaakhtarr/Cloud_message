# Cloud Messaging App

A Flutter app that receives Firebase Cloud Messaging notifications and updates the UI based on payload data.
Demonstrates FCM integration with foreground/background message handling and dynamic image loading from custom data.

## Features

- Receive FCM notifications in foreground, background, and terminated states
- Request and display FCM device token for Firebase Console testing
- Extract notification title and display in UI status card
- Dynamically load and display images based on custom payload data

## How UI Changes on Message

When a message arrives, the UI updates automatically via `setState()`:

- **Status text**: Extracted from `message.notification?.title`
- **Image path**: Built from `message.data['asset']` → `'assets/images/{asset}.jpeg'`
- **Example**: Sending `asset='clouds'` displays `clouds.jpeg` from `assets/images/` folder

```

