# HealthLog

Keep track of your medical test records to monitor your progress and become healthier.

The project is currently in a beta testing phase. Used it for multiple users and works well enough for daily use, but if you encounter any bugs please report them. I'll try my best to fix them.

## Download
[<img src="https://github.com/machiav3lli/oandbackupx/blob/034b226cea5c1b30eb4f6a6f313e4dadcbb0ece4/badge_github.png" alt="Get HealthLog on GitHub" height="82"
align="center">](https://github.com/jucktion/healthlog/releases/latest)
[<img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png" alt="Get HealthLog on IzzyOnDroid" height="80"
align="center">](https://apt.izzysoft.de/packages/com.jucktion.healthlog)
[<img src="https://github.com/ImranR98/Obtainium/blob/main/assets/graphics/badge_obtainium.png"
alt="Get HealthLog on Obtainium"
height="55"
align="center">](https://apps.obtainium.imranr.dev/redirect?r=obtainium://add/https://github.com/jucktion/healthlog/)

## Features
- Allows health test reading data storage for multiple users
- Blood Pressure, Blood Sugar/Glucose, Cholesterol, Renal Function Test, Notes can be saved
- Acceptable range for Blood Glucose (Sugar)/Cholesterol/RFT reading configurable in settings
- Graph view of last 30 readings (for now)
- No Ads and Tracking (Has no Internet permission)
- Limited dependencies for reduced binary size. Currently under 10MB
- Tested on Android 6 and up (although only a few devices)
- Can enable data file backup on every entry to prevent data loss
- Free and Open Source


### Drawbacks
- Data is not encrypted on storage. Local SQLite database stores data in json format
- Currently in beta testing state. (Report bugs and UI/UX issues)
- Some (old)keyboards cannot create newline on notes

## Screenshots

### Home Screen - List of users

![List of Users](https://i.imgur.com/bsMoS6G.png)

### User Profile - List of recordings for user

![List of recordings for user](https://i.imgur.com/dlRo8VG.png)

### Bottom popup for easy record addition

![Bottom popup for easy addition](https://i.imgur.com/VY0XTnj.png)

### A popup to show the results from the list

![A popup to show the results from the list](https://i.imgur.com/iOvhhv3.png)

### Record Graph - Graph showing the history

![Graph showing the recording](https://i.imgur.com/qMAh2Lk.png)

### Setting Screen - Just the basics for now

![Settings screen for the app](https://i.imgur.com/gQc7mAk.png)


## Build

### Install Flutter on your respective OS

```
https://docs.flutter.dev/get-started/install
```

Tested with Flutter Version:
```
3.29.0
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