# 🔑 How to Check Gemini API Key

## Your Current API Key
```
AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU
```

---

## Method 1: Quick Test via Command Line (PowerShell)

### Test with curl:
```powershell
$apiKey = "AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"
$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "Hello! Say hi in Bengali."
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
```

**Expected Response**: You should see JSON with Bengali text response

**If Error**: 
- `400` = Invalid request format
- `401` or `403` = Invalid API key
- `429` = Rate limit exceeded
- `500` = Server error

---

## Method 2: Test via Browser

1. Open: https://aistudio.google.com/app/apikey
2. Login with your Google account
3. Check if the API key exists and is active
4. You can also generate a new key here if needed

---

## Method 3: Test in Google AI Studio

1. Go to: https://aistudio.google.com/
2. Click **"Get API key"**
3. Select your project or create new one
4. Test the API directly in the web interface
5. Try sending: "Hello in Bengali"

---

## Method 4: Check Quota and Usage

1. Go to: https://console.cloud.google.com/
2. Select your project
3. Navigate to: **APIs & Services → Dashboard**
4. Search for: **"Generative Language API"**
5. Click on it to see:
   - ✅ API Status (Enabled/Disabled)
   - 📊 Usage statistics
   - 🎯 Quota limits
   - ⚠️ Any errors

---

## Method 5: Quick PowerShell Test Script

Copy and paste this into PowerShell:

```powershell
Write-Host "Testing Gemini API..." -ForegroundColor Yellow
Write-Host ""

$apiKey = "AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"

$body = @"
{
  "contents": [{
    "parts": [{
      "text": "Say 'API Working!' in Bengali"
    }]
  }]
}
"@

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    
    if ($response.candidates) {
        Write-Host "✅ SUCCESS! API is working!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response:" -ForegroundColor Cyan
        Write-Host $response.candidates[0].content.parts[0].text -ForegroundColor White
    } else {
        Write-Host "⚠️ API responded but with unexpected format" -ForegroundColor Yellow
        Write-Host $response
    }
} catch {
    Write-Host "❌ ERROR! API test failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error Details:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Message -match "401|403") {
        Write-Host ""
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host "1. Invalid API key" -ForegroundColor White
        Write-Host "2. API key not enabled for Generative Language API" -ForegroundColor White
        Write-Host "3. Billing not enabled in Google Cloud Console" -ForegroundColor White
    } elseif ($_.Exception.Message -match "429") {
        Write-Host ""
        Write-Host "Rate limit exceeded. Wait a few seconds and try again." -ForegroundColor Yellow
    }
}
```

**Just copy the entire block and paste in PowerShell!**

---

## Method 6: Test Inside Your Flutter App

Run this from your project:

```bash
cd C:\KrishiBondhuAI
flutter run
```

Then:
1. Register/Login
2. Go to Chat screen
3. Send a message: "আমার জমিতে পাতা হলুদ হচ্ছে"
4. If you get a response → API working ✅
5. If error → Check logs

---

## Common Error Messages & Solutions

### ❌ "API_KEY_INVALID" or 403 Forbidden
**Problem**: API key is wrong or not activated

**Solutions**:
1. Go to https://aistudio.google.com/app/apikey
2. Verify the key matches: `AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU`
3. If not, copy the correct key
4. Update in `lib/core/config/app_config.dart`:
   ```dart
   static const String geminiApiKey = 'YOUR_NEW_KEY_HERE';
   ```

### ❌ "Generative Language API has not been used"
**Problem**: API not enabled in Google Cloud Console

**Solutions**:
1. Go to: https://console.cloud.google.com/apis/library
2. Search: "Generative Language API"
3. Click **Enable**
4. Wait 2-3 minutes
5. Test again

### ❌ 429 "Resource exhausted"
**Problem**: Rate limit exceeded (60 requests/minute on free tier)

**Solutions**:
- Wait 60 seconds
- Your app now has retry logic (automatically retries with delays)
- Upgrade to paid tier for higher limits

### ❌ "Billing not enabled"
**Problem**: Need to set up billing (even for free tier)

**Solutions**:
1. Go to: https://console.cloud.google.com/billing
2. Link a billing account (credit card)
3. Don't worry - free tier has generous limits
4. You won't be charged unless you exceed free quota

---

## Check API Quotas

Free tier limits:
- **60 requests per minute**
- **1500 requests per day**
- **1 million tokens per month**

To check your usage:
1. https://console.cloud.google.com/
2. Select project
3. **APIs & Services → Quotas**
4. Search: "Generative Language API"

---

## Verify API Key Format

Valid Gemini API key should:
- ✅ Start with `AIza`
- ✅ Be 39 characters long
- ✅ Contain only letters, numbers, hyphens, underscores

Your key: `AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU`
- Length: 39 ✅
- Format: Valid ✅

---

## Generate New API Key (If Needed)

1. Go to: https://aistudio.google.com/app/apikey
2. Click **"Create API Key"**
3. Select existing project or create new
4. Copy the new key
5. Update in your app:
   - File: `lib/core/config/app_config.dart`
   - Line 8: `static const String geminiApiKey = 'NEW_KEY';`

---

## Test Both Models

Your app uses 2 Gemini models:

### Test gemini-pro (text only):
```powershell
$apiKey = "AIzaSyBraIDDuf8yY3wBLsRA2RfOKAx3o_XO4uU"
Invoke-RestMethod -Uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey" -Method Post -Body '{"contents":[{"parts":[{"text":"Test"}]}]}' -ContentType "application/json"
```

### Test gemini-pro-vision (text + image):
```powershell
# This requires image data, easier to test in the app
```

---

## Monitor API in Real-Time

While testing your Flutter app:

**Terminal 1** (Run app):
```bash
flutter run --verbose
```

Look for logs:
```
[INFO] Sending message to Gemini: ...
[INFO] Received response from Gemini
```

**Terminal 2** (Watch errors):
```bash
flutter logs
```

---

## Quick Health Check Commands

### Check if API is reachable:
```powershell
Test-NetConnection -ComputerName generativelanguage.googleapis.com -Port 443
```

### Check API status page:
Open: https://status.cloud.google.com/

---

## 🎯 Recommended Test Sequence

1. **Run PowerShell test script** (5 seconds)
   - If ✅ → API key works!
   - If ❌ → Check error message

2. **Check Google Cloud Console** (1 minute)
   - Verify API is enabled
   - Check quota usage

3. **Test in Flutter app** (2 minutes)
   - Most realistic test
   - Tests actual integration

---

## Need Help?

If API still not working after all checks:

1. **Generate new API key**:
   - https://aistudio.google.com/app/apikey
   
2. **Enable billing** (required even for free tier):
   - https://console.cloud.google.com/billing

3. **Wait 2-3 minutes** after enabling API

4. **Check service status**:
   - https://status.cloud.google.com/

---

**Quick Test**: Run the PowerShell script above right now to instantly verify if your API key works! 🚀
