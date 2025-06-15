import mongoose from "mongoose";

const { Schema, model } = mongoose;

// Sub-schema for ingredients
const ingredientSchema = new Schema({
  qty: Number,
  name: String,
}, { _id: false });

// Sub-schema for description block
const descriptionBlockSchema = new Schema({
  heading1: String,
  heading2: String,
  body: String,
  image: String,
}, { _id: false });

// Sub-schema for instruction steps
const instructionStepSchema = new Schema({
  description: String,
}, { _id: false });

// Sub-schema for micronutrients
const microNutrientsSchema = new Schema({
  minerals: String,
  vitamins: String,
}, { _id: false });

// Main recipe schema
const recipeSchema = new Schema({
  img: String,

  writer: { type: Schema.Types.ObjectId, ref: "User" },

  status: {
    type: String,
    enum: ["public", "private"],
    default: "private"
  },

  ingredientList: [ingredientSchema],

  descriptionBlock: [descriptionBlockSchema],

  instructionSet: [instructionStepSchema],
  
  calorieCount: Number,
  protein: Number,
  carb: Number,
  fat: Number,

  microNutrients: microNutrientsSchema,

  apiCall: [Schema.Types.Mixed], // generic array of objects

  review: Number,
}, { timestamps: true });

export default model("Recipe", recipeSchema);
