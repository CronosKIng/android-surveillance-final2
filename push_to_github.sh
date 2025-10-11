#!/bin/bash

echo "🚀 Kuanza ku-push mabadiliko kwenye GitHub..."

# Nenda kwenye directory ya project
cd ~/android-surveillance-final2

# Hakikisha uko kwenye directory sahihi
if [ $? -ne 0 ]; then
    echo "❌ Error: Haiwezekani kuingia kwenye ~/android-surveillance-final2"
    exit 1
fi

# Onyesha status ya sasa
echo "📊 Directory ya sasa: $(pwd)"
echo "📁 Files zilizopo:"
ls -la

# Weka repository yako sahihi
echo "🔗 Kuweka GitHub repository..."
git remote set-url origin https://github.com/CronosKIng/android-surveillance-final2.git

# Onyesha status ya git
echo "📊 Checking git status..."
git status

# Onyesha mabadiliko
echo "📝 Files zilizobadilika:"
git status --porcelain

# Add files zote
echo "➕ Adding files zote kwenye staging..."
git add .

# Fanya commit
echo "💾 Kufanya commit..."
git commit -m "🔒 Stealth Mode Implementation - $(date '+%Y-%m-%d %H:%M:%S')

- Added invisible StealthActivity (no UI launcher)
- Added background StealthService 
- Modified LoginActivity for stealth mode
- Added BootReceiver for auto-start on boot
- Updated AndroidManifest for hidden operation
- Added self-protection mechanisms
- App now runs completely invisible
- Hide from recent apps and launcher"

# Push kwenye main branch
echo "📤 Inapush kwenye GitHub..."
git branch -M main
git push -u origin main

# Angalia matokeo
if [ $? -eq 0 ]; then
    echo "✅✅✅ MAFANIKIO! 🎉"
    echo "📱 Mabadiliko yameshapush kwenye GitHub!"
    echo "🔗 https://github.com/CronosKIng/android-surveillance-final2"
    echo ""
    echo "🔒 FEATURES MPYA ZA STEALTH MODE:"
    echo "   👻 Hakuna icon kwenye app launcher"
    echo "   🔄 Inajizima kwenye background"
    echo "   🚀 Inaanza wenyewe kwenye boot"
    echo "   📍 Inafuatilia location kwa siri"
    echo "   📞 Inasikilizia simu calls"
    echo "   💬 Inasoma SMS messages"
    echo "   🛡️ Haifutiki kirahisi"
    echo "   🔐 Inahitaji code ya kufuta"
else
    echo "❌ Push imeshindikana!"
    echo "📋 Sababu zinazowezekana:"
    echo "   🔗 Hakuna internet connection"
    echo "   🔑 GitHub credentials hazipo"
    echo "   🔐 Umelogin kwenye GitHub"
    echo ""
    echo "💡 Tumia command hii kwanza kama huwezi push:"
    echo "   git push -u origin main --force"
fi

# Onyesha taarifa za mwisho
echo ""
echo "📊 TAARIFA ZA MWISHO:"
git remote -v
echo "Branch: $(git branch --show-current)"
echo "Last commit: $(git log -1 --oneline)"
