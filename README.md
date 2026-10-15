# Callifex demo

Önceden hazırlanmış 12 kariyer öğrenme yolunu Firestore'dan gösteren Flutter
demo uygulaması. Öğrenme yolları AI tarafından üretilmez veya değiştirilmez.
Rehber sohbeti Groq'un REST API'sine Flutter uygulamasından doğrudan istek atar;
sohbet geçmişi ekran açık kaldığı sürece uygulama belleğinde tutulur ve Firebase'e
gönderilmez. Firestore yalnızca öğrenme yolları içindir.

## İçerik

- Yazılım: Backend, mobil uygulama, siber güvenlik ve oyun geliştirme
- UI/UX Tasarım: Tasarım sistemleri, motion tasarım, UX yazarlığı ve design thinking
- Dijital Pazarlama: SEO, sosyal medya, growth hacking ve e-posta pazarlaması
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
dosyasındaki yolları Firestore'a yüklemek için Google Cloud CLI ve
Application Default Credentials gerekir:

```sh
gcloud auth application-default login
cd tools
npm install
npm run seed
```

Bu işlem JSON'daki her yolu `id` alanını belge kimliği olarak kullanarak
`learningPaths` koleksiyonuna yazar veya aynı kimlikteki belgeyi günceller.
JSON'dan kaldırılan belgeler Firestore'dan silinmez. Firestore
kurallarını yayımlamak için proje kökünde:

```sh
firebase deploy --project callifex-38e38 --only firestore:rules
```

Kullanıcının seçtiği yollar Firebase'e yazılmaz; seçilen yol kimlikleri cihazda
`SharedPreferences` ile saklanır. Bu yüzden uygulama ilk açıldığında kişisel yol
listesi boştur, eklenen yollar ana sayfa ve “Yollarım” ekranında görünür ve aynı
cihazdaki sonraki açılışlarda korunur. “Yollarım” ekranındaki silme düğmesi
seçilen yolu yalnızca bu cihazın listesinden kaldırır; Firestore kataloğu
değişmez. Yol ekleme formu Firestore kataloğundaki
sektör, zorluk ve toplam süre seçeneklerini kullanır; üç alanın tam eşleşmesi
aranır. Eşleşme bulunamazsa kullanıcıya bildirim gösterilir. Mevcut örnek
süreler 7, 8, 10 ve 12 haftadır.

## Firestore veri modeli

`assets/data/learning_paths.json`, başlangıç belgelerinin kaynağıdır. Seeder
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
