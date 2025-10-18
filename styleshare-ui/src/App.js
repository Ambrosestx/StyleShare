import React, { useState } from 'react';
import { Plus, Trash2, ShoppingBag, Package, AlertCircle, CheckCircle, Loader } from 'lucide-react';

export default function StyleShareUI() {
  const [activeTab, setActiveTab] = useState('bulk-list');
  const [listItems, setListItems] = useState([{
    id: 1,
    title: '',
    description: '',
    category: '',
    size: '',
    dailyRate: '',
    securityDeposit: ''
  }]);
  const [rentItems, setRentItems] = useState([{
    id: 1,
    itemId: '',
    durationDays: ''
  }]);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);

  const categories = ['Dress', 'Suit', 'Shoes', 'Accessories', 'Outerwear', 'Handbag', 'Jewelry'];
  const sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'One Size'];

  const addListItem = () => {
    if (listItems.length < 10) {
      setListItems([...listItems, {
        id: Date.now(),
        title: '',
        description: '',
        category: '',
        size: '',
        dailyRate: '',
        securityDeposit: ''
      }]);
    }
  };

  const removeListItem = (id) => {
    if (listItems.length > 1) {
      setListItems(listItems.filter(item => item.id !== id));
    }
  };

  const updateListItem = (id, field, value) => {
    setListItems(listItems.map(item => 
      item.id === id ? { ...item, [field]: value } : item
    ));
  };

  const addRentItem = () => {
    if (rentItems.length < 10) {
      setRentItems([...rentItems, {
        id: Date.now(),
        itemId: '',
        durationDays: ''
      }]);
    }
  };

  const removeRentItem = (id) => {
    if (rentItems.length > 1) {
      setRentItems(rentItems.filter(item => item.id !== id));
    }
  };

  const updateRentItem = (id, field, value) => {
    setRentItems(rentItems.map(item => 
      item.id === id ? { ...item, [field]: value } : item
    ));
  };

  const validateListItems = () => {
    for (let item of listItems) {
      if (!item.title || !item.description || !item.category || !item.size || 
          !item.dailyRate || !item.securityDeposit) {
        return false;
      }
      if (parseFloat(item.dailyRate) <= 0 || parseFloat(item.securityDeposit) <= 0) {
        return false;
      }
    }
    return true;
  };

  const validateRentItems = () => {
    for (let item of rentItems) {
      if (!item.itemId || !item.durationDays) {
        return false;
      }
      const duration = parseInt(item.durationDays);
      if (duration < 1 || duration > 365) {
        return false;
      }
    }
    return true;
  };

  const handleBulkList = async () => {
    if (!validateListItems()) {
      setResult({ 
        type: 'error', 
        message: 'Please fill all fields with valid values (prices must be > 0)'
      });
      return;
    }

    setLoading(true);
    setResult(null);

    // Simulate contract call
    setTimeout(() => {
      const itemIds = listItems.map((_, idx) => idx + 1);
      setResult({
        type: 'success',
        message: `Successfully listed ${listItems.length} items!`,
        data: `Item IDs: ${itemIds.join(', ')}`
      });
      setLoading(false);
      
      // Reset form after success
      setTimeout(() => {
        setListItems([{
          id: 1,
          title: '',
          description: '',
          category: '',
          size: '',
          dailyRate: '',
          securityDeposit: ''
        }]);
        setResult(null);
      }, 3000);
    }, 2000);
  };

  const handleBulkRent = async () => {
    if (!validateRentItems()) {
      setResult({ 
        type: 'error', 
        message: 'Please fill all fields (duration must be 1-365 days)'
      });
      return;
    }

    setLoading(true);
    setResult(null);

    // Calculate total cost
    const mockCosts = rentItems.map((item) => {
      const days = parseInt(item.durationDays);
      const rate = 50; // Mock daily rate
      const deposit = 100; // Mock security deposit
      return (days * rate) + deposit;
    });
    const totalCost = mockCosts.reduce((a, b) => a + b, 0);

    // Simulate contract call
    setTimeout(() => {
      const rentalIds = rentItems.map((_, idx) => idx + 100);
      setResult({
        type: 'success',
        message: `Successfully rented ${rentItems.length} items!`,
        data: `Rental IDs: ${rentalIds.join(', ')} | Total Cost: ${totalCost} STX`
      });
      setLoading(false);

      // Reset form after success
      setTimeout(() => {
        setRentItems([{
          id: 1,
          itemId: '',
          durationDays: ''
        }]);
        setResult(null);
      }, 3000);
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
      <div className="max-w-6xl mx-auto p-6">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-lg p-8 mb-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent mb-2">
                StyleShare
              </h1>
              <p className="text-gray-600">Decentralized Fashion Rental Marketplace</p>
            </div>
            <Package className="w-16 h-16 text-purple-600" />
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="bg-white rounded-2xl shadow-lg mb-6">
          <div className="flex border-b">
            <button
              onClick={() => setActiveTab('bulk-list')}
              className={`flex-1 py-4 px-6 font-semibold transition-all ${
                activeTab === 'bulk-list'
                  ? 'bg-purple-600 text-white rounded-tl-2xl'
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <div className="flex items-center justify-center gap-2">
                <Package className="w-5 h-5" />
                Bulk List Items
              </div>
            </button>
            <button
              onClick={() => setActiveTab('bulk-rent')}
              className={`flex-1 py-4 px-6 font-semibold transition-all ${
                activeTab === 'bulk-rent'
                  ? 'bg-purple-600 text-white rounded-tr-2xl'
                  : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              <div className="flex items-center justify-center gap-2">
                <ShoppingBag className="w-5 h-5" />
                Bulk Rent Items
              </div>
            </button>
          </div>
        </div>

        {/* Bulk List Items Tab */}
        {activeTab === 'bulk-list' && (
          <div className="bg-white rounded-2xl shadow-lg p-8">
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-gray-800 mb-2">
                Bulk List Fashion Items
              </h2>
              <p className="text-gray-600">
                List up to 10 fashion items in a single transaction. Save on gas fees!
              </p>
            </div>

            <div className="space-y-4 mb-6">
              {listItems.map((item, index) => (
                <div key={item.id} className="border-2 border-purple-100 rounded-xl p-6 bg-purple-50/30">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold text-gray-800">
                      Item {index + 1}
                    </h3>
                    {listItems.length > 1 && (
                      <button
                        onClick={() => removeListItem(item.id)}
                        className="text-red-500 hover:text-red-700 transition-colors"
                      >
                        <Trash2 className="w-5 h-5" />
                      </button>
                    )}
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Title *
                      </label>
                      <input
                        type="text"
                        value={item.title}
                        onChange={(e) => updateListItem(item.id, 'title', e.target.value)}
                        placeholder="e.g., Elegant Evening Gown"
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                        maxLength="100"
                      />
                    </div>

                    <div className="col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Description *
                      </label>
                      <textarea
                        value={item.description}
                        onChange={(e) => updateListItem(item.id, 'description', e.target.value)}
                        placeholder="Describe your item..."
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                        rows="3"
                        maxLength="500"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Category *
                      </label>
                      <select
                        value={item.category}
                        onChange={(e) => updateListItem(item.id, 'category', e.target.value)}
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                      >
                        <option value="">Select category</option>
                        {categories.map(cat => (
                          <option key={cat} value={cat}>{cat}</option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Size *
                      </label>
                      <select
                        value={item.size}
                        onChange={(e) => updateListItem(item.id, 'size', e.target.value)}
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                      >
                        <option value="">Select size</option>
                        {sizes.map(size => (
                          <option key={size} value={size}>{size}</option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Daily Rate (STX) *
                      </label>
                      <input
                        type="number"
                        value={item.dailyRate}
                        onChange={(e) => updateListItem(item.id, 'dailyRate', e.target.value)}
                        placeholder="0.00"
                        min="0"
                        step="0.01"
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Security Deposit (STX) *
                      </label>
                      <input
                        type="number"
                        value={item.securityDeposit}
                        onChange={(e) => updateListItem(item.id, 'securityDeposit', e.target.value)}
                        placeholder="0.00"
                        min="0"
                        step="0.01"
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-purple-500 focus:ring focus:ring-purple-200 transition-all"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className="flex gap-4">
              {listItems.length < 10 && (
                <button
                  onClick={addListItem}
                  className="flex-1 bg-purple-100 text-purple-700 px-6 py-3 rounded-lg font-semibold hover:bg-purple-200 transition-all flex items-center justify-center gap-2"
                >
                  <Plus className="w-5 h-5" />
                  Add Another Item ({listItems.length}/10)
                </button>
              )}
              <button
                onClick={handleBulkList}
                disabled={loading}
                className="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 py-3 rounded-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {loading ? (
                  <>
                    <Loader className="w-5 h-5 animate-spin" />
                    Processing...
                  </>
                ) : (
                  <>
                    <Package className="w-5 h-5" />
                    List {listItems.length} Item{listItems.length > 1 ? 's' : ''}
                  </>
                )}
              </button>
            </div>
          </div>
        )}

        {/* Bulk Rent Items Tab */}
        {activeTab === 'bulk-rent' && (
          <div className="bg-white rounded-2xl shadow-lg p-8">
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-gray-800 mb-2">
                Bulk Rent Fashion Items
              </h2>
              <p className="text-gray-600">
                Rent up to 10 items in a single transaction. Perfect for events!
              </p>
            </div>

            <div className="space-y-4 mb-6">
              {rentItems.map((item, index) => (
                <div key={item.id} className="border-2 border-pink-100 rounded-xl p-6 bg-pink-50/30">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold text-gray-800">
                      Rental {index + 1}
                    </h3>
                    {rentItems.length > 1 && (
                      <button
                        onClick={() => removeRentItem(item.id)}
                        className="text-red-500 hover:text-red-700 transition-colors"
                      >
                        <Trash2 className="w-5 h-5" />
                      </button>
                    )}
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Item ID *
                      </label>
                      <input
                        type="number"
                        value={item.itemId}
                        onChange={(e) => updateRentItem(item.id, 'itemId', e.target.value)}
                        placeholder="Enter item ID"
                        min="1"
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-pink-500 focus:ring focus:ring-pink-200 transition-all"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Duration (Days) *
                      </label>
                      <input
                        type="number"
                        value={item.durationDays}
                        onChange={(e) => updateRentItem(item.id, 'durationDays', e.target.value)}
                        placeholder="1-365"
                        min="1"
                        max="365"
                        className="w-full px-4 py-2 border-2 border-gray-200 rounded-lg focus:border-pink-500 focus:ring focus:ring-pink-200 transition-all"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <div className="flex gap-4">
              {rentItems.length < 10 && (
                <button
                  onClick={addRentItem}
                  className="flex-1 bg-pink-100 text-pink-700 px-6 py-3 rounded-lg font-semibold hover:bg-pink-200 transition-all flex items-center justify-center gap-2"
                >
                  <Plus className="w-5 h-5" />
                  Add Another Item ({rentItems.length}/10)
                </button>
              )}
              <button
                onClick={handleBulkRent}
                disabled={loading}
                className="flex-1 bg-gradient-to-r from-pink-600 to-purple-600 text-white px-6 py-3 rounded-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {loading ? (
                  <>
                    <Loader className="w-5 h-5 animate-spin" />
                    Processing...
                  </>
                ) : (
                  <>
                    <ShoppingBag className="w-5 h-5" />
                    Rent {rentItems.length} Item{rentItems.length > 1 ? 's' : ''}
                  </>
                )}
              </button>
            </div>
          </div>
        )}

        {/* Result Message */}
        {result && (
          <div className={`mt-6 rounded-xl p-6 shadow-lg ${
            result.type === 'success' 
              ? 'bg-green-50 border-2 border-green-200' 
              : 'bg-red-50 border-2 border-red-200'
          }`}>
            <div className="flex items-start gap-3">
              {result.type === 'success' ? (
                <CheckCircle className="w-6 h-6 text-green-600 flex-shrink-0 mt-0.5" />
              ) : (
                <AlertCircle className="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5" />
              )}
              <div>
                <p className={`font-semibold ${
                  result.type === 'success' ? 'text-green-800' : 'text-red-800'
                }`}>
                  {result.message}
                </p>
                {result.data && (
                  <p className={`text-sm mt-1 ${
                    result.type === 'success' ? 'text-green-700' : 'text-red-700'
                  }`}>
                    {result.data}
                  </p>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Info Panel */}
        <div className="mt-6 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl p-6 border-2 border-blue-100">
          <h3 className="font-semibold text-gray-800 mb-3 flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-blue-600" />
            Bulk Operations Benefits
          </h3>
          <ul className="space-y-2 text-sm text-gray-700">
            <li>• Save on transaction fees by batching operations</li>
            <li>• Process up to 10 items in a single transaction</li>
            <li>• Atomic execution ensures all-or-nothing processing</li>
            <li>• Perfect for event planning or inventory management</li>
            <li>• Platform fee: 2.5% on successful rentals</li>
          </ul>
        </div>
      </div>
    </div>
  );
}