<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//Logo.png">
  <img alt="FinFlow Logo" src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//Logo.png" width="100">
</picture>

<p align="center">
  <img src="https://github.com/OmarAfifi-CSE/FinFlow/blob/master/assets/Platforms_Mockups.gif" alt="FinFlow App Demo" width="900"/>
</p>
</div>

<div align="center">

**Spend Smarter, Save More. Your Personal Finance Companion, Everywhere.**

*A sleek, cross-platform finance tracker built with Flutter and Supabase that runs seamlessly on Mobile, Web, and Windows.*

</div>

<div align="center">

[![Platform](https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.io)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

FinFlow is a modern, intuitive, and secure application designed to help you take full control of your financial life. Track your income and expenses with ease, categorize your spending, and gain clear insights into your financial habits. Built with a single Flutter codebase, FinFlow delivers a consistent and beautiful native experience across all your devices.

## 📸 A Showcase of FinFlow

FinFlow is a full-featured application designed for a seamless user experience. Here is a gallery showcasing the core screens and functionalities.

<table width="100%">
<tr>
    <td width="50%" valign="top">
      <h4 align="center">Welcome Aboard</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//1-%20Onboarding_Screenshot.png?text=Onboarding+Screen" alt="Onboarding" width="300">
      </p>
      <p>A simple and beautiful onboarding experience to welcome users and highlight the app's value proposition from the very first launch.</p>
    </td>
    <td width="50%" valign="top">
      <h4 align="center">Secure Authentication</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//2-%20Signin_Screenshot.png?text=Sign-In+Screen" alt="Sign-In" width="300">
      </p>
      <p>Robust and secure user sign-up and sign-in powered by Supabase Auth. Your financial data is protected from the start.</p>
    </td>
  </tr>

<tr>
    <td width="50%" valign="top">
      <h4 align="center">Financial Dashboard</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//3-%20Dashboard_Screenshot.png?text=Dashboard" alt="Dashboard" width="300">
      </p>
      <p>The central hub gives you an instant snapshot of your balance, income, and expenses. A live list of recent transactions keeps you up-to-date.</p>
    </td>
    <td width="50%" valign="top">
      <h4 align="center">Effortless Transaction Entry</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//4-%20Add%20Transaction_Screenshot.png?text=Add+Transaction" alt="Add Transaction" width="300">
      </p>
      <p>An intuitive bottom-sheet interface makes adding income or expenses incredibly fast. Categorize and tag on the fly to maintain perfect records.</p>
    </td>
  </tr>

<tr>
    <td width="50%" valign="top">
      <h4 align="center">Custom Categories & Tags</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//5-%20Categories_Screenshot.png?text=Category+Management" alt="Category Management" width="300">
      </p>
      <p>Take full control by creating and managing your own spending categories and tags. Tailor the app to fit your unique financial life.</p>
    </td>
    <td width="50%" valign="top">
      <h4 align="center">User Profile & Security</h4>
      <p align="center">
        <img src="https://fpeynvsshkecovrkuwfx.supabase.co/storage/v1/object/public/assets//6-%20Profile_Screenshot.png?text=Profile+Page" alt="Profile Page" width="300">
      </p>
      <p>View your account information and securely update your password. User control and security are at the core of FinFlow.</p>
    </td>
  </tr>
</table>

---

## ✨ Features

FinFlow is packed with features to make financial management simple and effective.

-   **Cross-Platform:** Single codebase for **Android, iOS, Web, and Windows**.
-   **Secure Authentication:** Safe sign-up and sign-in powered by Supabase Auth, including secure password reset.
-   **Dashboard Overview:** Get an instant snapshot of your total balance, total income, and total expenses.
-   **Transaction Management:** Effortlessly add, edit, or delete income and expense records.
-   **Smart Categorization:** Assign categories to your transactions for better analysis (e.g., Food, Transport, Bills).
-   **Custom Tags:** Add custom tags for better organization of your spending (e.g., #Work, #Vacation).
-   **Dynamic Filtering:** View your transaction history by date or grouped by category.
-   **Category & Tag Management:** A dedicated space to create, view, and delete your custom categories and tags.
-   **User Profile:** View your account details and securely change your password.
-   **Persistent Data:** All your data is securely stored and synced across your devices using the Supabase database.
-   **Sleek & Responsive UI:** A clean, modern, and user-friendly interface that looks great on any screen size.

---

## 🚀 Technologies Used

This project leverages a modern, powerful tech stack to deliver a high-quality experience.

| Technology | Description |
| :--- | :--- |
| **Flutter** | Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. |
| **Supabase** | The open-source Firebase alternative. Used for Database, Authentication, and Auto-generated APIs. |
| **Provider** | A robust and simple state management solution for Flutter. |
| **Dart** | The programming language used to build the application. |

---

## 📋 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   You will need a free [Supabase](https://supabase.com) account.

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/OmarAfifi-CSE/FinFlow.git
    cd FinFlow
    ```

2.  **Set up your Supabase Project:**
    -   Go to [Supabase](https://supabase.com) and create a new project.
    -   Inside your project, navigate to the **SQL Editor** and run the schema setup script to create the necessary tables. *(You should create a `schema.sql` file and add it to your repo for others to use).*
    -   Enable **Row Level Security (RLS)** on your tables for data privacy.

3.  **Configure Environment Variables:**
    -   In the root of the project, create a file named `.env`.
    -   Copy the contents of `.env.example` (if you created one) or use the template below.
    -   Go to your Supabase project's **Project Settings > API** to find your keys.
    -   Add your Supabase URL and Anon Key to the `.env` file:
        ```env
        SUPABASE_URL=YOUR_SUPABASE_URL
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
        ```

4.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

5.  **Run the application:**
    ```sh
    flutter run
    ```
    You can choose the target device (e.g., Chrome for web, a mobile emulator, or Windows).

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">

*Created with ❤️ to make finance tracking accessible to everyone.*

</div>
