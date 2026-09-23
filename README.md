# Kanz-e-Naseem (کنزِ نسیم)

### Islamic Literature, Audio Recordings & Historical Archives App
Built with **Flutter**, **Firebase Authentication**, **Cloud Firestore**, and **Firebase Storage**.

---

## 🌟 Key Architecture & Features

### 1. Authentication & Admin Gatekeeper
- **Master Admin (`ranaalijaved154@gmail.com`)**:
  - Automatically granted `role: 'admin'`, `isApproved: true`, and `status: 'approved'`.
  - Bypasses the approval gate upon both registration and login, with direct administrative powers.
- **Approval Gatekeeper (`AuthWrapper`)**:
  - Listens directly to the Firestore `users/{uid}` stream.
  - Pending users are shown `WaitingApprovalScreen` with the required Urdu notice:
    > **"آپ کی رجسٹریشن موصول ہو چکی ہے۔ ایڈمن کی منظوری کے بعد مواد تک رسائی دی جائے گی۔"**
  - Once an administrator marks `isApproved: true`, the user's screen **automatically transitions in real-time** to the `MainDashboardScreen`.

---

### 2. Kutub (کتب - Books & Writings)
- **Model**: `BookModel` (`id`, `title`, `description`, `coverUrl`, `fileUrl`, `totalPages`, `createdAt`).
- **Firestore Collection**: `books`
- **UI & Features**:
  - Grid card presentation with high-res cover art.
  - Page count badge and title in elegant Urdu typography (`Amiri`).
  - Search and filter bar.
  - **Built-in PDF Reader (`PdfViewerScreen`)**:
    - Powered by `syncfusion_flutter_pdfviewer`.
    - Floating page indicator (`صفحہ 15 از 240`).
    - One-tap "Jump to Page" dialog.
    - Smooth zoom in/out controls.

---

### 3. Sout o Bayan (صوت و بیان - Audio Recordings / Malfoozaat)
- **Model**: `AudioModel` (`id`, `title`, `topic`, `duration`, `fileUrl`, `createdAt`).
- **Firestore Collection**: `audios`
- **UI & Features**:
  - Filter by topics (`ملفوظات شریف`, `خطبات و بیانات`, `روحانی محافل`, `دعائیہ کلمات`).
  - Search bar.
  - **Persistent Sticky Mini-Player (`MiniPlayerWidget`)**:
    - Stays docked at the bottom across all tabs above the navigation bar when audio is playing.
    - Track title, topic, play/pause toggle, live progress bar, and close button.
  - **Full-Screen Audio Player (`FullAudioPlayerScreen`)**:
    - Ambient Islamic gold & emerald rotating disc artwork.
    - Interactive seek slider with current & remaining time.
    - Skip backward 10s and forward 10s buttons.
    - Playback speed control (`0.75x`, `1.0x`, `1.25x`, `1.5x`, `2.0x`).
    - Powered by `just_audio` with background playback support.

---

### 4. Yadain o Sawaneh (یادیں و سوانح - Memories & Gallery)
- **Model**: `MemoryModel` (`id`, `title`, `description`, `imageUrl`, `date`, `createdAt`).
- **Firestore Collection**: `memories`
- **UI & Features**:
  - Historical timeline cards with date tags (`1995ء`, `شعبان المعظم 1416ھ`).
  - High quality photograph thumbnails with descriptive Urdu text.
  - **Pinch-to-Zoom Image Viewer (`ImageViewerScreen`)**:
    - Interactive zoom up to $4.0\times$ with pan gestures.
    - Dark backdrop and caption overlay.

---

### 5. Admin Content Uploading
- **Access**: Strictly restricted to Master Admin (`ranaalijaved154@gmail.com`) and users with `role: 'admin'`.
- **Upload Modal (`AdminUploadDialog`)**:
  - Triggered via the **Floating Action Button (+)** or Admin Dashboard tab.
  - **Tab 1: کتب (Books)**: Book title, description, total pages, cover image picker, and PDF file picker.
  - **Tab 2: صوت و بیان (Audios)**: Audio title, topic, duration, and MP3 file picker.
  - **Tab 3: یادیں و سوانح (Memories)**: Title, historical date/era, description, and photo picker.
  - Real-time Firebase Storage upload progress percentage (`Uploading... 65%`).

