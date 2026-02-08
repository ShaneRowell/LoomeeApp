const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI('AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys');

async function listModels() {
  try {
    console.log('Fetching available Gemini models...\n');
    
    const models = await genAI.listModels();
    
    console.log('📋 Available Models:\n');
    for await (const model of models) {
      console.log(`✅ ${model.name}`);
      console.log(`   Supports: ${model.supportedGenerationMethods.join(', ')}`);
      console.log('');
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

listModels();