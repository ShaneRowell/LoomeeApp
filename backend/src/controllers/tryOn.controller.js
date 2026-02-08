const TryOn = require('../models/tryOn.model');
const PresetImage = require('../models/presetImage.model');
const Clothing = require('../models/clothing.model');
const Measurement = require('../models/measurement.model');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');

// Initialize Gemini AI
console.log('🔑 Gemini API Key:', process.env.GEMINI_API_KEY ? 'Loaded ✅' : 'Not found ❌');
console.log('🔑 Key starts with:', process.env.GEMINI_API_KEY ? process.env.GEMINI_API_KEY.substring(0, 15) + '...' : 'N/A');

const genAI = process.env.GEMINI_API_KEY 
  ? new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
  : null;

// Helper function to convert image to base64
const imageToBase64 = (imagePath) => {
  const fullPath = path.join(__dirname, '../../', imagePath);
  const imageBuffer = fs.readFileSync(fullPath);
  return imageBuffer.toString('base64');
};

// Simulate AI try-on (fallback)
const simulateAITryOn = async (userImagePath, clothingImagePath, userMeasurements) => {
  return {
    success: true,
    resultImageUrl: '/uploads/tryon-result-placeholder.jpg',
    fitAnalysis: {
      overallFit: 'good',
      tightAreas: [],
      looseAreas: ['shoulders'],
      recommendations: [
        'The fit looks good overall based on your measurements',
        'Chest: ' + userMeasurements.chest + 'cm should fit comfortably',
        'Consider your preferred fit style when ordering'
      ],
      confidence: 85
    }
  };
};

