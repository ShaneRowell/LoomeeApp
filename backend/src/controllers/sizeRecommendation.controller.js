const Measurement = require('../models/measurement.model');
const Clothing = require('../models/clothing.model');

/**
 * Size recommendation algorithm
 * Scores each available size by comparing clothing measurements to user measurements.
 * Each dimension contributes equally; a 1cm difference reduces score by 2 points from 100.
 *
 * userMeasurements must include { chest, waist, hips, unit } where unit is 'cm' or 'inches'.
 * All garment measurements in the DB are assumed to be in cm.
 */
const calculateSizeRecommendation = (userMeasurements, clothingSizes) => {
  // ── Unit conversion ───────────────────────────────────────────────────
  // Garment measurements are stored in cm. If the user saved their
  // measurements in inches we must convert before comparing, otherwise a
  // 38" chest is compared to an 86 cm chest (diff = 48 → score ≈ 0 for
  // every size) and the stable sort silently returns S every time.
  const factor = userMeasurements.unit === 'inches' ? 2.54 : 1;
  const userChest = userMeasurements.chest ? userMeasurements.chest * factor : null;
  const userWaist = userMeasurements.waist ? userMeasurements.waist * factor : null;
  const userHips  = userMeasurements.hips  ? userMeasurements.hips  * factor : null;

  const recommendations = [];

  clothingSizes.forEach(sizeOption => {
    const m = sizeOption.measurements || {};

    // Calculate fit scores for each measurement dimension
    let totalScore = 0;
    let measurementCount = 0;

    // Chest
    if (m.chest && userChest) {
      totalScore += Math.max(0, 100 - Math.abs(m.chest - userChest) * 2);
      measurementCount++;
    }

    // Waist
    if (m.waist && userWaist) {
      totalScore += Math.max(0, 100 - Math.abs(m.waist - userWaist) * 2);
      measurementCount++;
    }

    // Hips
    if (m.hips && userHips) {
      totalScore += Math.max(0, 100 - Math.abs(m.hips - userHips) * 2);
      measurementCount++;
    }

    // null means "no garment measurements available for this size" — kept
    // separate from a genuine score of 0 so we can handle it below.
    const fitScore = measurementCount > 0
      ? Math.round(totalScore / measurementCount)
      : null;

    let fitDescription = 'No size data available';
    if (fitScore !== null) {
      if (fitScore >= 90)      fitDescription = 'Perfect Fit';
      else if (fitScore >= 75) fitDescription = 'Great Fit';
      else if (fitScore >= 60) fitDescription = 'Good Fit';
      else if (fitScore >= 40) fitDescription = 'Acceptable Fit';
      else                     fitDescription = 'Poor Fit';
    }

    recommendations.push({
      size: sizeOption.size,
      fitScore,
      fitDescription,
      stock: sizeOption.stock,
      measurements: m
    });
  });

  // ── Sort ──────────────────────────────────────────────────────────────
  // Sizes with real scores come first (highest score first).
  // Sizes whose garment measurements are missing fall to the bottom.
  // If NO sizes have measurements (common when items are added without
  // measurement data), fall back to a sensible default order so we don't
  // silently return 'S' every time just because it's first in the array.
  const scored   = recommendations.filter(r => r.fitScore !== null);
  const unscored = recommendations.filter(r => r.fitScore === null);

  scored.sort((a, b) => b.fitScore - a.fitScore);

  if (scored.length === 0) {
    // No garment measurements at all — rank by proximity to median size
    const fallbackOrder = ['M', 'L', 'S', 'XL', 'XS', 'XXL', '3XL'];
    unscored.sort((a, b) => {
      const ai = fallbackOrder.indexOf(a.size);
      const bi = fallbackOrder.indexOf(b.size);
      return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi);
    });
    // Give them a score of 0 so downstream code doesn't need null-checks
    return unscored.map(r => ({ ...r, fitScore: 0 }));
  }

  return [
    ...scored,
    ...unscored.map(r => ({ ...r, fitScore: 0 }))
  ];
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
        hips: userMeasurement.hips,
        unit: userMeasurement.unit || 'cm'
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
      advice: bestSize.fitScore >= 90
        ? 'This is your perfect size — order with confidence!'
        : bestSize.fitScore >= 75
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

    // Cap bulk requests to prevent excessive DB load
    if (clothingIds.length > 20) {
      return res.status(400).json({
        success: false,
        message: 'Maximum 20 items allowed per bulk request'
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
          hips: userMeasurement.hips,
          unit: userMeasurement.unit || 'cm'
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