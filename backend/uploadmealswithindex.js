const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

const serviceAccount = require('./ymmify-firebase-adminsdk-fbsvc-e207f5917e.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const mealsFilePath = path.join(__dirname, 'data', 'recipes.json');
const mealsData = JSON.parse(fs.readFileSync(mealsFilePath, 'utf8'));

function generateSearchIndex(name) {
  const index = [];
  const lowerName = name.toLowerCase();
  for (let i = 1; i <= lowerName.length; i++) {
    index.push(lowerName.slice(0, i));
  }
  return index;
}

async function uploadMeals() {
  const collectionRef = db.collection('recipes');

  // 1. Get all existing IDs and names from Firestore once
  const existingDocs = await collectionRef.get();
  const existingIds = new Set();
  const existingNames = new Set();

  existingDocs.forEach(doc => {
    const data = doc.data();
    existingIds.add(doc.id);
    if (data.name) {
      existingNames.add(data.name.toLowerCase());
    }
  });

  // 2. Filter mealsData to exclude duplicates by id or name
  const newMeals = mealsData.filter(meal => 
    !existingIds.has(meal.id) && !existingNames.has(meal.name.toLowerCase())
  );

  if (newMeals.length === 0) {
    console.log('No new meals to upload!');
    return;
  }

  // 3. Batch upload new meals with searchIndex
  let batch = db.batch();
  let batchCount = 0;

  for (const meal of newMeals) {
    const docRef = collectionRef.doc(meal.id);
    const mealWithIndex = {
      ...meal,
      searchIndex: generateSearchIndex(meal.name),
    };
    batch.set(docRef, mealWithIndex);
    batchCount++;

    if (batchCount % 450 === 0) {
      await batch.commit();
      console.log(`Committed batch of 450 meals`);
      batch = db.batch();
    }
  }

  if (batchCount % 450 !== 0) {
    await batch.commit();
    console.log(`Committed final batch of ${batchCount % 450} meals`);
  }

  console.log(`✅ Uploaded ${batchCount} new meals.`);
}

uploadMeals().catch(err => {
  console.error('Upload failed:', err);
});
