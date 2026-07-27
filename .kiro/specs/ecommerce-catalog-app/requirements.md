# Requirements Document

## Introduction

تطبيق `shopify` هو تطبيق Flutter لكتالوج متجر إلكتروني يعمل على Android و iOS. المستخدم ينشئ حسابًا (Email/Password أو Google Sign-In) عبر Firebase Authentication، وتُخزَّن بياناته الشخصية (Name, Phone, Email) في Cloud Firestore داخل collection باسم `users` بحيث يكون Document ID مساويًا لـ `uid` الخاص بـ Firebase Auth. بعد الدخول يستعرض المستخدم أقسام المنتجات (Categories) القادمة من DummyJSON API، ثم منتجات القسم، ثم تفاصيل المنتج. تُدار كل حالات التطبيق باستخدام `flutter_bloc` (Cubit) بدون استخدام `setState` لأي عملية شبكة أو قاعدة بيانات أو منطق أعمال.

الهوية البصرية مأخوذة من نظام تصميم **Lux-Commerce (ESTUDIO)** المُصدَّر من Stitch والمنسوخ إلى `design/stitch/` داخل المشروع (`lux_commerce_system/DESIGN.md` + شاشات `code.html` + `screen.png`): أسلوب High-Fashion Minimalism بأسود أساسي وأبيض/رمادي فاتح، خط Inter، مسافات 8px، حواف كبيرة ناعمة، ظلال منتشرة، وأيقونات Material Symbols Outlined، مع شريط تنقل سفلي بأربعة تابات (Home, Search, Favorites, Profile).

الحالة الحالية للمشروع: مشروع Flutter افتراضي (`lib/main.dart` عدّاد افتراضي) مع ملف `lib/firebase_options.dart` مولَّد من FlutterFire CLI (projectId: `shopify-44702`) وملف `android/app/google-services.json` موجود، وملف `ios/Runner/GoogleService-Info.plist` غير موجود. لا توجد أي حزم في `pubspec.yaml` غير `cupertino_icons` و `flutter_lints`، ولا توجد أي assets صور في المشروع؛ صور الكتالوج كلها من DummyJSON، والخط والأيقونات تُجلبان عبر حزمتي `google_fonts` و `material_symbols_icons`.

## Glossary

- **Shopify_App**: تطبيق Flutter بالكامل (نقطة الدخول `main.dart` وطبقاتها).
- **Auth_Service**: الطبقة التي تغلّف `firebase_auth` و `google_sign_in` وتنفّذ Sign Up و Login و Google Sign-In و Logout ومراقبة حالة الجلسة.
- **User_Repository**: الطبقة التي تغلّف `cloud_firestore` وتكتب وتقرأ وثيقة المستخدم في collection `users`.
- **Auth_Cubit**: Cubit مسؤول عن حالات المصادقة (Initial, Loading, Authenticated, Unauthenticated, Error).
- **Profile_Cubit**: Cubit مسؤول عن تحميل بيانات وثيقة المستخدم من Firestore وعرض حالات Loading/Success/Error.
- **Categories_Cubit**: Cubit مسؤول عن جلب قائمة الأقسام من DummyJSON.
- **Products_Cubit**: Cubit مسؤول عن جلب منتجات قسم محدد من DummyJSON.
- **Api_Provider**: الطبقة التي تنفّذ نداءات HTTP إلى DummyJSON باستخدام `dio`.
- **Category_Model**: موديل القسم بالحقول `slug`, `name`, `url` مع `fromJson` و `toJson`.
- **Product_Model**: موديل المنتج بالحقول `id`, `title`, `description`, `category`, `price`, `rating`, `thumbnail`, `images` مع `fromJson` و `toJson`.
- **Products_Response_Model**: موديل الاستجابة الملفوفة بالحقول `products`, `total`, `skip`, `limit`.
- **Auth_Gate**: الويدجت الذي يحدد الشاشة الأولى بناءً على `authStateChanges`.
- **Login_Screen**: شاشة تسجيل الدخول.
- **Register_Screen**: شاشة إنشاء الحساب (Name, Phone, Email, Password).
- **Home_Screen**: شاشة عرض الأقسام.
- **Products_Screen**: شاشة عرض منتجات قسم محدد.
- **Product_Details_Screen**: شاشة تفاصيل المنتج.
- **Profile_Screen**: شاشة الملف الشخصي مع زر Logout.
- **Search_Screen**: شاشة البحث عن الأقسام والمنتجات.
- **Search_Cubit**: Cubit مسؤول عن تصفية الأقسام محليًا وجلب نتائج بحث المنتجات من DummyJSON.
- **Favorites_Screen**: شاشة المنتجات المفضّلة.
- **Favorites_Cubit**: Cubit مسؤول عن تبديل حالة التفضيل وتحميل قائمة المفضّلة.
- **Favorites_Repository**: الطبقة التي تقرأ وتكتب المفضّلة في المسار `users/{uid}/favorites`.
- **Main_Shell**: الويدجت الحاوي لشريط التنقل السفلي والتابات الأربعة (Home, Search, Favorites, Profile).
- **App_Theme**: تعريف الثيم الموحّد المبني على نظام تصميم Lux-Commerce (Material 3، وضع فاتح ووضع داكن).
- **App_Loading_View**: الويدجت المشترك لعرض حالة التحميل بهيئة shimmer placeholders.
- **App_Error_View**: الويدجت المشترك لعرض حالة الخطأ مع أيقونة ورسالة عربية وزر إعادة المحاولة.
- **App_Empty_View**: الويدجت المشترك لعرض حالة عدم وجود بيانات مع أيقونة ورسالة عربية.
- **Design_Tokens**: القيم المرجعية للألوان والخطوط والحواف والمسافات والظلال المستخرجة من `design/stitch/lux_commerce_system/DESIGN.md`.
- **Platform_Config**: ملفات وإعدادات المنصات (Android/iOS) اللازمة لعمل Firebase و Google Sign-In.
- **Firestore_Rules**: قواعد أمان Cloud Firestore الخاصة بـ collection `users`.

