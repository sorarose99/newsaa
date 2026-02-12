# إعداد Supabase للتطبيق

## خطوات الإعداد

### 1. إنشاء حساب Supabase
1. اذهب إلى [Supabase](https://supabase.com)
2. أنشئ حساب جديد أو سجل دخولك
3. أنشئ مشروع جديد

### 2. الحصول على بيانات الاتصال
من لوحة التحكم، انسخ:
- `URL` (Project URL)
- `Anon Key` (Project API Key)

### 3. تحديث supabase_service.dart
في ملف `lib/core/services/supabase_service.dart`، استبدل:
```dart
url: 'https://YOUR_SUPABASE_URL.supabase.co',
anonKey: 'YOUR_SUPABASE_ANON_KEY',
```

بقيمك الفعلية من Supabase.

### 4. إنشاء الجداول المطلوبة

#### جدول admins
```sql
CREATE TABLE admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  email TEXT NOT NULL,
  "isAdmin" BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

#### جدول virtues
```sql
CREATE TABLE virtues (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  category TEXT,
  title TEXT,
  text TEXT NOT NULL,
  description TEXT,
  url TEXT,
  createdAt TIMESTAMP DEFAULT now(),
  updatedAt TIMESTAMP DEFAULT now()
);
```

#### جدول prayer_formulas
```sql
CREATE TABLE prayer_formulas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "titleAr" TEXT NOT NULL,
  "titleEn" TEXT NOT NULL,
  "contentAr" TEXT NOT NULL,
  "contentEn" TEXT NOT NULL,
  "createdAt" TIMESTAMPTZ DEFAULT now(),
  "updatedAt" TIMESTAMPTZ DEFAULT now()
);
```

#### جدول evidence
```sql
CREATE TABLE evidence (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  content TEXT NOT NULL,
  source TEXT,
  createdAt TIMESTAMP DEFAULT now(),
  updatedAt TIMESTAMP DEFAULT now()
);
```

#### جدول hadith
```sql
CREATE TABLE hadith (
  id TEXT PRIMARY KEY,
  text TEXT NOT NULL,
  narrator TEXT,
  source TEXT,
  grade TEXT,
  createdAt TIMESTAMP DEFAULT now(),
  updatedAt TIMESTAMP DEFAULT now()
);
```

#### جدول media
```sql
CREATE TABLE media (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  createdAt TIMESTAMP DEFAULT now(),
  updatedAt TIMESTAMP DEFAULT now()
);
```

#### جدول "prayerFormulaSounds"
```sql
CREATE TABLE "prayerFormulaSounds" (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  title TEXT NOT NULL,
  url TEXT,
  sound_binary BYTEA, -- قديم، يفضل استخدام url
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

#### جدول users (اختياري - للإحصائيات)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT,
  lastActive TIMESTAMP DEFAULT now(),
  createdAt TIMESTAMP DEFAULT now()
);
```

### 5. تكوين صلاحيات الوصول (RLS)

في Supabase Dashboard، اذهب إلى Authentication → Policies وأضف:

**للجداول العامة (virtues, media, sounds, etc):**
- اسمح بالقراءة للجميع (انتخب الخيار العام)
- اسمح بالكتابة والتعديل والحذف للمدراء فقط

**لجدول admins:**
- اسمح بالقراءة والكتابة للمدراء المصرحين فقط

### 6. تكوين التخزين (Storage)

في Supabase Dashboard، اذهب إلى Storage:
1. أنشئ bucket جديد باسم `files` (لصور وفيديوهات الفضائل)
2. أنشئ bucket جديد باسم `sounds` (لأصوات صيغ الصلاة)
3. اجعل كلاهما عاماً (Public)

### 7. منح صلاحيات المسؤول (Admin)
بعد إنشاء حساب في التطبيق، قم بتشغيل هذا الاستعلام في SQL Editor لمنح نفسك صلاحيات المسؤول:

```sql
INSERT INTO admins (id, username, email, "isAdmin")
VALUES (
  'USER_ID_FROM_AUTH_USERS', -- احصل عليه من تبويب Authentication
  'admin_name',
  'admin@email.com',
  true
);
```

```bash
flutter pub get
flutter run
```

## ملاحظات مهمة

- **بيانات الاعتماد**: لا تنسَ استبدال `YOUR_SUPABASE_URL` و `YOUR_SUPABASE_ANON_KEY` بقيمك الفعلية
- **الأمان**: احم مفاتيحك وعدم تشاركها في الريبوزيتوري
- **المصادقة**: استخدم عنوان بريد إلكتروني وكلمة مرور قوية للمدراء
- **النسخ الاحتياطية**: قم بعمل نسخ احتياطية منتظمة لبيانات Supabase

## استكشاف الأخطاء

إذا واجهت مشاكل:

1. **خطأ "Could not connect"**: تحقق من عنوان URL والمفتاح
2. **خطأ "Permission denied"**: تحقق من سياسات RLS
3. **خطأ "Table not found"**: تأكد من إنشاء جميع الجداول

## الدعم

للحصول على دعم إضافي:
- استشر [وثائق Supabase](https://supabase.com/docs)
- تحقق من سجلات الأخطاء في Flutter DevTools
