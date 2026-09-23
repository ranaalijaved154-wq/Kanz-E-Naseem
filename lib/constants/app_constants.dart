/// App Constants for Kanz-e-Naseem (کنزِ نسیم)
class AppConstants {
  // Master Admin Email & Display Name
  static const String adminEmail = "ranaalijaved154@gmail.com";
  static const String adminDisplayName = "خاکسار ایڈمن: علی جاوید";
  static const String adminDisplayNameEnglish = "Khaaksaar Admin: Ali Javed";

  // Firestore Collections
  static const String usersCollection = "users";
  static const String booksCollection = "books";
  static const String audiosCollection = "audios";
  static const String memoriesCollection = "memories";

  // User Roles
  static const String roleAdmin = "admin";
  static const String roleUser = "user";

  // User Approval Statuses
  static const String statusPending = "pending";
  static const String statusApproved = "approved";
  static const String statusRejected = "rejected";

  // App Title & Taglines
  static const String appNameUrdu = "کنزِ نسیم";
  static const String appNameEnglish = "Kanz-e-Naseem";
  static const String appSubTitleUrdu = "علم، حکمت اور روحانیت کا خزانہ";

  // Messages
  static const String pendingApprovalMessageUrdu =
      "آپ کی رجسٹریشن موصول ہو چکی ہے۔ ایڈمن کی منظوری کے بعد مواد تک رسائی دی جائے گی۔";
  static const String pendingApprovalStatusUrdu = "زیرِ التواء (منظوری درکار ہے)";
  static const String approvedStatusUrdu = "منظور شدہ (فعال اکاؤنٹ)";
  static const String rejectedStatusUrdu = "درخواست مسترد کر دی گئی";

  // Utility helper to check if an email is master admin
  static bool isMasterAdmin(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == adminEmail.toLowerCase();
  }
}