## Requirements

### Requirement 1: إنشاء حساب بالبريد وكلمة المرور

**User Story:** كمستخدم جديد، أريد إنشاء حساب باسمي ورقم هاتفي وبريدي وكلمة مرور، حتى أستطيع الدخول إلى التطبيق واستعراض المنتجات.

#### Acceptance Criteria

1. THE Register_Screen SHALL display input fields for Name, Phone, Email, and Password
2. WHEN the user submits the register form with an empty Name, an empty Phone, an Email that does not match the pattern `^[^@\s]+@[^@\s]+\.[^@\s]+$`, or a Password shorter than 6 characters, THEN THE Register_Screen SHALL display a validation message for each invalid field and skip calling Auth_Service
3. WHEN the user submits the register form with valid Name, Phone, Email, and Password, THE Auth_Service SHALL create a Firebase Auth account using `createUserWithEmailAndPassword`
4. WHEN Auth_Service creates a Firebase Auth account successfully, THE User_Repository SHALL write a document in collection `users` with Document ID equal to the Firebase Auth `uid` and fields `name`, `phone`, and `email`
5. WHEN the account and the user document are created successfully, THE Shopify_App SHALL navigate to Main_Shell with the Home destination selected and remove Register_Screen from the navigation stack
6. IF Firebase Auth returns an error code during registration, THEN THE Register_Screen SHALL display an Arabic message that maps the returned error code to a human readable text and keep the entered Name, Phone, and Email values in the form
7. THE Register_Screen SHALL exclude the Password value from every write operation to Cloud Firestore

### Requirement 2: تسجيل الدخول بالبريد وكلمة المرور

**User Story:** كمستخدم مسجَّل، أريد الدخول ببريدي وكلمة مروري، حتى أصل إلى حسابي والمنتجات.

#### Acceptance Criteria

1. THE Login_Screen SHALL display input fields for Email and Password, a login button, and a link that opens Register_Screen
2. WHEN the user submits the login form with an Email that does not match the pattern `^[^@\s]+@[^@\s]+\.[^@\s]+$` or a Password shorter than 6 characters, THEN THE Login_Screen SHALL display a validation message for each invalid field and skip calling Auth_Service
3. WHEN the user submits the login form with a valid Email and Password, THE Auth_Service SHALL authenticate the user using `signInWithEmailAndPassword`
4. WHILE Auth_Service processes a login request, THE Login_Screen SHALL display a progress indicator inside the login button and reject additional submissions
5. WHEN Auth_Service authenticates the user successfully, THE Shopify_App SHALL navigate to Main_Shell with the Home destination selected and remove Login_Screen from the navigation stack
6. IF Auth_Service returns an authentication error, THEN THE Login_Screen SHALL display an Arabic message that maps the returned error code to a human readable text

