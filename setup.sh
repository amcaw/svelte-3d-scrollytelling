#!/bin/bash

# Svelte 3D Scrollytelling - Development Setup Script
# This script sets up the development environment and guides you through the deployment process

echo "🌟 Welcome to Svelte 3D Scrollytelling Setup!"
echo "=============================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    echo "   Download from: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version)
echo "✅ Node.js version: $NODE_VERSION"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully!"
else
    echo "❌ Failed to install dependencies. Please check the error above."
    exit 1
fi

# Create git commit if needed
echo ""
echo "🔧 Setting up Git..."
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git repository initialized"
fi

# Check git status
if git diff-index --quiet HEAD --; then
    echo "✅ No uncommitted changes"
else
    echo "⚠️  You have uncommitted changes. Commit them before proceeding."
fi

# Development server
echo ""
echo "🚀 Starting development server..."
echo "   Open http://localhost:5173 in your browser"
echo "   Press Ctrl+C to stop the server"
echo ""

# Ask user if they want to start dev server
read -p "Start development server now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm run dev
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Create GitHub repository: https://github.com/new"
echo "2. Push your code: git push -u origin main"
echo "3. Deploy using Vercel, Netlify, or GitHub Pages"
echo "4. Read USAGE_GUIDE.md for detailed instructions"
echo ""
echo "Happy coding! 🚀"