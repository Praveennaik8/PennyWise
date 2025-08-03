# PennyWise

## A Smart Expense Tracking & Financial Management App

**Languages: English (this file), [中文](README.zh-cn.md).** , [KR](README.ko-kr.md)

## Introduction

PennyWise is a comprehensive expense tracking and financial management application built with Flutter and GetX. The app helps users track their daily expenses, manage bank cards, analyze spending patterns, and maintain better financial health. Built with modern Flutter architecture and GetX state management, PennyWise provides a smooth, responsive user experience across all platforms.

## Technology & Project Introduction

PennyWise is built with Flutter 3.x and uses GetX for state management, providing a robust and scalable architecture for expense tracking and financial management. The project features a clean folder structure, customizable themes, API integration, efficient state management, and comprehensive routing. Technologies used include but are not limited to [Flutter](https://flutter.cn/), [Dart](https://dart.dev/), [GetX](https://pub.dev/packages/get), and more.

<p align='center'>
    <img src="assets/screenshot/2.jpg" width="187" heght="333" />
    <img src="assets/screenshot/3.jpg" width="187" heght="333" />
    <img src="assets/screenshot/4.jpg" width="187" heght="333" />
    <img src="assets/screenshot/5.jpg" width="187" heght="333" />
    <img src="assets/screenshot/6.jpg" width="187" heght="333" />
    <img src="assets/screenshot/7.jpg" width="187" heght="333" />
    <img src="assets/screenshot/8.jpg" width="187" heght="333" />
    <img src="assets/screenshot/9.jpg" width="187" heght="333" />
    <img src="assets/screenshot/chat.gif" width="237px" heght="416px" />
</p>

## Installation & Use

**Step 1:**

Clone this project to your local machine:

```
git clone https://github.com/your-username/penny_wise.git
```

**Step 2:**

Open the project folder with VS Code and execute the following command to install the dependency package:

```
flutter pub get
```

**Step 3:**

Open the main.dart file in the lib folder, F5 or Ctrl + F5 to run the project, and then you can start developing and debugging.

## Folder structure

The following is the project folder structure (only the folders under lib are introduced)

```
lib/
|- api - Global Restful api requests, including interceptors, etc.
   |- interceptors - Interceptors, including auth, request, and response interceptors.
   |- api.dart - Restful api export file.
|- lang - Internationalization, including translation files, translation service files, etc.
   |- lang.dart - Language export file.
|- models - Various structured entity classes, divided into request and response entities.
   |- models.dart - Entity class export file.
|- modules - Business module folder.
   |- auth - Login & Registration Module.
   |- home - Home module.
   |- splash - Splash module.
   |- modules.dart - Module export file.
|- routes - Routing module.
   |- app_pages.dart - Routing page configuration.
   |- app_routes.dart - Route names.
   |- routes.dart - Route export file.
|- Shared - Global shared folders, including static variables, global services, utils, global Widgets, etc.
   |- shared.dart - Global shared export file.
|- theme - Theme folder.
|- app_bindings.dart - Services started before the app runs, such as Restful api.
|- di.dart - Global dependency injection objects, such as SharedPreferences, etc.
|- main.dart - Main entry.
```


