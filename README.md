# LG_AI_Controller

<h2>Introduction:</h2>
This is a user-friendly application that helps you find places on the LG Rigs with text queries and visual markers. It also displays detailed responses of the Gemini API with the help of  KML on the LG Rigs. With voice features, Galaxy Glider can speak responses and understand voice commands. Plus, easy-access buttons on the left of the main screen let you relaunch LG, shut down LG, clean KML, and disable voice. 

<h2>Key Features:</h2>

<h4>Text-Based Queries with Visual Markers:</h4> Users can input text queries to locate places on the LG Rig, which are then displayed using visual markers for easy identification.

<h4>KML Balloons for Detailed Responses:</h4> Detailed responses to queries are provided via KML balloons, enhancing clarity and comprehension.


<h4>Voice Interaction with Galaxy Glider:</h4> The system offers voice interaction capabilities through Galaxy Glider, allowing users to receive responses in voice format and also accepts commands via voice.


<h4>Convenient Button Functionality:</h4> The interface includes easy-access buttons for relaunch LG, shut down LG, clean KML, and disable voice, streamlining user interactions and device control.

## Tech Stacks:

- **Flutter:**
  - Flutter is a cross-platform framework for building Mobile Apps.
  - Packages used in the project:
    - flutter_tts: Text to speech package used to convert text to voice.
    - speech_to_text: Used for converting speech to text when the user clicks on the mic icon.
    - Google_generative_ai: Google AI Dart SDK for Flutter to use Google's state-of-the-art generative AI models (like Gemini) to build AI-powered features and applications.
    - Lottie: Used for showing animations.

- **Gemini API:**
  - Gemini is a family of multimodal large language models developed by Google DeepMind, serving as the successor to LaMDA and PaLM 2.
  - The Gemini API provides an additional way to receive responses from generative AI models like Gemini Pro: as a data stream.

## Basic Working of the Application:
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/ae292736-0320-4658-8494-7f7feb25c357" alt="image1" width="800" height="500">

## Input:
- User provides the prompt via text or voice.

### Request:
- The prompt is sent to the Gemini model using the Gemini API.

### Response:
- The response collected is utilized in two ways:
  - Shown to the user in the tablet.
  - Sent to LG rigs in KML format.
- The response is collected and re-prompted for fetching locations.
- Re-prompting involves fetching names and places.
- Returns a list of strings if the location is found, else empty.

### Parsing and Showing Visual Markers:
- The list of places is parsed.
- The SSH command for navigation is sent to locate each place inside a loop, with a delay of 7-8 seconds between iterations.

## How to Run?

1. Clone the repository.
2. Ensure you have Flutter and Dart installed.
3. Run `flutter pub get` to fetch the project dependencies.
4. Execute `flutter run` to launch the application on an emulator (10-inch tablet) or connected tablet device.
   
## Some Uses of This Project:

- **Helps Visualize Different Places with Just a Prompt:**
  - Users can gain insights into various locations simply by providing a prompt, enhancing their understanding and exploration of different areas.

- **Assists in Exploring Different Places:**
  - Enables users to explore a wide range of places, including historical sites, disaster areas, and more, fostering learning and discovery.

## Screens:
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/ccd27b23-fa84-42b6-abef-315894fef2f5" alt="image1" width="300" height="200">
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/8424687a-b558-4a8f-a571-cf629e89c30b" alt="image5" width="300" height="200">
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/2e061646-81ff-467e-ae44-e0a44f675a21" alt="image4" width="300" height="200">
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/5ec225ad-212a-429a-b0c8-fce2d2edd8c5" alt="image3" width="300" height="200">
<img src="https://github.com/Saumya-28/LG_AI_Controller/assets/98171392/1dcace63-4a06-4cdf-bddb-b5d8ad4c9a50" alt="image2" width="300" height="200">


