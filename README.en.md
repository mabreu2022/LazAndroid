# LazDroid-Deploy — IDE Plugin & Android Deployment Pipeline for Lazarus

<p align="center">
  <a href="README.md">🇧🇷 Português</a> &nbsp;|&nbsp; <b>🇺🇸 English</b>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)

**LazDroid-Deploy** is a professional automation suite (Open Tools Package) for **Lazarus IDE / Free Pascal (FPC)** that provides a *"1-Click Deploy & Run (Ctrl+Shift+F9)"* experience with support for real **LCL Visual Forms (CustomDrawn Android)**, identical to the Delphi and Android Studio ecosystems.

---

## 🎯 Key Features

- ⚡ **1-Click IDE Deployment**: Trigger compilation, packaging, installation, and execution with a single shortcut (`Ctrl+Shift+F9`) or via the `Run` menu.
- 🎯 **Delphi-Style Target Manager**: Dockable window featuring **automatic USB phone detection (Plug & Play)**, dynamic display of connected devices under the `Target` node, comprehensive hardware/OS inspection (battery, screen resolution, ABI, Android version), and direct deployment to the active target!
- 🎨 **Native On-Screen LCL Components**: Design user interfaces using the **Lazarus Form Designer** with `TForm`, `TButton`, `TLabel`, `TPanel`, `TPageControl`, `TEdit`, `TCheckBox`, and more, rendered via LCL CustomDrawn (`customdrawn_android`).
- 📁 **1-Click New Project Wizard**: Registered under `File -> New... -> Android Application (LazDroid)`, pre-configuring JNI library templates, LCLWidgetType, compiler flags, and the initial form.
- 📱 **Smart ABI & Device Detection**: Scans USB-connected devices (`adb devices -l`) and automatically selects the appropriate target architecture (`arm64-v8a` or `armeabi-v7a`).
- 🔧 **High-Performance Native FPC Compilation**: Drives the Free Pascal cross-compiler (`ppcrossa64`) generating direct ARM64 machine code (`liblazapp.so`), matching native C/C++ speed and efficiency.
- 🗄️ **Embedded SQLite Database**: Built-in support with pre-packaged native `libsqlite.so`, enabling lightning-fast offline SQLite operations out of the box.
- 📦 **Robust Android Scaffold**: Lightweight Java host (`com.pascal.lclproject.LCLActivity`) managing lifecycle, fullscreen mode, display orientation, DPI scaling, and touch event dispatching.
- 💬 **Real-Time Log Streaming**: Captures build `stdout`/`stderr` and streams Logcat output (`__android_log_print` / `tag: lclapp`) directly to Lazarus' **Messages** window.
- ⚙️ **Integrated Settings Panel**: SDK, NDK, ADB, JDK, and FPC path manager embedded into `Tools -> Options` with one-click automatic detection.

---

## 📂 Project Structure

```
LazAndroid/
├── package/                                # Lazarus Open Tools Package (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Main package to install into the IDE
│   ├── LazDroidDeploy_Reg.pas             # IDE menu, shortcut, and action registration
│   ├── LazDroidConfig.pas                 # Configuration persistence (XML)
│   ├── LazDroidConfigFrame.pas/.lfm       # Configuration frame in Tools -> Options
│   ├── LazDroidDeviceManager.pas          # ADB device detection and status inspection
│   ├── LazDroidDeviceSelectDlg.pas/.lfm   # USB device modal selection dialog
│   ├── LazDroidProcessRunner.pas          # Async multithreaded process runner with pipes
│   ├── LazDroidProjectDescriptor.pas      # Android New Project Wizard in the IDE
│   └── LazDroidPipeline.pas               # Master 6-stage build orchestrator
│
├── scaffold/                              # Ready-to-package Android template
│   ├── build.gradle                       # Root Gradle build script
│   ├── gradlew.bat                        # Gradle Wrapper for Windows
│   └── app/                               # Main Android application module
│       ├── build.gradle                   # SDK settings (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Configured for com.pascal.lclproject.LCLActivity
│           ├── java/.../LCLActivity.java  # Java Host: LCL Canvas, Touch, JNI bridge
│           └── jniLibs/                   # Injected compiled native shared libraries
│               └── arm64-v8a/             # liblazapp.so and libsqlite.so (AArch64)
│
├── demo/                                  # Full Sales Force Application (SQLite)
│   ├── LazAndroidDemo.lpr                 # JNI entry point
│   ├── FormLogin.pas/.lfm                 # LCL Login Form
│   ├── FormVendas.pas/.lfm                # LCL Dashboard and Sales Form
│   ├── SalesDatabase.pas                  # SQLite connection and queries
│   └── vendas.db                          # Sample SQLite database
│
├── demo2/                                 # Minimalist "Hello World" LCL Example
│   ├── project1.lpr                       # LCL initialization
│   └── unit1.pas/.lfm                     # TForm1 with TButton and modal dialog
│
├── demo3/                                 # Advanced Multi-Tab Demo (CRUD Mock)
│   ├── demo3.lpr                          # LCL initialization with Activity
│   └── unit1.pas/.lfm                     # TPageControl, TTabSheet, TPanel, TEdit, TLabel
│
├── demo4/                                 # LazDroid Mobile Palette Showcase
│   ├── demo4.lpr                          # JNI entry point
│   └── unit1.pas/.lfm                     # AppBar, BottomNav, Card, Badge, Edit, Button, ListView
│
├── demo5/                                 # Complete Commercial App (Login + SQLite + BottomNav)
│   ├── project1.lpr                       # JNI entry point with Activity
│   ├── unit1.pas/.lfm                     # Login screen authenticating against SQLite
│   ├── unit3.pas/.lfm                     # Main screen with BottomNav (Products, Orders, Clients, Settings)
│   ├── unit4.pas/.lfm                     # DataModule with TSQLite3Connection and queries
│   ├── database/app.db                    # SQLite database with 5 tables and sample data
│   └── imagens/                           # Catalog of PNG images and icons
│
├── tools/                                 # Utilities, SQLite binaries, scripts, and installer
└── docs/                                  # Technical Documentation and Guides
    ├── ARCHITECTURE.md                    # Detailed architecture and Mermaid diagrams
    ├── INSTALL_GUIDE.md                   # Step-by-step installation and usage guide
    └── manual_componentes_lazdroid.html   # Interactive Mobile Component Palette Manual
```

