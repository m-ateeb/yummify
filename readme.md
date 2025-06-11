# 🍽️ Cooking Companion App

A full-stack cooking assistant app designed to help users explore, create, and share recipes, track meals and calories, and get personalized recipe suggestions based on available ingredients. Built using **Flutter (frontend)**, **Node.js (backend)**, and **Firebase** for notifications and cloud functions.

---

## 📱 App Modules

This app is divided into **four major modules** along with advanced features for a complete cooking experience:

### 1. **Recipe Explorer**
- Browse a collection of public recipes.
- Filter recipes by category, ingredients, or popularity.

### 2. **Recipe Creator**
- Create and publish your own recipes.
- Choose to make them **public** or keep them **private**.

### 3. **Community**
- View, comment on, and like others' public recipes.
- Bookmark favorite recipes for later.

### 4. **Meal & Calorie Planner**
- Plan daily or weekly meals.
- Track calorie intake per recipe or per day.

### 5. **Ingredient-Based Suggestions**
- Enter ingredients you have at home.
- Get suggested recipes based on what’s available in your kitchen.

---

## 🛠️ Tech Stack

| Layer      | Technology       |
|------------|------------------|
| Frontend   | Flutter           |
| Backend    | Firebase |
| Notifications | Firebase Cloud Messaging |
| Hosting/Auth/DB | Firebase (Optional Modules) |

---

## 🚀 Getting Started

### 📦 Prerequisites

- Flutter SDK
- Node.js (LTS version recommended)
- Firebase CLI (optional for emulators or deployments)

### 🔧 Setup Instructions

```bash
# Clone the repository
git clone https://github.com/yourusername/cooking-app.git
cd cooking-app

# Set up frontend
cd frontend
flutter pub get

# Set up backend
cd ../backend
npm install

# Optional: Run Firebase Emulator
firebase emulators:start
