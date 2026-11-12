<a id="readme-en"></a>
# LazDroid-Deploy — IDE Plugin, Mobile Palette & Android Deployment Suite for Lazarus

<p align="center">
  <a href="#readme-pt">🇧🇷 Português</a> &nbsp;|&nbsp; <b>🇺🇸 English</b>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)
[![Installer: 1-Click GUI](https://img.shields.io/badge/Installer-1--Click%20GUI%20%2B%20Setup.exe-success.svg)](#-1-click-installation-new)

**LazDroid** is a comprehensive professional development suite for **Lazarus IDE / Free Pascal (FPC)** that delivers a true *"1-Click Deploy & Run (Ctrl+Shift+F9)"* mobile experience on real devices, with support for real **LCL Visual Forms (CustomDrawn Android)**, native embedded **SQLite database**, a touch-first **30-component palette**, and **brand-new automated 1-click installers**.

---

## ⚡ 1-Click Installation (New!)

**LazDroid** eliminates all complex manual configurations in Lazarus. You can now use **two new automated installers** to get your full Android environment ready in less than 1 minute:

| Installation Mode | Executable / Location | Recommended For | Key Advantages |
| :--- | :---: | :--- | :--- |
| **⚡ Native GUI Assistant (1-Click)** | [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) *(repo root)* | Developers cloning the Git repo or downloading `.zip` | • Native Pascal / LCL standalone application<br/>• Real-time visual diagnostic dashboard<br/>• No PowerShell execution policy restrictions<br/>• Configures everything with 1 click! |
| **📦 Traditional Windows Setup** | `dist\Setup-LazAndroid.exe` | Clients, partners, and new team members | • Standard Inno Setup wizard installer<br/>• Bundles offline FPC Android toolchain (no 100 MB download needed)<br/>• Start Menu shortcuts for all demos and manuals<br/>• Clean Windows uninstaller |
| **💻 Command-Line / CI Mode** | `Instalar-LazDroid.cmd --cli` | Build scripts, DevOps, and headless CI | • Non-interactive silent execution<br/>• Command-line flags for custom Lazarus paths |

```
┌────────────────────────────────────────────────────────────────────────┐
│  LazDroid — Installation & Environment Configuration Assistant         │
├────────────────────────────────────────────────────────────────────────┤
│  1. Lazarus IDE Installation Directory                                 │
│     Path:      [ C:\lazarus                               ] [ Browse ] │
│     ✔ Lazarus successfully detected! (FPC 3.2.2)                       │
├────────────────────────────────────────────────────────────────────────┤
│  2. Android & Java Toolchain (Real-Time Diagnostics)                   │
│     ✔ Java JDK: C:\Users\...\AppData\Local\Android\jdk                 │
│     ✔ Android SDK: C:\Users\...\AppData\Local\Android\Sdk (ADB OK)     │
│     ✔ Android NDK: C:\Users\...\Sdk\ndk\21.4.7075529                   │
│     ✔ FPC AArch64 Cross-Compiler: ppcrossa64.exe                       │
├────────────────────────────────────────────────────────────────────────┤
│  3. Automated Configuration Checklist                                  │
│     [X] FPC Android Cross-Compilers [X] Android RTL Units              │
│     [X] LCL CustomDrawn Patches     [X] LCL CustomDrawn Android Units  │
│     [X] LazDroidControls Palette    [X] LazDroidDeploy IDE Plugin      │
│     [X] XML / Properties Configs    [X] Lazarus IDE Rebuild            │
├────────────────────────────────────────────────────────────────────────┤
│  [ ⚡ Install All (1-Click) ]     [ 🔍 Verify ]     [ 🎨 Delphi Layout ] │
│  [ 🚀 Open IDE ]                  [ 📂 Demos ]                         │
├────────────────────────────────────────────────────────────────────────┤
│  Activity Log:                                                         │
│  [15:10:00] SUCCESS: Lazarus IDE rebuilt with LazDroid built-in!       │
└────────────────────────────────────────────────────────────────────────┘
```

### 🚀 How to Use the Native GUI Assistant (`Instalar-LazDroid.exe`)
1. Clone or download the repository:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Double-click the standalone executable [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) (or run [`Instalar-LazDroid.cmd`](Instalar-LazDroid.cmd)).
3. The assistant automatically scans and validates your installed **Lazarus IDE**, **Java JDK**, **Android SDK/NDK**, and **FPC AArch64**.
4. Click the prominent **"⚡ Install Everything (1-Click)"** button. In seconds, it executes:
   - ✅ Installs FPC cross-compilers (`ppcrossa64.exe` and `ppcrossarm.exe`).
   - ✅ Copies RTL/FCL units for `aarch64-android` and `arm-android`.
   - ✅ Applies LCL CustomDrawn patches (virtual keyboard `csRequiresKeyboardInput` and font fix `{$ifndef CD_UseNativeText}`).
   - ✅ Compiles LCL CustomDrawn for `aarch64-android`.
   - ✅ Registers packages **`LazDroidControls.lpk`** (30 mobile controls) and **`LazDroidDeploy.lpk`** (menus & deploy pipeline).
   - ✅ Writes configuration files `lazdroiddeploy.xml` and `scaffold\local.properties`.
   - ✅ Rebuilds the Lazarus IDE with LazDroid fully built-in!
5. Click **"🎨 Delphi Layout"** to organize Lazarus into docked single-window tabs (*AnchorDocking*) and click **"🚀 Open IDE"** to start coding!

### 📦 How to Use the Windows Setup Installer (`Setup-LazAndroid.exe`)
For clients, team members, and developers without Git:
1. Run `dist\Setup-LazAndroid.exe` as Administrator.
2. Follow the standard Windows setup wizard and select destination (recommended: `C:\LazAndroid`).
3. The installer extracts the suite, bundles the offline FPC Android toolchain, and creates Start Menu shortcuts.
4. On the final screen, check the box to launch the **Visual Setup Assistant** to finish Lazarus configuration with 1 click.

---

## 🎯 Key Features

- ⚡ **1-Click IDE Deployment**: Trigger compilation, packaging, installation, and execution with a single shortcut (`Ctrl+Shift+F9`) or via the `Run` menu.
- 🎯 **Delphi-Style Target Manager**: Dockable window featuring **automatic USB phone detection (Plug & Play)**, dynamic display of connected devices under the `Target` node, comprehensive hardware/OS inspection (battery, screen resolution, ABI, Android version), and direct deployment to the active target!
- 🎨 **Native On-Screen LCL Components**: Design user interfaces using the **Lazarus Form Designer** with `TForm`, `TButton`, `TLabel`, `TPanel`, `TPageControl`, `TEdit`, `TCheckBox`, and more, rendered via LCL CustomDrawn (`customdrawn_android`).
- 📁 **1-Click New Project Wizard**: Registered under `File -> New... -> Android Application (LazDroid)`, pre-configuring JNI library templates, LCLWidgetType, compiler flags, and the initial form.
- 📱 **Smart ABI & Device Detection**: Scans USB-connected devices (`adb devices -l`) and automatically selects the appropriate target architecture (`arm64-v8a` or `armeabi-v7a`).
- 🔧 **High-Performance Native FPC Compilation**: Drives the Free Pascal cross-compiler (`ppcrossa64`) generating direct ARM64 machine code (`liblazapp.so`), achieving native C/C++ execution performance.
- 🗄️ **Embedded SQLite Database**: Pre-bundled with native `libsqlite.so`, enabling ultra-fast, zero-configuration local offline storage.
- 📦 **Robust Android Scaffold**: Lightweight Java host (`com.pascal.lclproject.LCLActivity`) handling lifecycle, full-screen modes, orientation, display DPI, and multi-touch gestures.
- 💬 **Real-Time Logcat Channeling**: Streams build logs and runtime Logcat (`__android_log_print` / `tag: lclapp`) directly into Lazarus' **Messages** window.
- ⚙️ **Integrated Options Panel**: SDK, NDK, ADB, JDK, and FPC path manager built into the IDE under `Tools -> Options` with automatic path detection.

---

## 📂 Project Structure

```
LazAndroid/
├── Instalar-LazDroid.exe                  # ⚡ 1-Click Native GUI Assistant (LCL)
├── Instalar-LazDroid.cmd                  # Smart launcher with UAC auto-elevation
├── Restaurar-Layout-Lazarus.cmd           # 🎨 Delphi-Style Docked Layout Organizer
├── Abrir-Livro-LazDroid.cmd               # 📚 Direct shortcut to the Official Book
├── Abrir-Manual-Componentes.cmd           # 📖 Direct shortcut to Component Manual
│
├── package/                               # Lazarus Open Tools Packages (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Main deploy plugin & Target Manager
│   ├── LazDroidControls.lpk               # 30-component touch-first mobile palette
│   ├── LazDroidDeploy_Reg.pas             # Menus, shortcuts, and IDE actions registration
│   ├── LazDroidConfig.pas                 # XML configuration persistence
│   ├── LazDroidDeviceManager.pas          # ADB device discovery & inspection
│   └── LazDroidPipeline.pas               # 6-stage master build orchestrator
│
├── scaffold/                              # Gradle Android packaging scaffold
│   ├── build.gradle                       # Root Gradle script
│   ├── gradlew.bat                        # Windows Gradle Wrapper
│   └── app/                               # Main Android application module
│       ├── build.gradle                   # SDK targets (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Preconfigured for LCLActivity
│           ├── java/.../LCLActivity.java  # Java host: LCL canvas, touch, JNI bridge
│           └── jniLibs/arm64-v8a/         # liblazapp.so and libsqlite.so (AArch64)
│
├── demo/                                  # Demo 1: Sales Force & LCL Forms with SQLite
├── demo2/                                 # Demo 2: Minimalist "Hello World" LCL example
├── demo3/                                 # Demo 3: Multi-tab layout with PageControl & CRUD
├── demo4/                                 # Demo 4: LazDroid Touch-First Mobile Palette showcase
├── demo5/                                 # Demo 5: Full Commercial App (Login + SQLite + BottomNav)
│
├── tools/                                 # Tools, installers, and helper scripts
│   ├── installer/                         # Inno Setup script (Setup-LazAndroid.iss) & install.ps1
│   ├── installer_gui/                     # Pascal/LCL source code of the GUI Assistant
│   └── scripts/                           # Restaurar-Layout-Lazarus.ps1 and generators
│
├── dist/                                  # Built distribution packages (Setup-LazAndroid.exe)
└── docs/                                  # Technical Documentation, Manuals & Official Book
    ├── ARCHITECTURE.md                    # Detailed architecture & Mermaid diagrams
    ├── INSTALL_GUIDE.md                   # Step-by-step installation guide
    ├── livro_lazdroid_desenvolvimento_mobile.html  # Official Book (with PDF export)
    └── manual_componentes_lazdroid.html   # Interactive Mobile Palette Manual
```

---

## 📱 "LazDroid" Mobile Component Suite (30 Components)

**LazDroid** features a comprehensive library of **30 touch-first mobile components**, specifically engineered for Android touchscreens (Material Design & iOS look-and-feel), breaking free from desktop-oriented controls.

All controls are available under the **`LazDroid`** palette in the Form Designer:

### 🧭 Navigation & Layout
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Mobile title bar with dynamic title, subtitle, Back button (`OnBackClick`), and action buttons (`OnActionClick`). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Bottom navigation bar with touch tabs, automatic vector icons, notification badges, and `OnTabSelected` event. |
| **`TLazDroidBottomSheet`** | 📥 Modal Drawer | Slide-up modal sheet with touch handle, perfect for contextual options, sharing, and filters. |
| **`TLazDroidSpeedDial`** | ⚡ Floating Menu | Expandable Floating Action Button that unfolds into multiple child action buttons with icon rotation. |
| **`TLazDroidLayout`** | 📐 Responsive Box | Responsive screen container with smart padding, rounded corners, and smooth vertical touch scrolling. |

### ✏️ Data Input & Forms
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidEdit`** | ✏️ Input Field | Touch text input with placeholder support, rounded corners, and **automatic Android virtual keyboard activation**. |
| **`TLazDroidSearchBar`** | 🔍 Search Bar | Search bar with search icon, instant clear button (`X`), pill shape, and real-time typing events (`OnSearch`). |
| **`TLazDroidOtpBox`** | 🔢 PIN / OTP Input | Security PIN / SMS verification code input (4-6 digits) in individual boxes with auto-focus advancing. |
| **`TLazDroidDatePicker`** | 📅 Date Picker | Touch date selector with mobile popup calendar and localized date formatting. |
| **`TLazDroidTimePicker`** | ⏰ Time Picker | Hour and minute selector with 12h/24h toggle and touch carousel controls. |
| **`TLazDroidCheckBox`** | ☑️ CheckBox | Expanded touch checkbox with smooth fill animation, checkmark, and label. |
| **`TLazDroidSwitch`** | 🎚️ Toggle Switch | iOS/Material style on/off toggle switch with animated transitions and active/inactive colors. |
| **`TLazDroidRadioGroup`** | 🔘 Radio Group | Mutually exclusive radio buttons with vertical/horizontal layout and comfortable touch areas. |
| **`TLazDroidSegmentedControl`** | 📑 Segments | Horizontal segmented control with sliding pill indicator for quick view toggling or filters. |
| **`TLazDroidChipGroup`** | 🏷️ Filter Chips | Dynamic chip/tag collection supporting single or multi-selection for categories and filters. |

### 📋 Lists & Data Display
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidListView`** | 📋 Card List | Mobile card list with title, subtitle, badges, 32-bit images, right-aligned currency, and **touch drag scrolling**. |
| **`TLazDroidCard`** | 🃏 Surface Card | Elevated surface card with soft shadow, header, and rounded corners to group related information. |
| **`TLazDroidMetricCard`** | 📊 KPI Card | Specialized dashboard card with key numeric metric, label, and percentage variance badge. |
| **`TLazDroidSectionHeader`** | 📑 Section Header | Visual section divider with bold title and optional action link (*e.g., "See all"*). |
| **`TLazDroidImageList`** | 🖼️ Image Manager | Mobile image and icon manager supporting true 32-bit alpha transparency (PNG) without visual loss. |

### 🔘 Actions, Buttons & Feedback
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidButton`** | 🔘 Action Button | Touch-sized button (min 48px), semantic variants (*Primary, Success, Danger, Outline*), and vector icons. |
| **`TLazDroidFAB`** | ➕ Action Button | Floating Action Button with elevated drop shadow, ideal for primary screen actions (*e.g., New Order*). |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Semantic status badge (*Pending, Completed, Cancelled*) or notification counter pill (*e.g., 3*). |
| **`TLazDroidProgressBar`** | ⏳ Progress Bar | Smooth progress bar with centered percentage label and customizable state colors. |
| **`TLazDroidSlider`** | 🎚️ Value Slider | Touch slider with floating bubble value indicator for continuous adjustments. |
| **`TLazDroidActivityIndicator`** | 🔄 Spinner | Modern circular loading spinner for asynchronous SQLite queries or network requests. |

### 📱 Special Mobile Features
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidRatingBar`** | ⭐ Star Rating | Interactive touch star rating (1 to 5 stars) with half-star precision. |
| **`TLazDroidKeypad`** | ⌨️ Numeric Keypad | Dedicated virtual numeric keypad for POS, order processing, and rapid data entry. |
| **`TLazDroidSignaturePad`** | ✍️ Signature Pad | Touch digital signature capture area with smooth curves and direct bitmap export. |
| **`TLazDroidAvatar`** | 👤 Avatar | Circular user avatar with automatic fallback initials and online/offline status badge. |

> 📖 **Interactive Component Palette Manual:**  
> To explore documentation, properties, events, and Pascal code examples for all 30 components, open in your browser:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (or run the shortcut `Abrir-Manual-Componentes.cmd`).

> 📚 **Official Book (HTML & PDF Export):**  
> We wrote a comprehensive technical guide covering environment setup through building a full **Sales Force Application with SQLite**:  
> - **File:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (or run `Abrir-Livro-LazDroid.cmd`).  
> - **PDF Export:** Includes an instant top button to generate/print an A4-format PDF with professional cover, TOC, pagination, and clean chapter breaks.

---

## 🚀 Ready-to-Run Demos (Demos 1 to 5)

The repository comes with 5 complete, ready-to-run showcase projects:

1. **`demo/` (Demo 1 - LCL Sales Force)**: Real visual forms (`FormLogin.pas`, `FormVendas.pas`) connected to a local SQLite database.
2. **`demo2/` (Demo 2 - Minimalist Hello World)**: Lightweight form demonstrating button clicks, dialogs, and dynamic rotation resizing.
3. **`demo3/` (Demo 3 - Multi-Tab CRUD)**: Multi-tab layout using `TPageControl`, `TTabSheet`, edit controls, and mock CRUD operations.
4. **`demo4/` (Demo 4 - Touch-First Showcase)**: Live gallery of all 30 LazDroid mobile components operating on Android.
5. **`demo5/` (Demo 5 - Full Commercial App)**: Complete Sales Force app with local SQLite authentication (`database/app.db`), bottom tab navigation (`TLazDroidBottomNav`), customer management, and product catalog.

### How to Run a Demo on Your Phone:
1. Open **Lazarus IDE**.
2. Connect your mobile phone via USB cable (with *USB Debugging* enabled).
3. Open any demo project (e.g., `demo5/project1.lpi`).
4. Press:
   ```
   Ctrl + Shift + F9
   ```
5. LazDroid compiles the native ARM64 library (`liblazapp.so`), builds the APK, and deploys it straight to your device in seconds!

---

## 🎨 Organize the IDE in Delphi Style (1-Click)

If Lazarus' windows are floating or disorganized, apply the Delphi-style docked layout directly from the GUI Assistant (**"🎨 Delphi Layout"** button) or by running:
```cmd
Restaurar-Layout-Lazarus.cmd
```
This organizes the interface into a docked layout (*AnchorDocking*) identical to Delphi:
* **Left:** Object Inspector (components, properties, and events).
* **Center:** Code Editor and Form Designer at the top, Messages and Debugging at the bottom.
* **Right:** Project Inspector at the top, LazDroid Mobile Target Manager in the middle, and Component Palette at the bottom.
* *(The layout is locked against accidental rearrangement).*

---

## 📊 LCL Component Status on Android

| LCL Component | Status on Android | Notes |
| :--- | :---: | :--- |
| **LazDroid Palette (30 Controls)** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView optimized for touch |
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