### Requirement 3: الدخول السريع بحساب Google

**User Story:** كمستخدم، أريد الدخول بحساب Google بضغطة واحدة، حتى أوفّر وقت كتابة البيانات.

#### Acceptance Criteria

1. THE Login_Screen SHALL display a Google Sign-In button
2. WHEN the user activates the Google Sign-In button, THE Auth_Service SHALL start the Google authentication flow
3. WHEN the Google authentication flow returns a Google credential, THE Auth_Service SHALL exchange that credential for a Firebase Auth session
4. WHEN a Google Sign-In session is established, THE User_Repository SHALL merge a document in collection `users` with Document ID equal to the Firebase Auth `uid` and fields `name`, `phone`, and `email`, using the Google account display name for `name`, the Google account email for `email`, and the existing stored value or an empty string for `phone`
5. IF the user cancels the Google authentication flow, THEN THE Login_Screen SHALL return to its idle state and display no error message
6. IF the Google authentication flow returns an error, THEN THE Login_Screen SHALL display an Arabic error message and return to its idle state

### Requirement 4: استمرار الجلسة والخروج

**User Story:** كمستخدم، أريد أن يتذكرني التطبيق عند إعادة فتحه وأن أستطيع الخروج وقت ما أريد، حتى أتحكم في حسابي.

#### Acceptance Criteria

1. WHEN the Shopify_App starts, THE Shopify_App SHALL initialize Firebase using `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` before rendering Auth_Gate
2. THE Auth_Gate SHALL subscribe to the `authStateChanges` stream of Auth_Service
3. WHILE the `authStateChanges` stream reports a signed-in user, THE Auth_Gate SHALL display Main_Shell
4. WHILE the `authStateChanges` stream reports no signed-in user, THE Auth_Gate SHALL display Login_Screen
5. WHILE the `authStateChanges` stream has emitted no value yet, THE Auth_Gate SHALL display a splash indicator
6. WHEN the user activates the Logout button in Profile_Screen, THE Auth_Cubit SHALL emit the unauthenticated state and THE Shopify_App SHALL display Login_Screen and clear the navigation stack
7. WHEN the user activates the Logout button in Profile_Screen, THE Auth_Service SHALL sign out from Firebase Auth and from the Google Sign-In session
8. IF the sign out operation returns an error, THEN THE Shopify_App SHALL keep Login_Screen displayed and log the error message

### Requirement 5: عرض الملف الشخصي من Cloud Firestore

**User Story:** كمستخدم، أريد رؤية بياناتي المحفوظة (الاسم، الهاتف، البريد)، حتى أتأكد أن حسابي صحيح.

#### Acceptance Criteria

1. WHEN Profile_Screen is opened, THE Profile_Cubit SHALL read the document `users/{uid}` for the current Firebase Auth user
2. WHILE the Profile_Cubit is reading the user document, THE Profile_Screen SHALL display a loading placeholder in place of any previously displayed user data
3. WHEN the user document is read successfully, THE Profile_Screen SHALL display the `name`, `phone`, and `email` field values under a circular avatar that contains the first character of the `name` value
4. IF the document `users/{uid}` is absent, THEN THE Profile_Screen SHALL display an Arabic empty-state message and a retry button
5. IF the read operation returns an error, THEN THE Profile_Screen SHALL display an Arabic error message and a retry button
6. WHEN the user activates the retry button, THE Profile_Cubit SHALL repeat the read of the document `users/{uid}`
7. THE Profile_Screen SHALL display the Logout control as a full-width button with the primary color background and a logout icon

### Requirement 6: جلب أقسام المنتجات وعرضها

**User Story:** كمستخدم، أريد رؤية أقسام المنتجات في الشاشة الرئيسية، حتى أختار القسم الذي يهمني.

