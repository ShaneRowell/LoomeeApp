const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI('AIzaSyD5l1eyGICusSJDMAeKFoFv3e1o7u3UQaQ');

async function test() {
  try {
    console.log('Testing Gemini API...');
    const model = genAI.getGenerativeModel({ model: 'gemini-exp-1206' });
    const result = await model.generateContent('Say hello in one sentence!');
    const response = await result.response;
    console.log('✅ SUCCESS! Gemini API works!');
    console.log('Response:', response.text());
  } catch (error) {
    console.log('❌ FAILED!');
    console.log('Error:', error.message);
  }
}

test();