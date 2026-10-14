# Callifex demo

Önceden hazırlanmış altı kariyer öğrenme yolunu Firestore'dan gösteren Flutter
demo uygulaması. Öğrenme yolları AI tarafından üretilmez veya değiştirilmez.
Rehber sohbeti Groq'un REST API'sine Flutter uygulamasından doğrudan istek atar;
sohbet geçmişi ekran açık kaldığı sürece uygulama belleğinde tutulur ve Firebase'e
gönderilmez. Firestore yalnızca öğrenme yolları içindir.

## İçerik

- Yazılım: Frontend Geliştirici ve Python ile Veri Analizi
- UI/UX Tasarım: Ürün UI/UX Tasarımcısı ve UX Araştırmacısı
- Dijital Pazarlama: Performans Pazarlama Uzmanı ve İçerik Pazarlama Uzmanı
- Her yol için adım adım modüller, içerik/kurs önerileri ve uygulama projeleri
- Seçilen yola göre bağlam alan Türkçe Groq rehber sohbeti

## Kurulum

1. Firebase Console'daki mevcut Android/iOS uygulamalarınızı ve
   `lib/firebase_options.dart` yapılandırmanızı kullanın. Firestore öğrenme
   yolları için Firebase yapılandırması eskisi gibi gereklidir.
2. Groq API anahtarı için [Groq Console API Keys](https://console.groq.com/keys)
   sayfasından bir key oluşturun.
3. Proje kökünde `.env.example` dosyasını `.env` olarak kopyalayın ve
   `GROQ_API_KEY` değerini kendi anahtarınızla değiştirin. Dosya, Flutter'ın
   `--dart-define-from-file` seçeneği için JSON biçimindedir:

   ```sh
   cp .env.example .env
   ```

   Önceki Firebase Functions kurulumunda anahtarı `functions/.env` içine
   kaydettiyseniz, o dosyadaki key değerini yerel `.env` dosyasındaki
   `GROQ_API_KEY` alanına taşıyın. Uygulama artık `functions/.env` dosyasını
   okumaz; bu dosyayı anahtarı taşıdığınızı doğrulayana kadar silmeyin.

4. Bağımlılıkları yükleyip uygulamayı `.env` dosyasıyla başlatın:

   ```sh
   flutter pub get
   flutter run --dart-define-from-file=.env
   ```

   `.env` Git tarafından yok sayılır. Uygulamayı başka yolla başlatırsanız,
   sohbet servisi Groq anahtarının eksik olduğunu açıkça bildirir.
5. Üretim build'inde de aynı key'i `--dart-define-from-file` ile vermeniz gerekir.
   **Önemli:** Doğrudan mobil istemciden Groq'a giden API key, `.env` Git'te
   tutulsa bile derlenmiş uygulamadan çıkarılabilir. Bu yöntem demo/kişisel test
   içindir; herkese dağıtılan üretim uygulamasında anahtarı korumaz ve kullanım
   limitlerini istismar riskinden korumaz.

### Firestore'daki öğrenme yolları

Firestore kullanımı chatbot'tan bağımsız olarak devam eder. `assets/data/learning_paths.json`
dosyasındaki altı sabit yolu Firestore'a yüklemek için Google Cloud CLI ve
Application Default Credentials gerekir:

```sh
gcloud auth application-default login
cd tools
npm install
npm run seed
```

Bu işlem `learningPaths` koleksiyonundaki belgeleri günceller. Firestore
kurallarını yayımlamak için proje kökünde:

```sh
firebase deploy --project callifex-38e38 --only firestore:rules
```

## Firestore veri modeli

`assets/data/learning_paths.json`, altı başlangıç belgesinin kaynağıdır. Seeder
bu dosyadaki `id` alanını Firestore belge kimliği olarak kullanır; uygulamanın
Firestore'dan beklediği alanlar:

```text
learningPaths/{id}
  title: string
  track: string
  level: string
  duration: string
  summary: string
  color: string (#RRGGBB)
  order: number
  modules: [{ title, description, lessons: string[], project }]
```

## Testler

```sh
flutter analyze
flutter test
```
