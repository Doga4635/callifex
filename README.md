# Callifex demo

Flutter ile hazırlanmış, önceden tanımlı altı kariyer öğrenme yolunu Firestore'dan
gösteren ve Firebase AI Logic üzerinden Gemini rehber sohbeti sunan mobil demo.
Öğrenme yolları yapay zekâ tarafından oluşturulmaz veya değiştirilmez.

## İçerik

- Yazılım: Frontend Geliştirici ve Python ile Veri Analizi
- UI/UX Tasarım: Ürün UI/UX Tasarımcısı ve UX Araştırmacısı
- Dijital Pazarlama: Performans Pazarlama Uzmanı ve İçerik Pazarlama Uzmanı
- Her yol için adım adım modüller, içerik/kurs önerileri ve uygulama projeleri
- Seçilen yola göre bağlam alan, Türkçe Gemini rehber sohbeti

## Gereksinimler

- Flutter SDK ve FlutterFire CLI
- Firebase projesi
- Node.js 20 veya üzeri; Firestore senaryolarını yüklemek için
- Firebase projesi için Application Default Credentials veya servis hesabı
- Firebase CLI (`firebase-tools`) ve seed işlemi için Google Cloud CLI (`gcloud`)

## Kurulum

1. Android ve iOS platform klasörleri henüz oluşturulmadıysa proje kökünde
   `flutter create --platforms=android,ios .` komutunu çalıştırın.
2. Firebase Console'da proje oluşturun; iOS ve Android uygulamalarını ekleyin.
3. Firebase CLI'ı `npm install -g firebase-tools` ile kurup `firebase login` ile
   giriş yapın. FlutterFire CLI'ı `dart pub global activate flutterfire_cli` ile
   kurun. Proje kökünde `flutterfire configure` komutunu çalıştırın. Üretilen
   `lib/firebase_options.dart` dosyası uygulama başlangıcında kullanılır.
4. Firestore Database'i oluşturun ve
   `firebase deploy --project proje-kimliginiz --only firestore:rules` komutuyla
   `firestore.rules` dosyasını yayımlayın. Öğrenme yolları herkese açık okunur;
   istemci tarafından yazılamaz.
5. Firebase Console'daki AI Logic bölümünden Gemini Developer API sağlayıcısını
   etkinleştirin. Gemini API anahtarını uygulama koduna alıp elle yazmayın:
   Firebase AI Logic, sağlayıcıyı etkinleştirirken Firebase projesini ve
   SDK'nın kullanacağı anahtarı yönetir. `flutterfire configure` ile üretilen
   `lib/firebase_options.dart` uygulamanın Firebase yapılandırmasını sağlar;
   `guide_chat_service.dart` içine ayrıca bir Gemini anahtarı eklenmez.
   Kullanılan model adı `gemini-3.7-flash` olup [Firebase AI Logic model
   listesinde](https://firebase.google.com/docs/ai-logic/models) desteklenir.
6. Senaryoları güvenli biçimde yüklemek için Firebase Admin SDK kimlik
   doğrulaması gereken bir terminalde:

   ```sh
   # Google Cloud CLI kurulu olmalı: https://cloud.google.com/sdk/docs/install
   gcloud auth application-default login
   cd tools
   npm install
   npm run seed
   ```

   `firebase login` yalnızca Firebase CLI'ı yetkilendirir; Admin SDK'nın
   Firestore'a yazabilmesi için tek başına yeterli değildir. `gcloud` komutu
   bulunmuyorsa önce Google Cloud CLI'ı kurun. Alternatif olarak servis hesabı
   kimlik bilgileri kullanıp dosyanın yolunu `GOOGLE_APPLICATION_CREDENTIALS`
   olarak ayarlayın.
   Seeder proje kimliğini `firebase.json` içindeki FlutterFire ayarından okur.
   İsterseniz `FIREBASE_PROJECT_ID` ile üzerine yazabilirsiniz. Servis hesabı
   kullanıyorsanız anahtar dosyasını repoya koymayın; yolunu
   `GOOGLE_APPLICATION_CREDENTIALS` ortam değişkeniyle verin. Seed komutu
   `learningPaths` koleksiyonundaki aynı kimlikli altı belgeyi günceller.
7. Proje kökünde `flutter pub get` ve `flutter run` çalıştırın.

Gerçek kullanıcılara açmadan önce Firebase App Check'i yapılandırıp Gemini
kullanımını Firebase Console'dan izleyin.

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
  modules: [
    {
      title: string,
      description: string,
      lessons: string[],
      project: string
    }
  ]
```

## Doğrulama

Firebase yapılandırmasını tamamladıktan sonra `flutter analyze` ve
`flutter test` komutlarını çalıştırın. Testler örnek veri sayısını, kategori
dağılımını ve model doğrulamasını kontrol eder.
