const Measurement = require('../models/measurement.model');
const Clothing = require('../models/clothing.model');

// Size recommendation algorithm
const calculateSizeRecommendation = (userMeasurements, clothingSizes) => {
  const recommendations = [];

  clothingSizes.forEach(sizeOption => {
    const sizeMeasurements = sizeOption.measurements;
    
    // Calculate fit scores for each measurement
    let totalScore = 0;
    let measurementCount = 0;

    // Chest fit score
    if (sizeMeasurements.chest && userMeasurements.chest) {
      const chestDiff = Math.abs(sizeMeasurements.chest - userMeasurements.chest);
      const chestScore = Math.max(0, 100 - (chestDiff * 2));
      totalScore += chestScore;
      measurementCount++;
    }

    // Waist fit score
    if (sizeMeasurements.waist && userMeasurements.waist) {
      const waistDiff = Math.abs(sizeMeasurements.waist - userMeasurements.waist);
      const waistScore = Math.max(0, 100 - (waistDiff * 2));
      totalScore += waistScore;
      measurementCount++;
    }

    // Hip fit score (if applicable)
    if (sizeMeasurements.hips && userMeasurements.hips) {
      const hipDiff = Math.abs(sizeMeasurements.hips - userMeasurements.hips);
      const hipScore = Math.max(0, 100 - (hipDiff * 2));
      totalScore += hipScore;
      measurementCount++;
    }

    // Average fit score
    const fitScore = measurementCount > 0 ? Math.round(totalScore / measurementCount) : 0;

    // Determine fit description
    let fitDescription = '';
    if (fitScore >= 90) fitDescription = 'Perfect Fit';
    else if (fitScore >= 75) fitDescription = 'Great Fit';
    else if (fitScore >= 60) fitDescription = 'Good Fit';
    else if (fitScore >= 40) fitDescription = 'Acceptable Fit';
    else fitDescription = 'Poor Fit';

    recommendations.push({
      size: sizeOption.size,
      fitScore,
      fitDescription,
      stock: sizeOption.stock,
      measurements: sizeMeasurements
    });
  });

  // Sort by fit score (best first)
  recommendations.sort((a, b) => b.fitScore - a.fitScore);

  return recommendations;
};

// Get size recommendation for a specific clothing item
exports.getSizeRecommendation = async (req, res) => {
  try {
    const { clothingId } = req.params;
    const userId = req.userId;

    // Get user measurements
    const userMeasurement = await Measurement.findOne({ userId });
    if (!userMeasurement) {
      return res.status(404).json({
        success: false,
        message: 'Please add your body measurements first'
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

    // Calculate recommendations
    const recommendations = calculateSizeRecommendation(
      {
        chest: userMeasurement.chest,
        waist: userMeasurement.waist,
        hips: userMeasurement.hips
      },
      clothing.sizes
    );

    // Get best recommendation
    const bestSize = recommendations[0];

    res.json({
      success: true,
      clothing: {
        id: clothing._id,
        name: clothing.name,
        brand: clothing.brand
      },
      userMeasurements: {
        chest: userMeasurement.chest,
        waist: userMeasurement.waist,
        hips: userMeasurement.hips,
        height: userMeasurement.height
      },
      recommendedSize: bestSize.size,
      fitScore: bestSize.fitScore,
      fitDescription: bestSize.fitDescription,
      allSizes: recommendations,
      advice: bestSize.fitScore >= 75 
        ? 'This size should fit you well!' 
        : 'Consider trying the next size up or down for better fit.'
    });
  } catch (error) {
    console.error('Size recommendation error:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting size recommendation',
      error: error.message
    });
  }
};

// Get size recommendations for multiple items
exports.getBulkSizeRecommendations = async (req, res) => {
  try {
    const { clothingIds } = req.body;
    const userId = req.userId;

    if (!clothingIds || !Array.isArray(clothingIds)) {
      return res.status(400).json({
        success: false,
        message: 'Please provide an array of clothing IDs'
      });
    }

    // Get user measurements
    const userMeasurement = await Measurement.findOne({ userId });
    if (!userMeasurement) {
      return res.status(404).json({
        success: false,
        message: 'Please add your body measurements first'
      });
    }

    // Get all clothing items
    const clothingItems = await Clothing.find({ _id: { $in: clothingIds } });

    // Calculate recommendations for each
    const results = clothingItems.map(clothing => {
      const recommendations = calculateSizeRecommendation(
        {
          chest: userMeasurement.chest,
          waist: userMeasurement.waist,
          hips: userMeasurement.hips
        },
        clothing.sizes
      );

      const bestSize = recommendations[0];

      return {
        clothingId: clothing._id,
        name: clothing.name,
        brand: clothing.brand,
        recommendedSize: bestSize.size,
        fitScore: bestSize.fitScore,
        fitDescription: bestSize.fitDescription
      };
    });

    res.json({
      success: true,
      count: results.length,
      recommendations: results
    });
  } catch (error) {
    console.error('Bulk size recommendation error:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting size recommendations',
      error: error.message
    });
  }
};