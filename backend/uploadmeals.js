// uploadMeals.js

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Load service account
const serviceAccount = require('./ymmify-firebase-adminsdk-fbsvc-e207f5917e.json');

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Read the meals JSON file
const mealsFilePath = path.join(__dirname, 'data', 'food_dataset_final.json');
const mealsData = JSON.parse(fs.readFileSync(mealsFilePath, 'utf8'));

// Upload to Firestore
async function uploadMeals() {
  const batch = db.batch();
  const collectionRef = db.collection('meals');

  mealsData.forEach((meal) => {
    const docRef = collectionRef.doc(meal.id); // use your custom ID
    batch.set(docRef, meal);
  });

  await batch.commit();
  console.log(`✅ Uploaded ${mealsData.length} meals to Firestore`);
}

// Run the upload
uploadMeals().catch((err) => {
  console.error('❌ Failed to upload:', err);
});