#### Acceptance Criteria

1. WHEN Home_Screen is opened, THE Categories_Cubit SHALL request `https://dummyjson.com/products/categories` through Api_Provider
2. THE Category_Model SHALL parse each JSON object of the response into the fields `slug`, `name`, and `url`
3. THE Category_Model SHALL serialize a Category_Model instance into a JSON object containing the keys `slug`, `name`, and `url`
4. FOR ALL Category_Model instances, decoding the JSON produced by the serializer SHALL produce a Category_Model instance equal to the original instance
5. WHILE the Categories_Cubit is loading the categories, THE Home_Screen SHALL display shimmer placeholders
6. WHEN the categories are loaded successfully, THE Home_Screen SHALL display every returned category `name` as a tile in a two-column grid with the name overlaid on the tile
7. IF the categories request fails, THEN THE Home_Screen SHALL display an Arabic error message and a retry button that repeats the request
8. WHEN the categories response contains zero categories, THE Home_Screen SHALL display an Arabic empty-state message
9. WHEN the user selects a category, THE Shopify_App SHALL open Products_Screen and pass the selected category `slug` as the screen argument
10. WHEN Home_Screen is opened, THE Categories_Cubit SHALL request `https://dummyjson.com/products?limit=0&select=id,category,thumbnail` and SHALL associate the first returned `thumbnail` of each product category with the category whose `slug` equals that product `category` value
11. WHERE a category has an associated thumbnail, THE Home_Screen SHALL display that thumbnail as the tile background with a dark gradient overlay behind the category name
12. WHERE a category has no associated thumbnail, THE Home_Screen SHALL display a typographic tile containing the category order number and the category name
13. THE Home_Screen SHALL display every third category tile spanning two grid rows to produce an asymmetrical grid
14. IF the thumbnail request fails, THEN THE Home_Screen SHALL display the category tiles without thumbnails and skip displaying an error message

### Requirement 7: جلب منتجات القسم وعرضها

**User Story:** كمستخدم، أريد رؤية منتجات القسم الذي اخترته بصورها وأسعارها، حتى أتصفح المعروض.

#### Acceptance Criteria

1. WHEN Products_Screen is opened with a category `slug`, THE Products_Cubit SHALL request `https://dummyjson.com/products/category/{slug}` through Api_Provider with the query parameter `select` set to `id,title,description,category,price,rating,thumbnail,images,brand,stock`
2. THE Products_Response_Model SHALL parse the response into the fields `products`, `total`, `skip`, and `limit`
3. THE Product_Model SHALL parse each product JSON object into the fields `id`, `title`, `description`, `category`, `price`, `rating`, `thumbnail`, `images`, `brand`, and `stock`
4. FOR ALL Product_Model instances, decoding the JSON produced by the serializer SHALL produce a Product_Model instance equal to the original instance
5. WHILE the Products_Cubit is loading the products, THE Products_Screen SHALL display shimmer placeholders in a grid layout
6. WHEN the products are loaded successfully, THE Products_Screen SHALL display each product `thumbnail`, `title`, `price`, and `rating` badge in a grid of two columns for widths below 600 logical pixels and three columns for widths of 600 logical pixels and above
7. THE Products_Screen SHALL display the selected category name as a headline above the products grid
8. THE Products_Screen SHALL display each product image inside a container with a 4 by 5 aspect ratio, a `#F5F5F7` background, and a 16 logical pixel corner radius
9. THE Products_Screen SHALL display a favorite toggle control on every product card
10. IF the products request fails, THEN THE Products_Screen SHALL display an Arabic error message and a retry button that repeats the request
11. WHEN the products response contains zero products, THE Products_Screen SHALL display an Arabic empty-state message
12. WHEN the user selects a product, THE Shopify_App SHALL open Product_Details_Screen and pass the selected Product_Model as the screen argument

### Requirement 8: تفاصيل المنتج

**User Story:** كمستخدم، أريد رؤية صورة كبيرة للمنتج ووصفه الكامل وسعره وتقييمه، حتى أتخذ قرار الشراء.

#### Acceptance Criteria

