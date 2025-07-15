#!/bin/bash

echo "🚀 GitHub Pages Deployment Setup"
echo "=================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a Git repository. Please run this from your project root."
    exit 1
fi

# Check if origin remote exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "❌ No origin remote found. Please push your code to GitHub first."
    exit 1
fi

REPO_URL=$(git remote get-url origin)
echo "📦 Repository: $REPO_URL"

# Add and commit the GitHub Actions workflow
echo ""
echo "📝 Adding GitHub Actions workflow..."
git add .github/workflows/deploy.yml
git add svelte.config.js
git add deploy-github-pages.sh

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "✅ No changes to commit - workflow already exists"
else
    git commit -m "feat: add GitHub Pages deployment with GitHub Actions

- Add automated deployment workflow
- Configure Svelte adapter for GitHub Pages
- Set up proper build and deployment pipeline

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    echo "✅ Changes committed"
fi

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed to GitHub!"
else
    echo "❌ Failed to push to GitHub. Please check your authentication."
    exit 1
fi

echo ""
echo "🎉 GitHub Pages deployment setup complete!"
echo ""
echo "Next steps:"
echo "1. Go to your repository on GitHub"
echo "2. Click 'Settings' → 'Pages'"
echo "3. Under 'Source', select 'GitHub Actions'"
echo "4. The workflow will automatically build and deploy your site"
echo "5. Your site will be available at: https://amcaw.github.io/svelte-3d-scrollytelling/"
echo ""
echo "📊 Monitor deployment:"
echo "- Check 'Actions' tab for build progress"
echo "- Site will be live in 2-3 minutes after successful build"
echo ""
echo "🔧 Troubleshooting:"
echo "- If deployment fails, check the Actions tab for error logs"
echo "- Make sure GitHub Pages is enabled in repository settings"
echo "- Verify the repository is public (required for free GitHub Pages)"
echo ""
echo "✨ Happy deploying!"