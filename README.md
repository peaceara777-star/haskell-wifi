# 📶 WiFi Diagnostic Tool - Haskell Edition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Haskell](https://img.shields.io/badge/Haskell-5e5086?logo=haskell)](https://www.haskell.org/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-blue)](https://github.com/peaceara777-star/haskell-wifi)

أداة احترافية مكتوبة بلغة **Haskell** لتشخيص وإصلاح مشاكل الواي فاي. تدعم أنظمة **Linux** و **Windows** مع هيكلية قابلة للتوسع.

---

## ✨ المميزات

| الميزة | الوصف |
|--------|-------|
| 🔍 **تشخيص شامل** | اكتشاف مشاكل الكرت، DNS، الإشارة، والاتصال |
| 🔧 **إصلاح تلقائي** | حل المشاكل الشائعة تلقائياً بنقرة واحدة |
| 📡 **مسح الشبكات** | عرض جميع شبكات الواي فاي المتاحة مع قوة الإشارة |
| 🖥️ **دعم متعدد المنصات** | Linux و Windows (macOS قيد التطوير) |
| ⚡ **سريع وخفيف** | مكتوب بلغة Haskell النقية مع أداء عالي |
| 🧩 **قابل للتوسع** | هيكلية Modules تسهل إضافة ميزات جديدة |

---

## 📦 التثبيت

### المتطلبات الأساسية

- [Stack](https://docs.haskellstack.org/en/stable/README/) (مدير حزم Haskell)
- Git (لاستنساخ المستودع)

### خطوات التثبيت

```bash
# استنساخ المستودع
git clone https://github.com/peaceara777-star/haskell-wifi.git
cd haskell-wifi

# بناء المشروع
stack build

# تثبيت الملف التنفيذي (اختياري)
stack install# تثبيت الأدوات المطلوبة (Debian/Ubuntu)
sudo apt install network-manager rfkill nmap
Windows

· تشغيل PowerShell أو CMD كمسؤول (Administrator)
· التأكد من تفعيل خدمة WLAN AutoConfig

---

🚀 الاستخدام

الأوامر الأساسية

الأمر الوصف
wifi-diagnostic الوضع التفاعلي (موصى به للمبتدئين)
wifi-diagnostic --diagnose تشخيص المشاكل فقط
wifi-diagnostic --repair إصلاح تلقائي لجميع المشاكل
wifi-diagnostic --scan مسح الشبكات المتاحة
wifi-diagnostic --status عرض حالة الشبكة الحالية
wifi-diagnostic --reset-network إعادة تهيئة مكدس الشبكة
wifi-diagnostic --forget "اسم_الشبكة" حذف شبكة محفوظة
wifi-diagnostic --help عرض المساعدة
wifi-diagnostic --version عرض رقم الإصدار

أمثلة عملية

```bash
# تشخيص سريع للمشاكل
wifi-diagnostic --diagnose

# عرض الشبكات المتاحة مع قوة الإشارة
wifi-diagnostic --scan

# إصلاح مشاكل الاتصال تلقائياً
wifi-diagnostic --repair

# نسيان شبكة محددة
wifi-diagnostic --forget "Coffee Shop WiFi"
```

---

📁 هيكل المشروع

```
haskell-wifi/
├── app/
│   └── Main.hs                 # نقطة الدخول الرئيسية
├── src/
│   ├── WifiTypes.hs            # تعريف الأنواع والبيانات
│   ├── Diagnostics.hs          # طبقة التشخيص والتحليل
│   ├── RepairEngine.hs         # محرك الإصلاح والحلول
│   ├── Platform/
│   │   ├── Linux.hs            # دعم خاص بنظام Linux
│   │   └── Windows.hs          # دعم خاص بنظام Windows
│   └── Utils/
│       └── Command.hs          # دوال مساعدة لتنفيذ أوامر النظام
├── test/
│   └── Spec.hs                 # اختبارات الوحدة
├── package.yaml                # إعدادات الحزمة (Hpack)
├── stack.yaml                  # إعدادات Stack
├── LICENSE                     # رخصة MIT
└── README.md                   # هذا الملف
```

---

🧪 المشاكل المدعومة للتشخيص والإصلاح

المشكلة الوصف الإصلاح التلقائي
NoWifiAdapterFound لم يتم العثور على كرت واي فاي ❌
AdapterDisabled الكرت معطل (وضع الطيران) ✅
NotConnected غير متصل بأي شبكة ✅
ConnectedNoInternet متصل بالراوتر لكن لا يوجد إنترنت ✅
DnsResolutionFailure مشكلة في DNS ✅
WeakSignalStrength إشارة ضعيفة ⚠️
WrongPassword كلمة سر خاطئة ❌
IpConflict تعارض في عنوان IP ✅
DriverIssue مشكلة في التعريفات ❌

✅ = إصلاح تلقائي متاح | ⚠️ = يحتاج تدخل جزئي | ❌ = يحتاج تدخل يدوي

---

🤝 المساهمة

المساهمات مرحب بها! للمساهمة:

1. قم بعمل Fork للمشروع
2. أنشئ فرعاً للميزة:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. قم بعمل Commit للتغييرات:
   ```bash
   git commit -m 'إضافة ميزة رائعة'
   ```
4. ارفع الفرع:
   ```bash
   git push origin feature/AmazingFeature
   ```
5. افتح Pull Request

إرشادات المساهمة

· اتبع نمط الكود الموجود
· أضف تعليقات بالعربية أو الإنجليزية
· تأكد من اجتياز الاختبارات: stack test
· قم بتحديث README إذا أضفت ميزة جديدة

---

📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف LICENSE للتفاصيل الكاملة.

```
MIT License

Copyright (c) 2024 peaceara777

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
