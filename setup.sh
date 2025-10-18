#!/bin/bash

echo "Setting up StyleShare project..."

# Check if contract exists
if [ ! -f "contracts/StyleShare.clar" ]; then
    echo "❌ Contract file not found. Please add StyleShare.clar to contracts/ folder"
    exit 1
fi

# Run clarinet check
echo "Checking contract..."
clarinet check

if [ $? -eq 0 ]; then
    echo "✅ Contract check passed!"
else
    echo "❌ Contract check failed"
    exit 1
fi

# Optional: Setup UI
read -p "Do you want to setup the UI? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Choose UI framework:"
    echo "1) Create React App (traditional)"
    echo "2) Vite + React (faster, modern)"
    read -p "Enter choice (1 or 2): " choice
    
    if [ "$choice" == "1" ]; then
        npx create-react-app styleshare-ui
        cd styleshare-ui
        npm install lucide-react
    elif [ "$choice" == "2" ]; then
        npm create vite@latest styleshare-ui -- --template react
        cd styleshare-ui
        npm install
        npm install lucide-react
    fi
    
    echo "✅ UI setup complete! Add the React component to src/App.js or src/App.jsx"
    echo "Run 'cd styleshare-ui && npm start' (CRA) or 'npm run dev' (Vite) to start"
fi

echo "✅ Setup complete!"