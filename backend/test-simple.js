const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI('AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys');

async function test() {
  try {
    console.log('Testing Gemini API...\n');
    console.log('API Key:', 'AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys');
    console.log('Model:', 'gemini-1.5-flash');
    console.log('\nAttempting to generate content...\n');
    
    const model = genAI.getGenerativeModel({ model: 'models/gemini-2.5-flash' });
    const result = await model.generateContent('Say hello');
    const response = await result.response;
    
    console.log('✅ SUCCESS!');
    console.log('Response:', response.text());
    
  } catch (error) {
    console.log('❌ FAILED\n');
    console.log('Full Error Object:');
    console.log(JSON.stringify(error, null, 2));
    console.log('\nError Details:');
    console.log('Message:', error.message);
    console.log('Status:', error.status);
    console.log('Status Text:', error.statusText);
    console.log('Error Details:', error.errorDetails);
  }
}

test();