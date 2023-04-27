# Karoo Collab
A [Flutter](https://flutter.dev/) application intended to be deployed on the [Hammerhead Karoo 2](https://www.hammerhead.io/pages/karoo2). The Karoo 2 runs a modified version of Android 8.0, so the SDK target for the project is Android SDK level 26.
## Files
### [lib/main.dart](./lib/main.dart)
Entry point into the application. Does two main things: initialize the `UploadManager`, and put the main app instead of a widget that will allow the app to persist while minimized. This was done while the Karoo SDK was still being used.
### [lib/bluetooth_manager.dart](./lib/bluetooth_manager.dart)
Handles the connections between different Karoo or smart devices. Currently the app has only been tested between two different Karoo devices, but assuming the formatting of the string messages is consistent between apps, there would be no problem communicating between them.
### [lib/monitor_sensor.dart](./lib/monitor_sensor.dart)
Widget used on the sensors page to actually search for and connect to the apps. Most of the UI elements related to the sensor page are stored here as well.
### [lib/rider_data.dart](./lib/rider_data.dart)
Used to store information about the partner that needs to persist between different screens. Currently used by `BluetoothManager` to store information about the partner's name, max HR, and FTP and by `MonitorConnect` to store information about the partner's device.
### [lib/logging/exercise_logger.dart](./lib/logging/exercise_logger.dart)
The main file responsible for logging in the app. Initialized at app startup in `lib/main.dart`. Logs are saved to file at the end of a workout.
### [lib/logging/logger_constants.dart](./lib/logging/logger_constants.dart)
Holds constant values important for logging. Important variables that will need to be updated in the future are those beginning with `database`, as the API key and endpoint will need to be updated to work with the future database. All key and expected key value pairs should be retrieved in this class. Important enums such as `DeviceType` and `WorkoutType` are stored here.
### [lib/logging/upload_manager.dart](lib/logging/upload_manager.dart)
Handles the uploading of the log files saved by `ExerciseLogger`. When the app is initialized, it initialize the UploadManager
### [lib/logging/workout.dart](lib/logging/workout.dart)
Stores the workout events for `ExerciseLogger`. Workout events include heart rate and power updates. Should not be called directly, is only handled by `ExerciseLogger`.
### [lib/pages/home_page.dart](lib/pages/home_page.dart)
This is the page users see when opening the app, containing primarily UI elements. It also creates the initial instance of the logger that gets sent to analytics once a workout is ended.
### [lib/pages/paired_workout.dart](lib/pages/paired_workout.dart)
This page is for users who intend to exercise with partners. It directs users to have one person as host, and others to join a host.
### [lib/pages/host_page.dart](lib/pages/host_page.dart)
The host page asks the user for bluetooth permissions if they haven’t been granted. This page also has functionality to make itself discoverable for partners nearby. It takes values from the sensor to update the users metrics, which it then sends to paired devices. The metrics supported are heart rate, and power. It does so by broadcasting its values, and receiving the partner values through the bluetooth manager
### [lib/pages/join_page.dart](lib/pages/join_page.dart)
Just like the host page, the join page asks the user for bluetooth permissions if they haven’t been granted. This page also has functionality to search for partners nearby and lists them if they are karoos. It takes values from the sensor to update the users metrics, which it then sends to paired devices. The metrics supported are heart rate, and power. It does so by broadcasting its values, and receiving the partner values through the bluetooth manager
### [lib/pages/workout_page.dart](lib/pages/workout_page.dart)
This page works to give users a way to view their sensor data, as well as other metrics such as a workout timer, the distance traveled, and speed while in a session with partners. It pulls data from the settings page to show the user's name, and includes functionality to switch units from miles and miles per hour to kilometers and kilometers per hour. It has functionality to play, pause, and end a workout. It also receives a paired partner’s metrics data, as well as their name, and displays them accordingly. Ending a workout will result in sending a log to analytics
### [lib/pages/solo_workout.dart](lib/pages/solo_workout.dart)
This page works to give users a way to view their sensor data, as well as other metrics such as a workout timer, the distance traveled, and speed while in a session without partners. It pulls data from the settings page to show the user's name, and includes functionality to switch units from miles and miles per hour to kilometers and kilometers per hour. Just like the paired workout screen, it has functionality to play, pause, and end a workout. Ending a workout will result in sending a log to analytics
### [lib/pages/sensors_page.dart](lib/pages/sensors_page.dart)
The sensors page asks the user for permission, and if it has permissions, starts scanning for nearby sensors. It displays any sensors it finds so that the user can connect to them, showing a toast notification with the status of the connection after it finishes or fails
### [lib/pages/settings_page.dart](lib/pages/settings_page.dart)
The settings page allows users to input and update their personal information such as name, email, maximum heart rate, and functional threshold power (FTP) values. It uses shared preferences to save and retrieve data from the device's local storage.

## Testing/Release build instructions
* Get dart SDK
* Get flutter SDK

The instructions below were tested in VSCode rather than Android studio
To build and install the debug version of the app, run command in project directory:
```
flutter run
```
To quick test code changes while in debug mode (hot reload), simply press *r* while the terminal is running the app in dart after saving the code changes.

Disconnecting from the device does not keep the changes that were made from hot reloads debug app, you should run *flutter run* again to see the code changes saved. 

To build and install debug version of the app on two devices at the same time, find the device ID using:
```
flutter devices
```
Which should give something like: KAROO20ALC030802155

After this, split the terminal and run two different devices by running this command on both:
```
flutter run -d <device id> 
```
To build and install the release version of the app, run command in project directory:
```
flutter build apk
flutter install 
```
*flutter install* should install app-release.apk. If the built apk is not named app-release.apk, rename it to "app-release.apk" then try running again

## Future Work
* Map integration in the workout screen.
* Sensor pairing connection speed issue. Sometimes, certain sensors can take up to several minutes to successfully pair. So far this issue has only occurred on Karoo devices, so it may be a hardware related issue. Ideally, it should only take a few seconds to connect to each sensor.
* Sensors page has a visual bug where the connection indicator shows on all sensors that have been found, rather than the sensor that was tapped on and is in the process of pairing. Ideally, it should only show the connection animation for one device at a time.
* Sensors page needs a possible rework. Instead of choosing to pair multiple sensors at a time, it should only allow the user to select one sensor to pair, show a popup saying to wait until the sensor has successfully paired, then after it pairs or fails to pair, it should ask if the user wants to pair another device.
* A splash screen could be added while the app loads. When the app is pressed, it can take upto a full second to load, during which the screen is completely black. Ideally, a splash screen showing the app logo would show during this time instead.
* Fit file logging. Right now, the logs created are in a custom `json` file format. A `.fit` file would allow the user to upload their workout to their preferred fitness tracking app of choice, allowing them to track their individual progress. It would not track the partner's statistics. There exists a Flutter package for this called [fit_tool](https://pub.dev/packages/fit_tool).
* Guided tutorial introducing users to the app. 
* Battery consumption right now is relatively high. This might be more related to the Karoo itself having poor battery life, some things can be optimized to improve battery life. Firstly, the sensor/GPS polling and bluetooth transmission rates could be adjusted to occur slightly less frequently. Instead of sending each metric as a separate bluetooth broadcast, they could be queued then combined into one broadcast to transmit less frequently as well. 
