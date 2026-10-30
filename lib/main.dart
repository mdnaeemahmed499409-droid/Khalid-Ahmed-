# AI Prompt Master — Android starter

This is a Flutter starter project for the requested Bengali/English AI prompt app.

## Included in this starter
- Dark mobile UI branded **AI Prompt Master**
- Image picker (gallery)
- Video file picker
- Prompt result area
- Saved prompts stored locally
- AI chat screen placeholder
- Bengali/English interface copy

## Important: AI is not connected yet
The current project is a UI and upload-flow starter. It does not yet analyze media or answer questions. To make those features real, connect a secure backend service that:
1. Accepts the selected image/video upload.
2. Extracts video frames and relevant audio/transcript where appropriate.
3. Sends the media/context to a vision-capable AI model.
4. Returns a structured cinematic prompt in Bengali or English.
5. Handles chat requests.
6. Keeps provider API keys on the server, never inside the Android app.

## Run
1. Install Flutter SDK and Android Studio.
2. Extract this ZIP.
3. In this folder run `flutter pub get`.
4. Connect an Android phone with USB debugging enabled or start an emulator.
5. Run `flutter run`.

## Next development step
Implement a backend API (for example, `/analyze-media` and `/chat`) and replace the placeholder handlers in `lib/main.dart` with HTTP requests. Add upload size limits, authentication, consent, and secure file deletion.