1. WHEN Product_Details_Screen is displayed, THE Product_Details_Screen SHALL display the product image, `title`, full `description`, `price`, and `rating`
2. WHERE the Product_Model `images` list contains more than one entry, THE Product_Details_Screen SHALL display the images in a horizontally swipeable gallery with a page indicator
3. WHERE the Product_Model `images` list is empty, THE Product_Details_Screen SHALL display the `thumbnail` value as the product image and SHALL display the image error widget when that value fails to load
4. THE Product_Details_Screen SHALL render the `rating` value as a five-star indicator together with the numeric value formatted to one decimal place
5. THE Product_Details_Screen SHALL format the `price` value with a currency prefix and two decimal places
6. THE Product_Details_Screen SHALL display a two-cell information grid containing the `brand` value and the `stock` value
7. WHERE the `brand` value is an empty string, THE Product_Details_Screen SHALL display the `category` value in place of the brand
8. THE Product_Details_Screen SHALL display a persistent bottom action button that toggles the favorite state of the displayed product
9. THE Product_Details_Screen SHALL display a back control in the top app bar that returns to the previous screen

### Requirement 9: إدارة الحالة باستخدام Cubit

**User Story:** كمطوّر، أريد كل منطق التطبيق داخل Cubits، حتى يكون الكود قابلًا للاختبار والصيانة ومطابقًا لشروط المشروع.

#### Acceptance Criteria

1. THE Shopify_App SHALL manage authentication, profile, categories, products, search, and favorites logic through Auth_Cubit, Profile_Cubit, Categories_Cubit, Products_Cubit, Search_Cubit, and Favorites_Cubit
2. THE Shopify_App SHALL restrict every network request, every Cloud Firestore operation, and every business logic branch to the Cubit layer and the repository layer
3. THE Shopify_App SHALL exclude `setState` from every widget that performs a network request, a Cloud Firestore operation, or a business logic branch
4. THE Auth_Cubit, Profile_Cubit, Categories_Cubit, Products_Cubit, Search_Cubit, and Favorites_Cubit SHALL each expose a state class hierarchy containing an initial state, a loading state, a success state, and an error state
5. THE Login_Screen, Register_Screen, Home_Screen, Products_Screen, Search_Screen, Favorites_Screen, and Profile_Screen SHALL each implement a state listener for every Cubit they consume, and WHEN a consumed Cubit emits an error state, THE listening screen SHALL display the error message carried by that state

### Requirement 10: تطبيق نظام تصميم Lux-Commerce

**User Story:** كمستخدم، أريد واجهة مطابقة لتصميم ESTUDIO الفاخر بخطوطه وألوانه ومسافاته، حتى يبدو التطبيق احترافيًا ومتناسقًا.

#### Acceptance Criteria

1. THE App_Theme SHALL define a Material 3 theme with a light variant and a dark variant using the Design_Tokens color values `primary #000000`, `onPrimary #FFFFFF`, `surface #F9F9F9`, `surfaceContainerLowest #FFFFFF`, `surfaceContainerLow #F3F3F3`, `surfaceContainer #EEEEEE`, `onSurface #1B1B1B`, `onSurfaceVariant #4C4546`, `secondary #5D5F5F`, `outlineVariant #CFC4C5`, and `error #BA1A1A`
2. THE App_Theme SHALL define the Inter font family through the `google_fonts` package with the text styles displayLarge 48/56/w700/-0.02em, headlineLarge 32/40/w600/-0.01em, headlineMedium 24/32/w600, titleLarge 28/36/w600/-0.01em, bodyLarge 18/28/w400, bodyMedium 16/24/w400, labelLarge 14/20/w600/0.05em, and labelMedium 12/16/w500
3. THE App_Theme SHALL define the corner radius values 12 logical pixels for input fields, 16 logical pixels for buttons and cards, 24 logical pixels for feature containers, and a fully rounded shape for chips
4. THE App_Theme SHALL define the spacing scale 8, 16, 24, 32, and 48 logical pixels and SHALL apply 24 logical pixels as the horizontal screen padding
5. THE Shopify_App SHALL render card and sheet shadows with an offset of 0 by 8 logical pixels, a blur radius of 24 logical pixels, and a black color at 4 percent opacity
6. THE Shopify_App SHALL use icons from the `material_symbols_icons` package for the icons menu, shopping_bag, search, favorite, home, person, arrow_back_ios_new, star, logout, chevron_right, and expand_more
7. THE Shopify_App SHALL apply App_Theme to Login_Screen, Register_Screen, Home_Screen, Products_Screen, Product_Details_Screen, Search_Screen, Favorites_Screen, and Profile_Screen
8. THE Login_Screen, Register_Screen, Home_Screen, Products_Screen, Product_Details_Screen, and Profile_Screen SHALL display the brand title `ESTUDIO` in the top app bar with a translucent background and a backdrop blur
9. THE Shopify_App SHALL load every remote image through `cached_network_image` with a placeholder widget and an error widget
10. THE Home_Screen, Products_Screen, Product_Details_Screen, Search_Screen, Favorites_Screen, and Profile_Screen SHALL render their layouts without overflow for widths from 320 logical pixels to 900 logical pixels
11. THE Shopify_App SHALL support both left-to-right and right-to-left text directions by using direction-aware padding and alignment widgets

