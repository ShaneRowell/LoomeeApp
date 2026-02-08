const { GoogleGenerativeAI } = require('@google/generative-ai');

async function testWithFetch() {
  try {
    console.log('Testing with direct API call (v1 endpoint)...\n');
    
    const apiKey = 'AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys';
    const url = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';
    
    const response = await fetch(`${url}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: 'Say hello' }]
        }]
      })
    });
    
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ v1 API WORKS!');
      console.log('Response:', data.candidates[0].content.parts[0].text);
    } else {
      console.log('❌ v1 API Failed');
      console.log('Status:', response.status);
      console.log('Error:', JSON.stringify(data, null, 2));
    }
    
  } catch (error) {
    console.log('❌ Error:', error.message);
  }
}

testWithFetch();