const Clothing = require('../models/clothing.model');

// Add new clothing item
exports.addClothing = async (req, res) => {
  try {
    const clothingData = req.body;

    const clothing = new Clothing(clothingData);
    await clothing.save();

    res.status(201).json({
      success: true,
      message: 'Clothing item added successfully',
      clothing
    });
  } catch (error) {
    console.error('Add clothing error:', error);
    res.status(500).json({
      success: false,
      message: 'Error adding clothing item',
      error: error.message
    });
  }
};

// Get all clothing items with filters
exports.getAllClothing = async (req, res) => {
  try {
    const { category, gender, minPrice, maxPrice, brand, search } = req.query;

    let filter = { isActive: true };

    if (category) filter.category = category;
    if (gender) filter.gender = gender;
    if (brand) filter.brand = brand;
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { brand: { $regex: search, $options: 'i' } }
      ];
    }

    const clothing = await Clothing.find(filter).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: clothing.length,
      clothing
    });
  } catch (error) {
    console.error('Get all clothing error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching clothing items',
      error: error.message
    });
  }
};

// Get clothing by ID
exports.getClothingById = async (req, res) => {
  try {
    const { id } = req.params;

    const clothing = await Clothing.findById(id);

    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    res.json({
      success: true,
      clothing
    });
  } catch (error) {
    console.error('Get clothing by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching clothing item',
      error: error.message
    });
  }
};

// Get clothing by category
exports.getClothingByCategory = async (req, res) => {
  try {
    const { category } = req.params;

    const clothing = await Clothing.find({ 
      category: category.toLowerCase(), 
      isActive: true 
    }).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: clothing.length,
      clothing
    });
  } catch (error) {
    console.error('Get clothing by category error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching clothing by category',
      error: error.message
    });
  }
};

// Update clothing item
exports.updateClothing = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const clothing = await Clothing.findByIdAndUpdate(
      id, 
      { ...updates, updatedAt: Date.now() },
      { new: true, runValidators: true }
    );

    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    res.json({
      success: true,
      message: 'Clothing item updated successfully',
      clothing
    });
  } catch (error) {
    console.error('Update clothing error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating clothing item',
      error: error.message
    });
  }
};

// Delete clothing item
exports.deleteClothing = async (req, res) => {
  try {
    const { id } = req.params;

    const clothing = await Clothing.findByIdAndDelete(id);

    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: 'Clothing item not found'
      });
    }

    res.json({
      success: true,
      message: 'Clothing item deleted successfully'
    });
  } catch (error) {
    console.error('Delete clothing error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting clothing item',
      error: error.message
    });
  }
};