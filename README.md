# Healthlog

Keep track of your medical test records for monitoring your health and progress. I work on this at my free time.

The project is currently in a beta testing phase. I have used it for a while with multiple users and works well enough for daily use, but if you encounter any bugs please report them. I'll try my best to fix them.

## Screenshots

### Home Screen - List of users

![List of Users](https://i.imgur.com/bsMoS6G.png)

### User Profile - List of recordings for user

![List of recordings for user](https://i.imgur.com/dlRo8VG.png)

### A popup to show the results from the list

![A popup to show the results from the list](https://i.imgur.com/Iv9lJCt.jpeg)

### Bottom popup for easy record addition

![Bottom popup for easy addition](https://i.imgur.com/VY0XTnj.png)

### Record Graph - Graph showing the recording

![Graph showing the recording](https://i.imgur.com/qMAh2Lk.png)

### Setting Screen - Just the basics for now

![Settings screen for the app](https://i.imgur.com/gQc7mAk.png)


## Build

# Install Flutter on your respective OS

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