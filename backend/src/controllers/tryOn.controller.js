const TryOn = require('../models/tryOn.model');
const PresetImage = require('../models/presetImage.model');
const Clothing = require('../models/clothing.model');
const Measurement = require('../models/measurement.model');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const Replicate = require('replicate');
const fs = require('fs');
const path = require('path');

// Initialize Gemini AI — falls back to simulation mode if API key is absent
console.log('🔑 Gemini API Key:', process.env.GEMINI_API_KEY ? 'Loaded ✅' : 'Not found ❌');

const genAI = process.env.GEMINI_API_KEY 
  ? new GoogleGenerativeAI(process.env.GEMINI_API_KEY)
  : null;

// Initialize Replicate
const replicate = process.env.REPLICATE_API_TOKEN
  ? new Replicate({ auth: process.env.REPLICATE_API_TOKEN })
  : null;

/**
 * Converts an image path or URL to a base64 string.
 * Supports both Cloudinary URLs (fetched via HTTP) and local file paths.
 */
const imageToBase64 = async (imagePath) => {
  // Check if it's a Cloudinary URL
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    // Download from Cloudinary
    const response = await fetch(imagePath);
    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer).toString('base64');
  } else {
    // Local file (for backward compatibility)
    const fullPath = path.join(__dirname, '../../', imagePath);
    const imageBuffer = fs.readFileSync(fullPath);
    return imageBuffer.toString('base64');
  }
};

/**
 * Uses Gemini AI to generate a brief description of a garment from its image.
 * Falls back to "clothing item" if Gemini is unavailable.
 */
const describeGarment = async (clothingImageUrl) => {
  if (!genAI) {
    console.log('⚠️ Gemini not configured, using fallback description');
    return 'clothing item';
  }

  try {
    const model = genAI.getGenerativeModel({ model: 'models/gemini-2.5-flash' });
    
    const imageBase64 = await imageToBase64(clothingImageUrl);
    
    const prompt = `Describe this clothing item in 1-3 words for a virtual try-on system. 
Examples: "red dress", "blue jeans", "white shirt", "black skirt", "denim jacket".
Be specific about the type of garment. Respond with ONLY the description, nothing else.`;
    
    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: imageBase64
        }
      }
    ]);
    
    const description = result.response.text().trim().replace(/['"]/g, '');
    console.log('🤖 Gemini garment description:', description);
    return description;
    
  } catch (error) {
    console.error('Gemini garment description error:', error);
    return 'clothing item';
  }
};

/**
 * Generates a virtual try-on image using Replicate's IDM-VTON model.
 * Returns the URL of the generated image, or null if unavailable/failed.
 */
const processWithReplicate = async (humanImageUrl, garmentImageUrl, garmentDescription) => {
  if (!replicate) {
    console.log('⚠️ Replicate not configured, skipping virtual try-on generation');
    return null;
  }

  try {
    console.log('🎨 Starting Replicate virtual try-on generation...');
    console.log('   Human image:', humanImageUrl);
    console.log('   Garment image:', garmentImageUrl);
    console.log('   Description:', garmentDescription);

    const prediction = await replicate.predictions.create({
      version: "c871bb9b046607b680449ecbae55fd8c6d945e0a1948644bf2361b3d021d3ff4",
      input: {
        human_img: humanImageUrl,
        garm_img: garmentImageUrl,
        garment_des: garmentDescription
      }
    });

    console.log('⏳ Waiting for Replicate to complete (30-60 seconds)...');
    const completed = await replicate.wait(prediction);

    if (completed.status === 'succeeded' && completed.output) {
      console.log('✅ Replicate virtual try-on generated:', completed.output);
      return completed.output;
    } else {
      console.error('❌ Replicate failed:', completed.error || 'Unknown error');
      return null;
    }

  } catch (error) {
    console.error('Replicate error:', error);
    return null;
  }
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

// Real Gemini API integration for fit analysis
const processWithGemini = async (userImagePath, clothingImagePath, userMeasurements, clothingDetails) => {
  if (!genAI) {
    throw new Error('Gemini API key not configured');
  }

  try {
    const model = genAI.getGenerativeModel({ model: 'models/gemini-2.5-flash' });

    const clothingImageBase64 = await imageToBase64(clothingImagePath);

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
    
    console.log('🤖 Gemini fit analysis raw response:', text);

    // Gemini may wrap JSON in markdown code fences — strip them before parsing
    let jsonText = text.trim();
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.replace(/```json\n?/g, '').replace(/```\n?/g, '');
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/```\n?/g, '');
    }

    const aiAnalysis = JSON.parse(jsonText);

    return {
      success: true,
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
      let geminiResult;
      let replicateImageUrl = null;
      
      // Step 1: Gemini fit analysis
      if (genAI && process.env.GEMINI_API_KEY) {
        console.log('🤖 Using Gemini AI for fit analysis...');
        geminiResult = await processWithGemini(
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
        console.log('🔄 Using simulation mode for fit analysis...');
        geminiResult = await simulateAITryOn(
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

      // Step 2: Get garment description using Gemini
      const garmentDescription = await describeGarment(tryOn.clothingImageUrl);

      // Step 3: Generate virtual try-on image with Replicate
      if (replicate && process.env.REPLICATE_API_TOKEN) {
        replicateImageUrl = await processWithReplicate(
          presetImage.imageUrl,
          tryOn.clothingImageUrl,
          garmentDescription
        );
      }

      // Save results
      tryOn.resultImageUrl = replicateImageUrl || '/uploads/tryon-result-placeholder.jpg';
      tryOn.fitAnalysis = geminiResult.fitAnalysis;
      tryOn.status = 'completed';
      tryOn.completedAt = Date.now();
      
      await tryOn.save();

    } catch (aiError) {
      console.error('AI processing error:', aiError.message);
      tryOn.status = 'failed';
      tryOn.errorMessage = aiError.message;
      tryOn.completedAt = Date.now();
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

// Get all try-ons for user (optionally filtered by status)
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