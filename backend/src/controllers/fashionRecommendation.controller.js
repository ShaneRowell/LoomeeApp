const Clothing = require('../models/clothing.model');
const Measurement = require('../models/measurement.model');

// Fashion recommendation database (in production, this could use Gemini AI)
const fashionRules = {
  shirt: {
    accessories: ['watch', 'belt', 'necklace', 'bracelet'],
    shoes: ['sneakers', 'loafers', 'oxford shoes', 'boots'],
    bottomWear: ['jeans', 'chinos', 'dress pants', 'shorts']
  },
  pants: {
    accessories: ['belt', 'watch', 'wallet chain'],
    shoes: ['sneakers', 'boots', 'dress shoes', 'loafers'],
    topWear: ['shirt', 't-shirt', 'sweater', 'jacket']
  },
  dress: {
    accessories: ['necklace', 'earrings', 'clutch', 'bracelet'],
    shoes: ['heels', 'flats', 'sandals', 'boots'],
    outerwear: ['cardigan', 'blazer', 'shawl']
  },
  jacket: {
    accessories: ['scarf', 'watch', 'sunglasses'],
    shoes: ['boots', 'sneakers', 'loafers'],
    layering: ['shirt', 't-shirt', 'hoodie']
  }
};

const colorMatching = {
  black: ['white', 'gray', 'red', 'blue', 'gold'],
  white: ['black', 'navy', 'gray', 'pastels', 'any color'],
  navy: ['white', 'beige', 'gray', 'burgundy', 'gold'],
  gray: ['white', 'black', 'pink', 'blue', 'yellow'],
  beige: ['white', 'brown', 'navy', 'olive', 'burgundy'],
  red: ['black', 'white', 'navy', 'gray', 'denim'],
  blue: ['white', 'beige', 'brown', 'gray', 'orange']
};

// Get fashion recommendations for a clothing item
exports.getRecommendations = async (req, res) => {
  try {
    const { clothingId } = req.params;

    const clothing = await Clothing.findById(clothingId);
    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    const category = clothing.category;
    const primaryColor = clothing.colors && clothing.colors[0] ? clothing.colors[0].name.toLowerCase() : 'neutral';

    // Get recommendations based on category
    const categoryRecs = fashionRules[category] || {};

    // Get color matching suggestions
    const colorRecs = colorMatching[primaryColor] || colorMatching['white'];

    // Generate complete outfit suggestions
    const outfitSuggestions = generateOutfitSuggestions(clothing, categoryRecs);

    // Style tips
    const styleTips = generateStyleTips(clothing);

    res.json({
      success: true,
      clothing: {
        id: clothing._id,
        name: clothing.name,
        category: clothing.category,
        primaryColor: primaryColor
      },
      recommendations: {
        accessories: categoryRecs.accessories || [],
        shoes: categoryRecs.shoes || [],
        complementaryItems: categoryRecs.bottomWear || categoryRecs.topWear || categoryRecs.outerwear || [],
        colorMatches: colorRecs,
        outfitSuggestions,
        styleTips
      }
    });

  } catch (error) {
    console.error('Get recommendations error:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting fashion recommendations',
      error: error.message
    });
  }
};

// Generate outfit suggestions
const generateOutfitSuggestions = (clothing, categoryRecs) => {
  const suggestions = [];

  if (clothing.category === 'shirt') {
    suggestions.push({
      name: 'Casual Look',
      items: [
        `${clothing.name}`,
        'Dark wash jeans',
        'White sneakers',
        'Leather watch'
      ],
      occasion: 'Weekend outing, coffee date'
    });
    suggestions.push({
      name: 'Smart Casual',
      items: [
        `${clothing.name}`,
        'Chinos',
        'Loafers',
        'Belt and watch'
      ],
      occasion: 'Office casual, dinner'
    });
  } else if (clothing.category === 'dress') {
    suggestions.push({
      name: 'Evening Elegant',
      items: [
        `${clothing.name}`,
        'Statement earrings',
        'Heels',
        'Clutch bag'
      ],
      occasion: 'Dinner, party, formal event'
    });
    suggestions.push({
      name: 'Daytime Chic',
      items: [
        `${clothing.name}`,
        'Sandals',
        'Sun hat',
        'Light cardigan'
      ],
      occasion: 'Brunch, shopping, casual outing'
    });
  } else if (clothing.category === 'pants') {
    suggestions.push({
      name: 'Business Professional',
      items: [
        'Dress shirt',
        `${clothing.name}`,
        'Oxford shoes',
        'Leather belt and watch'
      ],
      occasion: 'Office, business meeting'
    });
  }

  return suggestions;
};