// Real Gemini API integration
const processWithGemini = async (userImagePath, clothingImagePath, userMeasurements, clothingDetails) => {
  if (!genAI) {
    throw new Error('Gemini API key not configured');
  }

  try {
    const model = genAI.getGenerativeModel({ model: 'models/gemini-2.5-flash' });

    // Read clothing image
    const clothingImageBase64 = imageToBase64(clothingImagePath);

    const prompt = `You are an AI fashion assistant analyzing clothing items for fit recommendations.

Analyze this clothing item and provide fit advice for a person with these measurements:
- Chest: ${userMeasurements.chest}cm
- Waist: ${userMeasurements.waist}cm
- Hips: ${userMeasurements.hips}cm
- Height: ${userMeasurements.height}cm

Clothing Details:
- Name: ${clothingDetails.name}
- Category: ${clothingDetails.category}
- Brand: ${clothingDetails.brand}

Tasks:
1. Describe the clothing item you see
2. Based on the measurements provided, suggest the best size
3. Identify any potential fit issues (too tight/loose areas)
4. Provide 2-3 specific recommendations

Respond ONLY with valid JSON in this exact format (no markdown, no backticks):
{
  "clothingDescription": "brief description of the item",
  "recommendedSize": "S/M/L/XL",
  "overallFit": "perfect/good/acceptable/poor",
  "tightAreas": ["area1", "area2"],
  "looseAreas": ["area1"],
  "recommendations": ["recommendation1", "recommendation2", "recommendation3"],
  "confidence": 85
}`;

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: clothingImageBase64
        }
      }
    ]);

    const response = await result.response;
    const text = response.text();
    
    console.log('🤖 Gemini raw response:', text);

    // Extract JSON from response (remove markdown if present)
    let jsonText = text.trim();
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/```\n?/g, '');
    }

    const aiAnalysis = JSON.parse(jsonText);

    return {
      success: true,
      resultImageUrl: '/uploads/tryon-result-placeholder.jpg',
      fitAnalysis: {
        overallFit: aiAnalysis.overallFit || 'good',
        tightAreas: aiAnalysis.tightAreas || [],
        looseAreas: aiAnalysis.looseAreas || [],
        recommendations: aiAnalysis.recommendations || [],
        confidence: aiAnalysis.confidence || 80
      },
      aiDescription: aiAnalysis.clothingDescription,
      recommendedSize: aiAnalysis.recommendedSize
    };

  } catch (error) {
    console.error('Gemini API error:', error);
    throw error;
  }
};

// Create AI try-on request
exports.createTryOn = async (req, res) => {
  try {
    const userId = req.userId;
    const { clothingId, presetImageId, clothingImageUrl } = req.body;

    if (!clothingId) {
      return res.status(400).json({
        success: false,
        message: 'Clothing ID is required'
      });
    }

    let presetImage;
    if (presetImageId) {
      presetImage = await PresetImage.findOne({ _id: presetImageId, userId });
    } else {
      presetImage = await PresetImage.findOne({ userId, isDefault: true });
    }

    if (!presetImage) {
      return res.status(404).json({
        success: false,
        message: 'Please upload a preset image first'
      });
    }

    const clothing = await Clothing.findById(clothingId);
    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    const measurements = await Measurement.findOne({ userId });
    if (!measurements) {
      return res.status(404).json({
        success: false,
        message: 'Please add your body measurements first'
      });
    }

    const tryOn = new TryOn({
      userId,
      clothingId,
      presetImageId: presetImage._id,
      clothingImageUrl: clothingImageUrl || clothing.images[0] || '',
      status: 'processing'
    });

    await tryOn.save();

    try {
      let aiResult;
      
      if (genAI && process.env.GEMINI_API_KEY) {
        console.log('🤖 Using Gemini AI for analysis...');
        aiResult = await processWithGemini(
          presetImage.imageUrl,
          tryOn.clothingImageUrl,
          {
            chest: measurements.chest,
            waist: measurements.waist,
            hips: measurements.hips,
            height: measurements.height
          },
          {
            name: clothing.name,
            category: clothing.category,
            brand: clothing.brand
          }
        );
      } else {
        console.log('🔄 Using simulation mode...');
        aiResult = await simulateAITryOn(
          presetImage.imageUrl,
          tryOn.clothingImageUrl,
          {
            chest: measurements.chest,
            waist: measurements.waist,
            hips: measurements.hips,
            height: measurements.height
          }
        );
      }

      tryOn.resultImageUrl = aiResult.resultImageUrl;
      tryOn.fitAnalysis = aiResult.fitAnalysis;
      tryOn.status = 'completed';
      tryOn.completedAt = Date.now();
      
      await tryOn.save();

    } catch (aiError) {
      console.error('AI processing error:', aiError);
      tryOn.status = 'failed';
      tryOn.errorMessage = aiError.message;
      await tryOn.save();
    }

    res.status(201).json({
      success: true,
      message: 'Try-on request created successfully',
      tryOn: await TryOn.findById(tryOn._id)
        .populate('clothingId', 'name brand price')
        .populate('presetImageId', 'imageUrl imageType')
    });

  } catch (error) {
    console.error('Create try-on error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating try-on request',
      error: error.message
    });
  }
};

// Get try-on result by ID
exports.getTryOnById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    const tryOn = await TryOn.findOne({ _id: id, userId })
      .populate('clothingId', 'name brand price images')
      .populate('presetImageId', 'imageUrl imageType');

    if (!tryOn) {
      return res.status(404).json({
        success: false,
        message: 'Try-on not found'
      });
    }

    res.json({
      success: true,
      tryOn
    });
  } catch (error) {
    console.error('Get try-on error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching try-on',
      error: error.message
    });
  }
};

// Get all try-ons for user
exports.getUserTryOns = async (req, res) => {
  try {
    const userId = req.userId;
    const { status } = req.query;

    let filter = { userId };
    if (status) filter.status = status;

    const tryOns = await TryOn.find(filter)
      .populate('clothingId', 'name brand price images')
      .populate('presetImageId', 'imageUrl imageType')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: tryOns.length,
      tryOns
    });
  } catch (error) {
    console.error('Get user try-ons error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching try-ons',
      error: error.message
    });
  }
};

// Delete try-on
exports.deleteTryOn = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    const tryOn = await TryOn.findOneAndDelete({ _id: id, userId });

    if (!tryOn) {
      return res.status(404).json({
        success: false,
        message: 'Try-on not found'
      });
    }

    if (tryOn.resultImageUrl && tryOn.resultImageUrl.startsWith('/uploads/')) {
      const filePath = path.join(__dirname, '../../', tryOn.resultImageUrl);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    res.json({
      success: true,
      message: 'Try-on deleted successfully'
    });
  } catch (error) {
    console.error('Delete try-on error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting try-on',
      error: error.message
    });
  }
};