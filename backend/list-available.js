async function listModels() {
  try {
    console.log('Fetching list of available models...\n');
    
    const apiKey = 'AIzaSyCbxcleIDUk_ULdfF8DVOKapraSwzzmeys';
    const url = `https://generativelanguage.googleapis.com/v1/models?key=${apiKey}`;
    
    const response = await fetch(url);
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ Available Models:\n');
      data.models.forEach(model => {
        console.log(`📦 ${model.name}`);
        console.log(`   Display Name: ${model.displayName}`);
        console.log(`   Supported Methods: ${model.supportedGenerationMethods.join(', ')}`);
        console.log('');
      });
    } else {
      console.log('❌ Failed to list models');
      console.log('Error:', JSON.stringify(data, null, 2));
    }
    
  } catch (error) {
    console.log('❌ Error:', error.message);
  }
}

listModels();