---

## 📁 Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # Master admin email, collections, roles, and Urdu labels
├── models/
│   ├── audio_model.dart            # Model for Sout o Bayan audio recordings
│   ├── book_model.dart             # Model for Kutub books & PDFs
│   ├── memory_model.dart           # Model for Yadain o Sawaneh photo memories
│   └── user_model.dart             # UserModel with permissions & gatekeeper getters
├── services/
│   ├── audio_player_service.dart   # Singleton audio manager (just_audio)
│   ├── auth_service.dart           # FirebaseAuth & Firestore user management
│   ├── content_service.dart        # Firestore CRUD for books, audios, and memories
│   └── storage_service.dart        # Firebase Storage uploads with progress tracking
├── theme/
│   └── app_theme.dart              # Emerald Green & Warm Gold Islamic theme
├── widgets/
│   ├── audio/
│   │   └── mini_player_widget.dart # Sticky bottom mini-player
│   ├── auth_wrapper.dart           # Real-time state router and gatekeeper
│   ├── custom_button.dart          # Reusable styled button with loading state
│   └── custom_text_field.dart      # Styled form field with visibility toggles
├── screens/
│   ├── admin/
│   │   └── admin_upload_dialog.dart# Upload dialog for Books, Audios, and Memories
│   ├── tabs/
│   │   ├── kutub_tab.dart          # Books grid, search & PDF reader trigger
│   │   ├── sout_tab.dart           # Audio playlist, topic chips & player trigger
│   │   └── yadain_tab.dart         # Historical timeline photo gallery
│   ├── full_audio_player_screen.dart # Full-screen audio player with seek & speed
│   ├── image_viewer_screen.dart    # Full-screen pinch-to-zoom photo viewer
│   ├── login_screen.dart           # Login UI with password reset modal
│   ├── main_dashboard_screen.dart  # 4-tab dashboard with sticky mini-player & FAB
│   ├── pdf_viewer_screen.dart      # Built-in PDF reader with page navigation
│   ├── register_screen.dart        # Register UI with client validation
│   └── waiting_approval_screen.dart# Pending approval screen with Urdu notice
└── main.dart                       # Entry point, Firebase initialization & theme binding
```

---

## ⚙️ Recommended Firebase Security Rules

### 1. Cloud Firestore Rules
Publish in Firebase Console under **Firestore Database > Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isMasterAdmin() {
      return isAuthenticated() && 
        (request.auth.token.email.lower() == 'ranaalijaved154@gmail.com' ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    function isApprovedUser() {
      return isAuthenticated() && 
        (isMasterAdmin() || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isApproved == true);
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated() && (request.auth.uid == userId || isMasterAdmin());
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isMasterAdmin() || 
        (request.auth.uid == userId && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isApproved', 'status']));
      allow delete: if isMasterAdmin();
    }

    // Content collections (Books, Audios, Memories)
    match /books/{documentId} {
      allow read: if isApprovedUser();
      allow write: if isMasterAdmin();
    }
    
    match /audios/{documentId} {
      allow read: if isApprovedUser();
      allow write: if isMasterAdmin();
    }
    
    match /memories/{documentId} {
      allow read: if isApprovedUser();
      allow write: if isMasterAdmin();
    }
  }
}
```

### 2. Firebase Storage Rules
Publish in Firebase Console under **Storage > Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isMasterAdmin() {
      return isAuthenticated() && request.auth.token.email.lower() == 'ranaalijaved154@gmail.com';
    }

    // Public read for approved members, Admin write only
    match /{allPaths=**} {
      allow read: if isAuthenticated();
      allow write: if isMasterAdmin();
    }
  }
}
```

---

## 🚀 Running the App

```bash
flutter pub get
flutter run
```
