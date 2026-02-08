const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI('AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys');

const modelsToTest = [
  'gemini-1.5-flash-latest',
  'gemini-1.5-pro-latest', 
  'gemini-1.5-flash-001',
  'gemini-1.5-pro-001',
  'gemini-1.0-pro',
  'gemini-pro',
  'models/gemini-1.5-flash',
  'models/gemini-1.5-pro'
];

async function testModel(modelName) {
  try {
    console.log(`Testing: ${modelName}...`);
    const model = genAI.getGenerativeModel({ model: modelName });
    const result = await model.generateContent('Say hello');
    const response = await result.response;
    console.log(`✅ ${modelName} WORKS!`);
    console.log(`   Response: ${response.text().substring(0, 50)}...\n`);
    return true;
  } catch (error) {
    console.log(`❌ ${modelName} failed: ${error.message.substring(0, 100)}\n`);
    return false;
  }
}

async function testAll() {
  console.log('🔍 Testing available Gemini models...\n');
  
  for (const modelName of modelsToTest) {
    await testModel(modelName);
  }
  
  console.log('✅ Done testing!');
}

testAll();