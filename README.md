# 💠 Fullstack Flutter & Backend Application  
مشروع متكامل يجمع بين **تطبيق Flutter** للواجهة الأمامية، و **واجهة خلفية Backend** خاصة لإدارة البيانات والخدمات.  
المشروع يمثل نموذج عملي لطريقة عملي في بناء الأنظمة، تنظيم الأكواد، الهيكلة، والتكامل بين الواجهة والخادم.

---

## 🔧 التقنيات المستخدمة

### **الواجهة الأمامية (Frontend – Flutter)**
- Flutter (Dart)
- إدارة الحالة (Provider / GetX) — بحسب النسخة التنفيذية
- Dio للاتصال بالـ API
- Firebase (Authentication / Firestore) – إن استخدم
- UI مبني بطريقة نظيفة وقابلة للتوسع

### **الواجهة الخلفية (Backend)**
- Python  
- Django / DRF (REST API)  
- PostgreSQL أو SQLite  
- JWT Authentication  
- خدمات CRUD كاملة  

---

## 🏗 بنية المشروع (Project Structure)

```bash
/
├── backend/              
│   ├── core/
│   ├── apps/
│   ├── requirements.txt
│   └── manage.py
│
├── frontend/            
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── utils/
│   └── pubspec.yaml
│
├── assets/
│   └── screenshots/       
│
└── README.md