---

## 📱 Complete "LazDroid" Mobile Component Suite (30 Components)

**LazDroid** delivers a comprehensive library of **30 touch-first mobile components**, engineered specifically for Android touchscreens (Material Design & iOS look-and-feel), breaking past the limitations of traditional desktop controls in Lazarus.

All components are instantly available in the **`LazDroid`** palette within the Form Designer:

### 🧭 Navigation & Layout
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Mobile top app bar with title, dynamic subtitle, Back button (`OnBackClick`), and action buttons (`OnActionClick`). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Touch bottom navigation bar with automatic vector icons, numeric badges, and `OnTabSelected` event. |
| **`TLazDroidBottomSheet`** | 📥 Modal Drawer | Bottom sliding panel (modal drawer) with grab handle, ideal for advanced filters, share options, and action sheets. |
| **`TLazDroidSpeedDial`** | ⚡ Floating Menu | Expandable Floating Action Button that unfolds into multiple circular action buttons with touch icon rotation. |
| **`TLazDroidLayout`** | 📐 Responsive Box | Responsive screen container supporting smart padding, rounded corners, and smooth vertical scrolling. |

### ✏️ Data Input & Forms
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidEdit`** | ✏️ Input Field | Modern text field with placeholder, rounded corners, and **automatic native Android virtual keyboard invocation**. |
| **`TLazDroidSearchBar`** | 🔍 Search Bar | Search bar featuring magnifying glass icon, quick-clear button (`X`), pill shape, and live typing event (`OnSearch`). |
| **`TLazDroidOtpBox`** | 🔢 PIN / OTP Input | Verification code input (4 to 6-digit PIN/SMS) in separate boxes with automatic focus advancement between digits. |
| **`TLazDroidDatePicker`** | 📅 Date Picker | Modern mobile date picker with a touch-friendly popup calendar and regional formatting. |
| **`TLazDroidTimePicker`** | ⏰ Time Picker | Hour and minute selector with 12h/24h toggle and touch carousel controls. |
| **`TLazDroidCheckBox`** | ☑️ CheckBox | Enlarged touch checkbox with animated fill, checkmark icon, and descriptive label. |
| **`TLazDroidSwitch`** | 🎚️ Toggle Switch | Modern iOS/Material-style on/off toggle switch with smooth animated transitions and custom active/inactive colors. |
| **`TLazDroidRadioGroup`** | 🔘 Radio Group | Mutually exclusive option group with vertical/horizontal layouts and comfortable touch targets. |
| **`TLazDroidSegmentedControl`** | 📑 Segments | Horizontal segmented selector with sliding indicator, ideal for quick view switching or status filters. |
| **`TLazDroidChipGroup`** | 🏷️ Filter Chips | Dynamic collection of tags/chips with single or multi-selection for fast categorization and catalog filtering. |

### 📋 Lists & Data Display
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidListView`** | 📋 Card List | Touch record list with title, subtitle, badges, 32-bit images, right-aligned currency amounts, and **drag-to-scroll**. |
| **`TLazDroidCard`** | 🃏 Surface Card | Card container with elevation, soft shadow, header, and rounded corners for grouping content blocks. |
| **`TLazDroidMetricCard`** | 📊 KPI Card | Specialized card for sales dashboards and KPI summaries featuring numeric value, label, and percentage variance badge. |
| **`TLazDroidSectionHeader`** | 📑 Section Header | Visual section divider with emphasized title and right-aligned action button (*e.g., "See all"*). |
| **`TLazDroidImageList`** | 🖼️ Image Manager | Mobile icon and photo manager with full 32-bit alpha transparency (PNG) support without quality degradation. |

