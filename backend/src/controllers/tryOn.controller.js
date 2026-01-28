const TryOn = require('../models/tryOn.model');
const PresetImage = require('../models/presetImage.model');
const Clothing = require('../models/clothing.model');
const Measurement = require('../models/measurement.model');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');

// Initialize Gemini AI
const genAI = process.env.GEMINI_API_KEY 
  ? new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
  : null;

// Helper function to convert image to base64
const imageToBase64 = (imagePath) => {
  const fullPath = path.join(__dirname, '../../', imagePath);
  const imageBuffer = fs.readFileSync(fullPath);
  return imageBuffer.toString('base64');
};

// Simulate AI try-on (will use real Gemini API when key is added)
const simulateAITryOn = async (userImagePath, clothingImagePath, userMeasurements) => {
  // This is a placeholder that will be replaced with real Gemini API calls
  return {
    success: true,
    resultImageUrl: '/uploads/tryon-result-placeholder.jpg',
    fitAnalysis: {
      overallFit: 'good',
      tightAreas: [],
      looseAreas: ['shoulders'],
      recommendations: [
        'The fit looks good overall',
        'Slightly loose around shoulders - consider size down',
        'Length is perfect for your height'
      ],
      confidence: 85
    }
  };
};

// Real Gemini API integration (will be used when API key is configured)
const processWithGemini = async (userImagePath, clothingImagePath, userMeasurements) => {
  if (!genAI) {
    throw new Error('Gemini API key not configured');
  }

  const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash-exp' });

  // Convert images to base64
  const userImageBase64 = imageToBase64(userImagePath);
  const clothingImageBase64 = imageToBase64(clothingImagePath);

  const prompt = `
You are an AI fashion assistant. Analyze how this clothing item would fit on this person.

User's body measurements:
- Chest: ${userMeasurements.chest}cm
- Waist: ${userMeasurements.waist}cm  
- Hips: ${userMeasurements.hips}cm
- Height: ${userMeasurements.height}cm

Tasks:
1. Analyze the fit based on the user's measurements
2. Identify any areas that might be too tight or loose
3. Provide specific recommendations
4. Give an overall fit rating (perfect/good/acceptable/poor)

Respond in JSON format with this structure:
{
  "overallFit": "good",
  "tightAreas": ["area1", "area2"],
  "looseAreas": ["area1"],
  "recommendations": ["recommendation1", "recommendation2"],
  "confidence": 85
}
`;

  const result = await model.generateContent([
    prompt,
    {
      inlineData: {
        mimeType: 'image/jpeg',
        data: userImageBase64
      }
    },
    {
      inlineData: {
        mimeType: 'image/jpeg',
        data: clothingImageBase64
      }
    }
  ]);

  const response = await result.response;
  const text = response.text();
  
  // Parse JSON response
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (jsonMatch) {
    return JSON.parse(jsonMatch[0]);
  }
  
  throw new Error('Failed to parse AI response');
};

// Create AI try-on request
exports.createTryOn = async (req, res) => {
  try {
    const userId = req.userId;
    const { clothingId, presetImageId, clothingImageUrl } = req.body;

    // Validate inputs
    if (!clothingId) {
      return res.status(400).json({
        success: false,
        message: 'Clothing ID is required'
      });
    }

    // Get user's default preset image if not specified
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

    // Get clothing item
    const clothing = await Clothing.findById(clothingId);
    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    // Get user measurements
    const measurements = await Measurement.findOne({ userId });
    if (!measurements) {
      return res.status(404).json({
        success: false,
        message: 'Please add your body measurements first'
      });
    }

    // Create try-on record
    const tryOn = new TryOn({
      userId,
      clothingId,
      presetImageId: presetImage._id,
      clothingImageUrl: clothingImageUrl || clothing.images[0] || '',
      status: 'processing'
    });

    await tryOn.save();

    // Process with AI (async - in production this would be a background job)
    try {
      let aiResult;
      
      if (genAI && process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your_gemini_api_key_here') {
        // Use real Gemini API
        aiResult = await processWithGemini(
          presetImage.imageUrl,
          tryOn.clothingImageUrl,
          {
            chest: measurements.chest,
            waist: measurements.waist,
            hips: measurements.hips,
            height: measurements.height
          }
        );
      } else {
        // Use simulation
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

      // Update try-on record
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

    // Return response
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

    // Optionally delete result image file
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