# ✅ 2DO by DB

A powerful, minimalist To-Do List app built with Flutter that helps you stay organized and in control of your day. This app supports priority-based task sorting, category filtering, deadlines, light/dark themes, and persistent storage.

---

## 🛠 Features

- ✏️ Add, delete, and mark tasks as completed  
- 🎯 Prioritize tasks as **High**, **Medium**, or **Low**  
- 📁 Categorize tasks: *Personal*, *Household*, *Work*, *Academic*  
- 🗓️ Optional **Deadline** picker for tasks  
- 🔍 Filter tasks by **priority** and **category**  
- 🌗 Toggle between **Light** and **Dark Mode**  
- 💾 Persistent storage using `SharedPreferences`  
- ❗ Error handling for duplicate tasks (based on name + priority + category + deadline)  
- 📱 Responsive UI designed for mobile  

---


## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code with Flutter extension
- A connected device or emulator

### Run the App

```bash
git clone https://github.com/your-username/todo_app.git
cd todo_app
flutter pub get
flutter run
```

---

## 📦 Dependencies

- [`shared_preferences`](https://pub.dev/packages/shared_preferences) – for saving tasks locally  
- [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) – for notification integration (planned/future)  
- [`cupertino_icons`](https://pub.dev/packages/cupertino_icons)  

---

## 📁 Project Structure

```
lib/
├── main.dart         # Main entry point with UI and logic
└── task_model.dart   # Task model with JSON serialization
```

---

## 🧠 Ideas for Future Updates

- 🔔 Task reminder notifications  
- 📅 Calendar integration  
- 🧭 Daily/Weekly Planner view  
- 🗂️ Custom category creation  
- ☁️ Cloud sync (Firebase)  

---

## 👨‍💻 Developed By

**Debagyan Bordoloi**

---

## 📃 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