### 🔘 Actions, Buttons & Feedback
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidButton`** | 🔘 Action Button | Button with a minimum 48px touch target, semantic styles (*Primary, Success, Danger, Outline*), and vector icons. |
| **`TLazDroidFAB`** | ➕ Action Button | Elevated circular Floating Action Button with drop shadow, ideal for the primary screen action (*e.g., New Order*). |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Semantic pill badge for statuses (*Pending, Completed, Cancelled*) or notification counters (*e.g., 3*). |
| **`TLazDroidProgressBar`** | ⏳ Progress Bar | Progress bar with smooth animations, centered percentage label, and state-specific colors. |
| **`TLazDroidSlider`** | 🎚️ Value Slider | Touch slider control with floating numeric value callout for continuous adjustments of quantities, volumes, or price ranges. |
| **`TLazDroidActivityIndicator`** | 🔄 Spinner | Asynchronous loading indicator with a modern spinning ring, ideal for SQLite queries or network activity. |

### 📱 Special Mobile Features
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidRatingBar`** | ⭐ Star Rating | Touch star rating (1 to 5 stars) with half-star support and direct touch selection. |
| **`TLazDroidKeypad`** | ⌨️ Numeric Keypad | Dedicated virtual numeric keypad for POS, cashier checkout, order tickets, and rapid number entry. |
| **`TLazDroidSignaturePad`** | ✍️ Signature Pad | Digital touch signature capture canvas with smooth strokes and direct export to bitmap/image. |
| **`TLazDroidAvatar`** | 👤 Avatar | Circular profile picture with automatic initial fallback and connection status badge (*Online / Away*). |

> 📖 **Palette Quick Reference Manual:**  
> To view interactive documentation for every property, event, and Pascal code example across all 30 components, open in your browser:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (or run the shortcut `Abrir-Manual-Componentes.cmd`).

> 📚 **Complete Official Book (HTML & PDF Export):**  
> We have created a comprehensive, formatted technical book covering everything from environment setup and hardening to building a commercial **Sales Force application with SQLite**:  
> - **File:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (or run the shortcut `Abrir-Livro-LazDroid.cmd`).  
> - **PDF Export:** The book features a built-in top button to instantly generate/print an A4-format PDF with a professional cover, table of contents, page numbers, and clean chapter breaks.

---

## 🛠️ Step-by-Step Installation Guide (For GitHub Users)

If you have just cloned or downloaded the repository from GitHub, follow the steps below to set up your environment in minutes:

### 1. System Prerequisites
Before running the installer, ensure you have installed on Windows:
* **Lazarus IDE (v2.2, 3.x, or 4.x)**: installed (e.g., `C:\lazarus`).
* **Android SDK & ADB**: installed via Android Studio or standalone at `%LOCALAPPDATA%\Android\Sdk` (with `platform-tools` containing `adb.exe`).
* **Android NDK**: versions r21 through r26 (installed via Android Studio under *SDK Tools* -> *NDK (Side by side)*).
* **Java JDK 17 or higher**: installed (e.g., Eclipse Adoptium JDK or Android Studio's bundled `jbr`).
* **Android Device**: connected via USB cable with **USB Debugging** enabled in *Developer Options*.

---

### 2. 1-Click Automatic Installation

1. Open the cloned project directory:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Double-click the file:
   ```cmd
   Instalar-LazDroid.cmd
   ```
3. Windows will request Administrator privileges (UAC). Click **Yes**.
4. The installer automatically performs all setup steps:
   - ✅ Locates the installed Lazarus IDE (`C:\lazarus`).
   - ✅ Automatically downloads and extracts the FPC AArch64 cross-compiler and Android RTL units.
   - ✅ Copies `ppcrossa64.exe` binaries and `aarch64-android` / `arm-android` units to FPC.
   - ✅ Applies the mobile patch for virtual keyboard activation in LCL CustomDrawn.
   - ✅ Compiles LCL CustomDrawn and packages for Android AArch64.
   - ✅ Registers the packages **`LazDroidControls.lpk`** (29 mobile components) and **`LazDroidDeploy.lpk`** (Deploy & Target Manager) in Lazarus.
   - ✅ Autodetects Android SDK, NDK, ADB, JDK and writes the `lazdroiddeploy.xml` configuration file.
5. When prompted at the end, type **`S`** (or press Enter) to authorize rebuilding the IDE. Lazarus will be recompiled with LazDroid built-in!

---

### 3. Organize the IDE in Delphi Style (Optional, Recommended)

If Lazarus' windows are floating or disorganized, double-click the file:
```cmd
Restaurar-Layout-Lazarus.cmd
```
This arranges the interface into a professional docked layout (*AnchorDocking*) identical to Delphi:
* **Left:** Object Inspector (components, properties, and events).
* **Center:** Code Editor and Form Designer at the top, Messages and Debugging at the bottom.
* **Right:** Project Inspector at the top, LazDroid Mobile Target Manager in the middle, and Component Palette at the bottom.
* *(The layout is locked as read-only to prevent accidental rearrangement).*

---

### 4. How to Test and Run Your First Deployment

1. Open **Lazarus IDE**.
2. Connect your mobile phone via USB (with *USB Debugging* enabled).
3. Open any of the included ready-to-run demo projects:
   * **`demo5/project1.lpi`**: Full sales application with **Login**, local **SQLite database (`database/app.db`)**, and tab navigation (**`TLazDroidBottomNav`**).
   * **`demo4/demo4.lpi`**: Showcase of touch-first buttons, cards, badges, inputs, and list views.
   * **`demo/LazAndroidDemo.lpi`**: Sales force demo with LCL visual forms.
4. Press the shortcut:
   ```
   Ctrl + Shift + F9
   ```
   *(Or click the menu `Run -> Deploy & Run on Android Device`)*.
5. LazDroid compiles the native ARM64 library (`liblazapp.so`), packages the APK with Gradle, and installs/launches the app on your phone in seconds!

---

## 📊 LCL Component Status on Android

| LCL Component | Status on Android | Notes |
| :--- | :---: | :--- |
| **LazDroid Palette** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView optimized for touch |
| **TForm** | ✅ Ready | Maximized, dynamic resizing on screen rotation |
| **TLabel** | ✅ Ready | Font rendering, word wrap, colors, and alignment |
| **TButton** | ✅ Ready | Touch click, pressed/released visual states |
| **TPanel** | ✅ Ready | Containers, styled cards, borders, and colors |
| **TPageControl / TTabSheet** | ✅ Ready | Multiple tabs with dynamic switching |
| **TCheckBox** | ✅ Ready | Selection and visual toggle state |
| **TImage / TCanvas** | ✅ Ready | Canvas drawing, bitmaps, and primitive shapes |
| **TEdit / TMemo** | ✅ Ready | Android virtual keyboard via `csRequiresKeyboardInput` and `adjustResize` |
| **TComboBox** | 🔄 In Adaptation | Native selection dialog (Spinner) recommended |
| **TStringGrid / TDBGrid** | 🔄 In Adaptation | Grid display; touch scrolling requires smooth inertia |
| **Dialogs (ShowMessage)** | ✅ Ready | Mapped to native Android `AlertDialog` |
| **SQLite Database** | ✅ Ready | Direct access via native compiled `libsqlite.so` |

For architectural details, refer to [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). For step-by-step installation instructions, see [`docs/INSTALL_GUIDE.md`](docs/INSTALL_GUIDE.md).

---

## 🤝 How to Contribute

Contributions from the entire Delphi, Lazarus, and Free Pascal community are warmly welcomed! If you would like to suggest an improvement, report or fix a bug, or create a new mobile component:

1. **Fork** the repository ([github.com/mabreu2022/LazAndroid](https://github.com/mabreu2022/LazAndroid)).
2. Create a branch for your feature (`git checkout -b feat/my-improvement`).
3. Develop your changes and verify compilation in Lazarus and the AArch64 cross-compiler.
4. Open a **Pull Request (PR)** detailing the changes made.

> 🛡️ **Governance & Approval Policy:**  
> The main branch (`main`) has protection enabled. No commits are merged directly into production without **explicit review and approval by the maintainer (@mabreu2022)**.
> 
> Please read our [Full Contribution Guide (`CONTRIBUTING.md`)](CONTRIBUTING.md) and [Code of Conduct (`CODE_OF_CONDUCT.md`)](CODE_OF_CONDUCT.md).
