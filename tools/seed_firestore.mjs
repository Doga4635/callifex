import { readFile } from 'node:fs/promises';
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const firebaseConfig = JSON.parse(
  await readFile(new URL('../firebase.json', import.meta.url), 'utf8'),
);
const projectId =
  process.env.FIREBASE_PROJECT_ID ??
  firebaseConfig.flutter?.platforms?.android?.default?.projectId;
if (!projectId) {
  throw new Error(
    'Firebase proje kimliği firebase.json içinde bulunamadı. '
      + 'FIREBASE_PROJECT_ID ortam değişkeniyle belirtin.',
  );
}

const sourceUrl = new URL('../assets/data/learning_paths.json', import.meta.url);
const scenarios = JSON.parse(await readFile(sourceUrl, 'utf8'));
if (!Array.isArray(scenarios) || scenarios.length !== 6) {
  throw new Error('Seed dosyasında tam olarak 6 öğrenme yolu bulunmalı.');
}

const expectedTracks = ['Yazılım', 'UI/UX Tasarım', 'Dijital Pazarlama'];
for (const track of expectedTracks) {
  const count = scenarios.filter((scenario) => scenario.track === track).length;
  if (count !== 2) {
    throw new Error(`"${track}" için 2 senaryo bekleniyordu; bulunan: ${count}.`);
  }
}

const ids = scenarios.map((scenario) => scenario.id);
if (
  ids.some((id) => typeof id !== 'string' || id.trim().length === 0) ||
  new Set(ids).size !== ids.length
) {
  throw new Error('Her öğrenme yolu benzersiz ve boş olmayan bir id içermeli.');
}

initializeApp({
  credential: applicationDefault(),
  projectId,
});

const db = getFirestore();
const batch = db.batch();
for (const { id, ...scenario } of scenarios) {
  batch.set(db.collection('learningPaths').doc(id), scenario);
}

await batch.commit();
console.log('Firestore için 6 öğrenme yolu yüklendi.');