### Requirement 11: تهيئة المنصات وقواعد الأمان

**User Story:** كمطوّر، أريد خطوات ربط واضحة لـ Android و iOS وقواعد أمان صحيحة، حتى يعمل التطبيق على الجهازين بأمان.

#### Acceptance Criteria

1. THE pubspec.yaml file SHALL declare the dependencies `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`, `flutter_bloc`, `equatable`, `dio`, `cached_network_image`, `shimmer`, `google_fonts`, and `material_symbols_icons` with pinned version constraints
2. THE Android build configuration SHALL set `minSdk` to a value of 23 or higher
3. THE iOS project SHALL include the file `ios/Runner/GoogleService-Info.plist` downloaded from the Firebase project `shopify-44702`
4. THE iOS Info.plist SHALL declare a URL scheme equal to the `REVERSED_CLIENT_ID` value of the iOS Firebase application
5. THE Firebase project SHALL register the Android debug and release SHA-1 and SHA-256 signing fingerprints and SHALL enable the Email/Password provider and the Google provider
6. THE Firestore_Rules SHALL allow a read operation and a write operation on the document `users/{uid}` and on every document under `users/{uid}/favorites` only when the requesting user is authenticated and the requesting `uid` equals the `uid` segment of the document path
7. THE Shopify_App SHALL pass `flutter analyze` with zero reported errors

### Requirement 12: شريط التنقل السفلي

**User Story:** كمستخدم، أريد التنقل بين الرئيسية والبحث والمفضّلة والحساب من شريط سفلي، حتى أصل لأي قسم بضغطة واحدة.

#### Acceptance Criteria

1. THE Main_Shell SHALL display a bottom navigation bar containing the four destinations Home, Search, Favorites, and Profile as icons without text labels
2. WHEN the user selects a bottom navigation destination, THE Main_Shell SHALL display the screen of that destination and mark its icon as active with a filled icon variant
3. WHEN the user returns to a previously visited destination, THE Main_Shell SHALL restore the scroll position and the loaded data of that destination
4. WHILE a destination screen is displayed, THE Main_Shell SHALL keep the bottom navigation bar visible above the screen content
5. THE Products_Screen and Product_Details_Screen SHALL be pushed above Main_Shell without the bottom navigation bar

### Requirement 13: البحث في الأقسام والمنتجات

**User Story:** كمستخدم، أريد البحث باسم منتج أو قسم، حتى أجد ما أريده بسرعة دون تصفح كل الأقسام.

#### Acceptance Criteria

