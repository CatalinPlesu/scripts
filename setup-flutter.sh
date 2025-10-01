#!/bin/bash

sudo snap install flutter --classic
sudo snap alias flutter.dart dart
sudo snap install android-studio --classic
# go through wizard
# also install sdk comand line tools
android-studio
flutter config --android-sdk="$HOME/Android/Sdk"
flutter config --android-studio-dir="/snap/android-studio/current/bin/"
flutter doctor --android-licenses
