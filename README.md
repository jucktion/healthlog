# Healthlog

Keep track of your medical test records for monitoring your health and progress. I work on this at my free time.

The project is currently in a beta testing phase. I have used it for a while with multiple users and works well enough for daily use, but if you encounter any bugs please report them. I'll try my best to fix them.

## Features
- Allows health test reading data storage for multiple users
- Blood Pressure, Blood Sugar/Glucose, Cholesterol, Renal Function Test, Notes can be saved
- Acceptable range for Glucose/Sugar reading configurable via slider in settings
- Graph view of last 30 readings (for now)
- No Ads and Tracking (Has no Internet permission)
- Limited dependencies for reduced binary size. Under 8MB for now.
- Tested on Android 6 and up (although only a few devices)
- Can enable data file backup on every entry to prevent data loss
- Free and Open source


### Drawbacks
- Data is not encrypted on storage. Local SQLite database stores data in json format
- Is a hobby project for someone still learning flutter
- Currently in beta testing state. Expect bugs and UI/UX issues
- Some acceptable ranges for some readings aren't configurable yet
- Some keyboards cannot create newline on notes

## Screenshots

### Home Screen - List of users

![List of Users](https://i.imgur.com/bsMoS6G.png)

### User Profile - List of recordings for user

![List of recordings for user](https://i.imgur.com/dlRo8VG.png)

### A popup to show the results from the list

![A popup to show the results from the list](https://i.imgur.com/iOvhhv3.png)

### Bottom popup for easy record addition

![Bottom popup for easy addition](https://i.imgur.com/VY0XTnj.png)

### Record Graph - Graph showing the recording

![Graph showing the recording](https://i.imgur.com/qMAh2Lk.png)

### Setting Screen - Just the basics for now

![Settings screen for the app](https://i.imgur.com/gQc7mAk.png)


## Build

### Install Flutter on your respective OS

```
Flutter Tested: 3.27.1
```

### Clone the git repo
```
git clone https://github.com/jucktion/healthlog
```

### Go into the folder and get dependencies
```
cd healthlog
```
```
flutter pub get
```

### Build app for your device platform

#### 64 Bit
```
flutter build apk --target-platform android-arm64
```

#### 32 Bit
```
flutter build apk --target-platform android-arm
```

#### Universal
```
flutter build apk
```

## Support

You can support the project by reporting bugs and issues you encounter. If you want to offer any other ways of help, it's appreciated as well

https://liberapay.com/jucktion