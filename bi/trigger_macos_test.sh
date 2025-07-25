#!/bin/bash

echo "🚀 Triggering macOS networking test via GitHub Actions"
echo

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository. Please run from the project root."
    exit 1
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Install with:"
    echo "   brew install gh"
    echo "   # or"
    echo "   sudo apt install gh"
    exit 1
fi

# Check if authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "🔐 Please authenticate with GitHub first:"
    echo "   gh auth login"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo

# Get current branch
BRANCH=$(git branch --show-current)
echo "📋 Current branch: $BRANCH"

# Check if there are uncommitted changes to our files
if git diff --quiet HEAD -- bi/pkg/cluster/kind/ bi/pkg/installs/env.go .github/workflows/test-macos-networking.yml; then
    echo "✅ No uncommitted changes to networking files"
else
    echo "⚠️  You have uncommitted changes to networking files:"
    git diff --name-only HEAD -- bi/pkg/cluster/kind/ bi/pkg/installs/env.go .github/workflows/test-macos-networking.yml
    echo
    read -p "Do you want to commit these changes first? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📝 Committing changes..."
        git add bi/pkg/cluster/kind/ bi/pkg/installs/env.go .github/workflows/test-macos-networking.yml
        git commit -m "feat: fix OSX networking for all container stacks

- Add Colima detection logic
- Add Apple Virtualization detection  
- Update gateway enable logic to include all runtimes
- Add container capabilities for proper routing

Fixes #2365"
        echo "✅ Changes committed"
    fi
fi

# Push current branch
echo "📤 Pushing current branch..."
git push origin "$BRANCH"

# Check if workflow exists
if ! gh workflow list | grep -q "Test macOS Networking Fix"; then
    echo "❌ Workflow 'Test macOS Networking Fix' not found in repository"
    echo "Make sure the workflow file is committed and pushed"
    exit 1
fi

# Trigger the workflow
echo "🎬 Triggering workflow..."
gh workflow run "Test macOS Networking Fix" --ref "$BRANCH"

echo "✅ Workflow triggered successfully!"
echo
echo "📊 Monitor the workflow with:"
echo "   gh run list --workflow='Test macOS Networking Fix'"
echo "   gh run watch"
echo
echo "🌐 Or view in browser:"
echo "   gh workflow view 'Test macOS Networking Fix' --web"

# Wait a moment then show recent runs
sleep 3
echo
echo "📋 Recent workflow runs:"
gh run list --workflow="Test macOS Networking Fix" --limit 3