// Generate style tips
const generateStyleTips = (clothing) => {
  const tips = [];

  // Material-based tips
  if (clothing.material) {
    if (clothing.material.toLowerCase().includes('cotton')) {
      tips.push('Cotton is breathable and comfortable for all-day wear');
      tips.push('Easy to maintain - machine washable');
    }
    if (clothing.material.toLowerCase().includes('silk')) {
      tips.push('Silk adds elegance - perfect for special occasions');
      tips.push('Handle with care - dry clean recommended');
    }
  }

  // Category-based tips
  if (clothing.category === 'shirt') {
    tips.push('Tuck in for formal look, leave out for casual vibe');
    tips.push('Roll up sleeves for a relaxed style');
  } else if (clothing.category === 'dress') {
    tips.push('Add a belt to accentuate your waistline');
    tips.push('Layer with jacket or cardigan for versatility');
  }

  // Gender-based tips
  if (clothing.gender === 'unisex') {
    tips.push('Versatile piece that works for any body type');
  }

  // Season tips
  tips.push('Layer appropriately based on weather');

  return tips;
};

// Get personalized recommendations based on user's wardrobe
exports.getPersonalizedRecommendations = async (req, res) => {
  try {
    const userId = req.userId;

    // Get user measurements for fit-based recommendations
    const measurements = await Measurement.findOne({ userId });

    // In production, this would analyze user's purchase/try-on history
    // For now, provide general recommendations

    const recommendations = {
      forYou: [
        'Based on your measurements, athletic fit styles suit you best',
        'Your height is perfect for standard length garments',
        'Consider slim-fit options for a modern look'
      ],
      trendingNow: [
        'Oversized blazers are trending this season',
        'Earth tones and neutrals are popular',
        'Sustainable fashion is in - look for organic cotton'
      ],
      buildYourWardrobe: [
        'Essential: A versatile white shirt',
        'Essential: Well-fitted dark jeans',
        'Essential: Classic sneakers',
        'Essential: A neutral jacket'
      ]
    };

    res.json({
      success: true,
      userMeasurements: measurements ? {
        chest: measurements.chest,
        waist: measurements.waist,
        height: measurements.height
      } : null,
      recommendations
    });

  } catch (error) {
    console.error('Get personalized recommendations error:', error);
    res.status(500).json({
      success: false,
      message: 'Error getting personalized recommendations',
      error: error.message
    });
  }
};

// Get complete outfit recommendations
exports.getCompleteOutfit = async (req, res) => {
  try {
    const { occasion, style } = req.query;

    // Fetch random clothing items from catalog
    const shirts = await Clothing.find({ category: 'shirt', isActive: true }).limit(3);
    const pants = await Clothing.find({ category: 'pants', isActive: true }).limit(3);
    const accessories = ['Watch', 'Belt', 'Sunglasses'];
    const shoes = ['Sneakers', 'Loafers', 'Boots'];

    const outfits = [];

    // Generate outfit combinations
    if (shirts.length > 0 && pants.length > 0) {
      outfits.push({
        name: 'Smart Casual Ensemble',
        occasion: occasion || 'Versatile',
        style: style || 'Modern',
        items: {
          top: shirts[0].name,
          bottom: pants[0].name,
          shoes: shoes[0],
          accessories: [accessories[0], accessories[1]]
        },
        totalPrice: shirts[0].price + pants[0].price,
        reasoning: 'This combination balances comfort and style, perfect for various occasions'
      });
    }

    res.json({
      success: true,
      occasion: occasion || 'Any occasion',
      style: style || 'Versatile',
      outfits
    });

  } catch (error) {
    console.error('Get complete outfit error:', error);
    res.status(500).json({
      success: false,
      message: 'Error generating outfit recommendations',
      error: error.message
    });
  }
};