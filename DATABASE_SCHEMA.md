# OneCitizen — Database Schema (সহজ ভাষায়)

এটা Firebase Realtime Database (RTDB) — অর্থাৎ পুরো ডেটাবেসটা একটা বড় JSON gaach (tree)।
প্রচলিত SQL-এর মতো আলাদা "table" নেই, কিন্তু প্রথম লেভেলের প্রতিটা ভাগ (node) কে
আমরা টেবিলের মতোই ভাবতে পারি। প্রজেক্ট: `onecitizen-bd`।
Security rules (কে কী করতে পারবে) থাকে [database.rules.json](database.rules.json) ফাইলে।

**মোট ৮টা node (টেবিল):**

1. [users](#1-users) — সব ইউজারের প্রোফাইল
2. [card_types](#2-card_types) — কী কী কার্ড পাওয়া যায়
3. [applications](#3-applications) — কার্ডের আবেদন
4. [documents](#4-documents) — আপলোড করা কাগজপত্র
5. [notifications](#5-notifications) — citizen-কে পাঠানো নোটিফিকেশন
6. [admin_notifications](#6-admin_notifications) — admin-কে পাঠানো নোটিফিকেশন
7. [application_locks](#7-application_locks) — ব্যাকগ্রাউন্ড সেফটি লক (UI-তে দেখা যায় না)
8. [phone_index](#8-phone_index) — ব্যাকগ্রাউন্ড সেফটি লক (UI-তে দেখা যায় না)

---

## 1. `users`

প্রতিটা account (citizen অথবা admin) এখানে একটা করে entry, key হলো Firebase Auth-এর
দেওয়া `uid` (যেমন `GxNYBJIjQ6S7h4yaWPDwvdB9cTr2` — এটা কোনো নাম না, শুধু ইউনিক আইডি)।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `email` | `"tanvir@gmail.com"` | লগইন ইমেইল |
| `role` | `"citizen"` অথবা `"admin"` | এই account citizen নাকি admin — কোন ড্যাশবোর্ড দেখাবে তা এটা দিয়ে ঠিক হয় |
| `is_active` | `true` / `false` | account **চালু আছে কিনা**। `false` করলে ওই citizen আর login করতে পারবে না (admin "Deactivate" চাপলে এটা `false` হয়) |
| `is_frozen` | `true` / `false` | account **সাময়িক আটকানো কিনা**। admin কাউকে সন্দেহজনক মনে করলে "Freeze" চাপে, তখন এটা `true` হয়ে যায় এবং citizen login করতে পারে না — কিন্তু deactivate-এর চেয়ে এটা "নরম" আটকানো, ভবিষ্যতে unfreeze করা যায় |
| `verified` | `true` / `false` | admin এই citizen-কে verify করেছে কিনা (identity confirm করা হয়েছে কিনা) — কোথাও hard-block করে না, শুধু status হিসেবে দেখানো হয় |
| `created_at` | `1786483839103` | account কবে তৈরি হয়েছে, milliseconds টাইমস্ট্যাম্প (মানুষের পড়ার জন্য না, কোড এটা date-এ রূপান্তর করে) |
| `first_name` / `last_name` | `"Tanvir"` / `"Islam"` | citizen-এর নাম (শুধু citizen account-এ থাকে) |
| `phone` | `"01854603003"` | ফোন নাম্বার — একজনের বেশি account একই ফোনে বানানো আটকাতে ব্যবহার হয় ([phone_index](#8-phone_index) দেখুন) |
| `nid` | `"1234567890"` | জাতীয় পরিচয়পত্র নাম্বার (বর্তমানে registration form-এ নেওয়া হয় না, তাই বেশিরভাগ account-এ খালি) |
| `date_of_birth` | `"2000-01-01"` | জন্মতারিখ |
| `gender` | `"male"` / `"female"` / `"other"` | লিঙ্গ |
| `address` | `"Dhaka"` | ঠিকানা |
| `occupation` | `"farmer"` / `"student"` ইত্যাদি | পেশা — Farmer Card-এর eligibility check এটার উপর নির্ভর করে |
| `income` | `8000` | মাসিক পারিবারিক আয় (টাকায়) — Family Card eligibility-তে ব্যবহার হয় |
| `ssc_gpa` / `hsc_gpa` | `5.0` | SSC/HSC পরীক্ষার GPA — Education Card eligibility-তে ব্যবহার হয় |
| `name` | `"Admin"` | admin account-এর জন্য একটা মাত্র নাম ফিল্ড (first/last name আলাদা না) |

**কে কী করতে পারে:** নিজের প্রোফাইল নিজে পড়তে/বদলাতে পারবে; admin সবার প্রোফাইল পড়তে/বদলাতে
পারবে। কিন্তু `role`, `verified`, `is_active`, `is_frozen` — এই ৪টা ফিল্ড citizen নিজে
বদলাতে পারবে না, শুধু admin পারবে (নাহলে citizen নিজেকে নিজে admin বানিয়ে ফেলতে পারত!)।

---

## 2. `card_types`

কোন কোন welfare card পাওয়া যায় তার তালিকা। প্রতিটার key একটা ছোট id
(`ct-education`, `ct-family`, `ct-farmer`)।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `code` | `"education"` | কোড নাম, অ্যাপের ভেতরে লজিকে ব্যবহার হয় |
| `name` | `"Education Card"` | ইউজারকে দেখানো নাম |
| `eligibility_criteria` | `"Must have achieved GPA 5.00..."` | কার্ডের জন্য যোগ্যতা কী, citizen-কে দেখানো হয় |
| `required_documents` | `["nid_copy", "ssc_marksheet", "hsc_marksheet"]` | এই কার্ডের জন্য কোন কোন ডকুমেন্ট আপলোড করতে হবে |

**কে কী করতে পারে:** সবাই পড়তে পারে (login না করেও); শুধু admin নতুন card type
যোগ/পরিবর্তন করতে পারে।

---

## 3. `applications`

একজন citizen যখন "Apply for Card" করে জমা দেয়, সেই আবেদনের রেকর্ড। Key একটা
auto-generated id (যেমন `-OzIL1yiLRUV6YWwJ1wg`)।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `citizen_id` | `"DD2if..."` | কোন citizen-এর আবেদন — `users` node-এর সেই uid |
| `card_type_id` | `"ct-education"` | কোন কার্ডের জন্য আবেদন — `card_types` node-কে নির্দেশ করে |
| `card_type_name` | `"Education Card"` | কার্ডের নাম (আলাদা করে সেভ রাখা হয় যাতে বারবার card_types লুকআপ করতে না হয়) |
| `applicant_name` / `applicant_email` / `applicant_nid` | | আবেদনকারীর তথ্যের কপি (আবেদনের সময়কার স্ন্যাপশট) |
| `application_data` | `{"village_road": "...", "land_unit": "Acre", ...}` | ফর্মে যা যা লেখা হয়েছে (কার্ড-ভেদে ভিন্ন ফিল্ড) |
| `status` | `"submitted"` → `"approved"` অথবা `"rejected"` | আবেদনের বর্তমান অবস্থা — admin এটা বদলায় |
| `admin_remark` | `"Missing signature"` | reject করলে admin কেন করল সেই কারণ |
| `submitted_at` | timestamp | কবে জমা দেওয়া হয়েছে |
| `updated_at` | timestamp | সর্বশেষ কবে status বদলেছে |

**কে কী করতে পারে:** citizen নতুন আবেদন তৈরি করতে পারবে (status বাধ্যতামূলক `"submitted"`
দিয়ে শুরু হতে হবে); এরপর status বদলানো শুধু admin-ই পারবে (approve/reject)।

---

## 4. `documents`

Citizen-এর আপলোড করা প্রতিটা ফাইল (NID, marksheet, certificate ইত্যাদি)। Key হলো
`uid_doctype` অথবা `uid_applicationId_doctype` ফরম্যাটে।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `citizen_id` | | কার ডকুমেন্ট |
| `citizen_name` / `citizen_email` | | নাম-ইমেইলের কপি (দ্রুত দেখানোর জন্য) |
| `doc_type` | `"nid_copy"` | কী ধরনের ডকুমেন্ট |
| `file_url` | `"data:image/jpeg;base64,..."` | ফাইলটার আসল কন্টেন্ট — base64 আকারে সরাসরি DB-তে সেভ (আলাদা storage bucket নেই) |
| `application_id` | `"-OzIL1yi..."` অথবা `null` | কোন application-এর সাথে যুক্ত — আবেদন করার আগে আপলোড করলে প্রথমে `null` থাকে, আবেদন জমা দেওয়ার সময় এটা লিংক হয় |
| `card_type_id` | | কোন কার্ডের জন্য |
| `uploaded_at` | timestamp | কবে আপলোড হয়েছে |
| `is_valid` | `true` / `false` / `null` | admin ডকুমেন্ট verify করেছে কিনা — `null` মানে এখনো review হয়নি |
| `remark` | `"Blurry image"` | admin invalid করলে কেন করল |

**কে কী করতে পারে:** citizen নিজের ডকুমেন্ট আপলোড/পরিবর্তন করতে পারবে, কিন্তু `is_valid`
আর `remark` ফিল্ড দুটো শুধু admin বদলাতে পারবে (citizen নিজেই নিজের ডকুমেন্ট "verified"
বানিয়ে ফেলতে পারবে না)।

---

## 5. `notifications`

Citizen-কে পাঠানো নোটিফিকেশন (dashboard-এর ঘণ্টা আইকনে দেখা যায়)।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `citizen_id` | | কাকে পাঠানো হয়েছে |
| `message` | `"Your Education Card application has been approved."` | নোটিফিকেশনের লেখা |
| `created_at` | timestamp | কবে পাঠানো হয়েছে |
| `is_read` | `true` / `false` | citizen পড়েছে কিনা — এটা citizen নিজে বদলাতে পারে (পড়লে `true` হয়ে যায়) |

---

## 6. `admin_notifications`

Admin-কে পাঠানো নোটিফিকেশন (citizen নতুন আবেদন করলে বা document আপলোড করলে admin
panel-এ alert দেখানোর জন্য)।

| Field | উদাহরণ মান | মানে কী |
|---|---|---|
| `message` | `"A citizen submitted a new Education Card application."` | কী ঘটেছে |
| `created_at` | timestamp | কবে |
| `is_read` | `true` / `false` | admin দেখেছে কিনা |

---

## 7. `application_locks` *(ব্যাকগ্রাউন্ড — অ্যাপে দেখা যায় না)*

একজন citizen যাতে একই কার্ডে একসাথে দুইবার apply করতে না পারে (দুই আঙুলে দ্রুত দুইবার
বাটন চাপলেও) তার জন্য এই "লক"। Key হয় `citizenId_cardTypeId` ফরম্যাটে।

| Field | মানে কী |
|---|---|
| `citizen_id` | কে লক করেছে |
| `card_type_id` | কোন কার্ডের জন্য |
| `application_id` | সেই আবেদনের id — আবেদন তৈরি হওয়ার পর ভরা হয় |

আবেদন reject হলে এই লক নিজে থেকে মুছে যায়, যাতে citizen আবার apply করতে পারে।

---

## 8. `phone_index` *(ব্যাকগ্রাউন্ড — অ্যাপে দেখা যায় না)*

একই ফোন নাম্বার দিয়ে একজন মানুষ যাতে একাধিক account না বানাতে পারে (ভিন্ন email
দিয়েও), তার জন্য এই index। Key হলো ফোন নাম্বার নিজেই।

| Field | মানে কী |
|---|---|
| *(value)* | কোন `uid` এই ফোন নাম্বারটা claim করেছে |

Registration-এর সময় এটা claim করা হয়; registration কোনো কারণে ব্যর্থ হলে এটাও মুছে
ফেলা হয়, নইলে ফোন নাম্বারটা চিরতরে আটকে থাকত।

---

## কোন টেবিল কোনটার সাথে যুক্ত (Relationships)

```
users (citizen) ──┬──< applications >── card_types
                   ├──< documents >───── card_types
                   ├──< notifications
                   ├──< application_locks >── card_types
                   └──< phone_index (1:1, ফোন নাম্বার দিয়ে)

applications ──< documents (application_id দিয়ে)
applications ──< application_locks (application_id দিয়ে, উল্টো রেফারেন্স)
```

## নিরাপত্তা — কে কী করতে পারে (সংক্ষেপে)

পুরো নিয়ম [database.rules.json](database.rules.json) ফাইলে। সারমর্ম:

- সব জায়গায় login করা লাগবেই (`auth != null`)
- Citizen শুধু **নিজের** ডেটা পড়তে/বদলাতে পারবে, অন্য কারো না
- Status-জাতীয় sensitive ফিল্ড (`applications.status` তৈরির পর, `documents.is_valid`,
  `documents.remark`, `users.role/verified/is_active/is_frozen`) শুধু admin বদলাতে পারবে
- `card_types` সবাই পড়তে পারে, শুধু admin লিখতে পারে
