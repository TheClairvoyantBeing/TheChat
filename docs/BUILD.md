# Build Guide for TheChat

This guide explains how to build the application for distribution (Release mode).

## 1. Windows Build (Desktop)

To create a standalone `.exe` file that you can share or run without the terminal:

0.  **Enable Developer Mode**:
    - Go to Settings -> Privacy & Security -> For Developers (or run `start ms-settings:developers`).
    - Turn **On** "Developer Mode". This is required for Flutter to create symlinks for plugins.

1.  Open your terminal in the project folder.
2.  Run the build command:
    ```powershell
    C:\Users\evion\tools\flutter\bin\flutter.bat build windows
    ```
3.  **Output Location**:
    The built files will be in:
    `build\windows\x64\runner\Release\`

    Look for `the_chat.exe`. You need to COPY the entire `Release` folder to share it, as it contains necessary DLLs and the `data` folder.

## 2. Android Build (Mobile)

To create an APK file that you can install on an Android phone:

1.  Open your terminal.
2.  Run the build command:
    ```powershell
    C:\Users\evion\tools\flutter\bin\flutter.bat build apk
    ```
3.  **Output Location**:
    The APK will be in:
    `build\app\outputs\flutter-apk\app-release.apk`

    Transfer this file to your phone and install it (you may need to enable "Install from Unknown Sources").

## 3. Web Build (Optional)

If you want to host it as a website:

1.  Run:
    ```powershell
    C:\Users\evion\tools\flutter\bin\flutter.bat build web
    ```
2.  **Output Location**:
    `build\web\`

---

## Troubleshooting

- **Clean Build**: If you see weird errors, try cleaning the project cache first:
  ```powershell
  C:\Users\evion\tools\flutter\bin\flutter.bat clean
  C:\Users\evion\tools\flutter\bin\flutter.bat pub get
  ```