1. THE Search_Screen SHALL display a search input field with a search icon and an Arabic placeholder
2. WHEN the user changes the search query, THE Search_Cubit SHALL wait 400 milliseconds of input inactivity before starting a search
3. WHEN a search query of at least two characters is submitted, THE Search_Cubit SHALL filter the loaded categories by case-insensitive substring match on the category `name` and the category `slug`
4. WHEN a search query of at least two characters is submitted, THE Search_Cubit SHALL request `https://dummyjson.com/products/search` through Api_Provider with the query parameter `q` set to the search query and the query parameter `select` set to `id,title,description,category,price,rating,thumbnail,images,brand,stock`
5. WHEN search results are received, THE Search_Screen SHALL display the matching categories section above the matching products section
6. WHILE a search request is in progress, THE Search_Screen SHALL display shimmer placeholders
7. WHEN a search query shorter than two characters is entered, THE Search_Cubit SHALL emit an idle state and THE Search_Screen SHALL display an Arabic prompt to type at least two characters
8. WHEN a search returns zero categories and zero products, THE Search_Screen SHALL display an Arabic empty-state message containing the submitted query
9. IF the search request fails, THEN THE Search_Screen SHALL display an Arabic error message and a retry button that repeats the search
10. WHEN the user selects a search result, THE Shopify_App SHALL open Products_Screen for a category result and Product_Details_Screen for a product result
11. WHEN the user activates the search field displayed on Home_Screen, THE Main_Shell SHALL select the Search destination and give input focus to the Search_Screen search field

### Requirement 14: المنتجات المفضّلة

**User Story:** كمستخدم، أريد حفظ منتجات في المفضّلة ورؤيتها في أي جهاز أدخل منه، حتى أرجع لها لاحقًا.

#### Acceptance Criteria

1. WHEN the user activates the favorite control of a product that is not stored as a favorite, THE Favorites_Repository SHALL write a document at `users/{uid}/favorites/{productId}` containing the fields `id`, `title`, `price`, `rating`, `thumbnail`, and `addedAt`
2. WHEN the user activates the favorite control of a product that is stored as a favorite, THE Favorites_Repository SHALL delete the document `users/{uid}/favorites/{productId}`
3. WHEN the favorite state of a product changes, THE Favorites_Cubit SHALL emit the updated favorite identifier set and THE Product_Details_Screen, Products_Screen, and Search_Screen SHALL display the updated favorite control state of that product
4. WHEN Favorites_Screen is opened, THE Favorites_Cubit SHALL read the collection `users/{uid}/favorites` ordered by `addedAt` in descending order
5. WHEN the favorites collection is read successfully, THE Favorites_Screen SHALL display each stored favorite `thumbnail`, `title`, `price`, and `rating`
6. WHEN the favorites collection contains zero documents, THE Favorites_Screen SHALL display an Arabic empty-state message
7. IF a favorite write operation fails, THEN THE Favorites_Cubit SHALL restore the previous favorite state and THE displaying screen SHALL show an Arabic error message
8. WHEN the user signs in again on any device with the same account, THE Favorites_Screen SHALL display the favorites stored for that `uid`
9. WHEN the user signs out, THE Favorites_Cubit SHALL clear the in-memory favorite identifier set

### Requirement 15: مكوّنات الحالات المشتركة وسلوك الشبكة

**User Story:** كمستخدم، أريد أن يعرض لي التطبيق حالة التحميل والخطأ والفراغ بشكل واحد متسق مع إمكانية إعادة المحاولة، حتى لا أواجه شاشات بيضاء أو رسائل غامضة.

#### Acceptance Criteria

1. THE Shopify_App SHALL render every loading state, every error state, and every empty state of Home_Screen, Products_Screen, Search_Screen, Favorites_Screen, and Profile_Screen through App_Loading_View, App_Error_View, and App_Empty_View
2. THE App_Loading_View SHALL render shimmer placeholders whose count, shape, and grid arrangement match the loaded content layout of the screen that displays it
3. THE App_Error_View SHALL display an error icon, the Arabic error message carried by the emitted error state, and a retry button
4. WHEN the user activates the retry button of App_Error_View, THE Cubit that emitted the error state SHALL repeat the operation that produced that error state
5. THE Api_Provider SHALL set the connect timeout, the send timeout, and the receive timeout to 15 seconds each
6. IF an Api_Provider request exceeds a configured timeout, THEN THE Api_Provider SHALL return a Failure carrying the Arabic message «انتهت مهلة الاتصال، تحقّق من الإنترنت وحاول مرة أخرى.»
7. WHERE a screen already displays loaded content, IF a subsequent request for that screen returns an error, THEN THE screen SHALL keep the loaded content displayed and display the Arabic error message in a snack bar
8. THE App_Empty_View SHALL display an icon and the Arabic empty-state message supplied by the calling screen
