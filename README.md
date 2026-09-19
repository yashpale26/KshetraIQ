# 🌾 KshetraIQ

### AI-Powered Agricultural Decision Support and Farm Intelligence System

KshetraIQ is a Flutter-based agricultural intelligence application designed to help users manage farm information and obtain AI-powered insights using structured agricultural data and agricultural images.

The application combines **Flutter, Dart, Firebase Authentication, Cloud Firestore and Google Gemini AI** to provide contextual farm analysis, crop recommendations, AI image analysis and an AI Assistant through a simple mobile application.

---

## 📱 Project Overview

Agricultural decision-making depends on multiple factors such as farm characteristics, field conditions, crop information, soil properties and environmental conditions.

KshetraIQ brings these factors together in a single application and uses Generative AI to analyze the recorded information and provide structured agricultural insights.

The application provides two primary AI analysis capabilities:

* **Farm Analysis** – analyzes structured farm, field, crop, soil and environmental information.
* **AI Image Analysis** – analyzes agricultural images captured using the camera or selected from the gallery.

KshetraIQ also includes an **AI Assistant** that allows users to interact with the system using natural-language questions.

---

## 🎯 Objectives

The main objectives of KshetraIQ are:

* To provide a digital platform for managing farm information.
* To organize farm, field, crop, soil and environmental data.
* To provide contextual AI-powered farm analysis.
* To analyze agricultural images using multimodal AI.
* To provide crop suitability recommendations.
* To provide understandable AI-generated explanations.
* To maintain a history of previous AI analyses.
* To provide an AI Assistant for agricultural queries.
* To demonstrate the integration of Flutter, Firebase and Generative AI.

---

# ✨ Key Features

## 🏠 Home Dashboard

The Home screen provides a summarized view of the user's selected farm.

It displays information such as:

* Selected farm
* Farm area
* Number of fields
* Number of crops
* Farm Intelligence Score
* Current crop
* Crop health
* Soil readings
* Environmental conditions
* Latest Farm Analysis
* Latest AI Image Analysis
* KshetraIQ AI insight
* Quick access to AI features

The dashboard acts as the main overview of the user's agricultural information and AI-generated intelligence.

---

## 🌾 Farm Management

Users can create and maintain their farm profile using structured information.

Farm information includes:

### Farm Details

* Farm name
* Location
* Farm area
* Farm type
* Water source

### Field Details

* Field name
* Field area
* Irrigation method
* Field condition

### Crop Details

* Crop name
* Sowing date
* Growth stage
* Crop health
* Expected harvest

### Soil Details

* Soil type
* pH
* Moisture
* Nitrogen
* Phosphorus
* Potassium

### Environment Details

* Temperature
* Humidity
* Rainfall
* Wind speed
* Weather condition
* Additional notes

The complete farm profile is stored in Cloud Firestore and can later be used as contextual input for AI analysis.

---

# ✨ AI Module

The AI module is the main intelligence component of KshetraIQ.

It contains three major capabilities:

```text
AI
│
├── 📊 Farm Analysis
│
├── 📷 AI Image Analysis
│
├── 💬 AI Assistant
│
└── 📜 Analysis History
```

---

## 📊 AI Farm Analysis

Farm Analysis uses the structured information stored in the user's farm profile.

The AI can consider:

* Farm details
* Field details
* Crop details
* Soil details
* Environmental details

The resulting report can include:

* Farm Intelligence Score
* Crop Health
* Crop Problem Analysis
* Soil Analysis
* Irrigation Analysis
* Environmental Analysis
* Risk Indicators
* Recommended Actions
* Crop Recommendation

The result is presented as a structured analytical report rather than a normal chatbot conversation.

---

## 🌱 Crop Recommendation

KshetraIQ uses the available farm information to provide crop suitability recommendations.

The analysis can consider factors such as:

* Farm characteristics
* Field characteristics
* Soil type
* Soil pH
* Soil moisture
* Nitrogen
* Phosphorus
* Potassium
* Temperature
* Humidity
* Rainfall
* Wind conditions

Potential crops can be presented using suitability percentages and visual progress bars.

Example:

```text
Crop Recommendation
────────────────────────────

🍅 Tomato

Suitability: 86%
█████████████████░░░

Why?
• Suitable soil conditions
• Suitable temperature conditions
• Manageable water requirement
• Recorded environmental conditions
```

> The suitability percentage represents an estimated assessment based on the available input data and should not be interpreted as a guaranteed crop success rate.

---

# 📷 AI Image Analysis

AI Image Analysis allows users to provide an agricultural image for AI-powered analysis.

Images can be:

* Captured using the camera
* Selected from the gallery

The feature can be used for images of:

* 🌱 Plants
* 🌾 Crops
* 🍃 Leaves
* 🌳 Agricultural fields
* 🌾 Farms
* 🧪 Soil
* 🧴 Fertilizer
* Crop problems or visible symptoms

The AI analyzes the provided image and generates a structured report based on the visible information.

The result can include:

* Detected subject
* Visual condition
* Health assessment
* Observed symptoms
* Possible problems
* Possible contributing factors
* Risk indicators
* Recommended actions
* KshetraIQ AI insight

---

# 💬 KshetraIQ AI Assistant

KshetraIQ includes an AI Assistant that allows users to interact with the application through natural-language questions.

Users can ask agricultural questions and receive AI-generated responses through the assistant interface.

The AI Assistant provides a conversational interface alongside the structured Farm Analysis and Image Analysis features.

Example questions may include:

```text
"What soil conditions are suitable for Tomato?"

"What should I monitor in my crop?"

"Why is soil moisture important?"

"What factors affect crop suitability?"
```

---

# 📜 AI Analysis History

KshetraIQ stores previous AI analyses so users can access them later.

The history can contain:

* Farm Analysis
* AI Image Analysis
* Analysis date
* Associated farm
* Analysis result

Previously generated analysis reports can be reopened without performing the AI analysis again.

Example:

```text
📊 Farm Analysis
Kshetra Farm
18 Sep 2026
Farm Score: 82/100

🖼 Image Analysis
Tomato Plant
17 Sep 2026
Health Assessment: 76%
```

---

# 🧠 Explainable AI

KshetraIQ is designed to present explanations along with AI-generated recommendations.

Instead of displaying only a recommendation, the application can show relevant factors that contributed to the result.

For example:

```text
Crop Recommendation
────────────────────────────

Tomato
Suitability: 86%

Contributing Factors:

• Suitable soil conditions
• Suitable temperature
• Manageable water requirement
• Recorded environmental conditions
```

This makes the generated analysis easier to understand.

---

# 👤 Profile

The Profile module is intentionally kept simple.

It provides:

* User profile information
* Logout

User authentication is handled through Firebase Authentication.

The Profile screen displays the authenticated user's account information and provides access to the logout functionality.

---

## 🚪 Logout

The logout feature allows the user to safely end their current Firebase Authentication session.

The logout process includes a confirmation step before signing the user out.

After logout:

```text
Profile
   ↓
Logout
   ↓
Confirmation
   ↓
Firebase Sign Out
   ↓
Login Screen
```

The user's saved farm information and AI analysis history remain stored in their account.

---

# 🔐 Firebase Authentication

Firebase Authentication is used for user account management.

The application supports authentication functionality such as:

* User registration
* Login
* Email verification
* Password reset
* Logout

Firebase Authentication manages the user's authenticated session.

---

# ☁️ Cloud Firestore

Cloud Firestore is used as the cloud database for KshetraIQ.

The application can store:

* User information
* Farm information
* Field information
* Crop information
* Soil information
* Environmental information
* AI Farm Analysis
* AI Image Analysis
* Analysis History

The stored farm information is also used as contextual data for Farm Analysis.

---

# 🤖 AI Processing Flow

## Farm Analysis

```text
User
  │
  ▼
Farm Data
  │
  ├── Farm Details
  ├── Field Details
  ├── Crop Details
  ├── Soil Details
  └── Environment Details
  │
  ▼
Cloud Firestore
  │
  ▼
KshetraIQ AI Service
  │
  ▼
Gemini AI
  │
  ▼
Structured Farm Analysis
  │
  ├── Crop Health
  ├── Crop Problem Analysis
  ├── Soil Analysis
  ├── Irrigation Analysis
  ├── Environmental Analysis
  ├── Risk Indicators
  ├── Recommended Actions
  └── Crop Recommendation
  │
  ▼
Save Analysis
  │
  ▼
Analysis History
```

---

## AI Image Analysis

```text
Camera / Gallery
       │
       ▼
Agricultural Image
       │
       ▼
KshetraIQ AI Service
       │
       ▼
Gemini Multimodal AI
       │
       ▼
Image Analysis
       │
       ├── Detected Subject
       ├── Visual Condition
       ├── Possible Problem
       ├── Risk Indicators
       └── Recommended Actions
       │
       ▼
Save Analysis
       │
       ▼
AI Analysis History
```

---

## 💬 AI Assistant Flow

```text
User Question
      │
      ▼
AI Assistant
      │
      ▼
KshetraIQ AI Service
      │
      ▼
Gemini AI
      │
      ▼
AI Response
      │
      ▼
Display Response
```

---

# 📱 Application Structure

The final application contains four main navigation modules:

```text
┌───────────────────────────────────────────────┐
│                  KshetraIQ                    │
├───────────────────────────────────────────────┤
│                                               │
│  🏠 Home                                      │
│      Farm dashboard and latest intelligence   │
│                                               │
│  🌾 Farms                                     │
│      Farm and agricultural data management    │
│                                               │
│  ✨ AI                                        │
│      Farm Analysis                            │
│      AI Image Analysis                        │
│      AI Assistant                             │
│      Analysis History                         │
│                                               │
│  👤 Profile                                   │
│      User information                         │
│      Logout                                   │
│                                               │
└───────────────────────────────────────────────┘
```

> **Note:** The Planner module is not part of the final KshetraIQ application.

---

# 🔄 Overall Application Workflow

```text
Register / Login
       │
       ▼
     Home
       │
       ▼
   Create Farm
       │
       ▼
Enter Farm Information
       │
       ├── Farm
       ├── Field
       ├── Crop
       ├── Soil
       └── Environment
       │
       ▼
Cloud Firestore
       │
       ▼
      AI
       │
       ├─────────────────┐
       ▼                 ▼
Farm Analysis      Image Analysis
       │                 │
       └────────┬────────┘
                ▼
        Structured Results
                │
                ▼
        Save Analysis History
                │
                ├───────────────┐
                ▼               ▼
        AI Assistant          Home
```

---

# 🛠️ Technology Stack

| Technology              | Purpose                               |
| ----------------------- | ------------------------------------- |
| Flutter                 | Mobile application development        |
| Dart                    | Programming language                  |
| Firebase Authentication | User authentication                   |
| Cloud Firestore         | Cloud database                        |
| Google Gemini AI        | Generative AI and multimodal analysis |
| Android Studio          | Development environment               |
| Git                     | Version control                       |
| GitHub                  | Source code hosting                   |

---

# 📂 Project Structure

The project follows a modular Flutter structure.

```text
KshetraIQ/
│
├── android/
├── assets/
│
├── lib/
│   ├── main.dart
│   │
│   ├── screens/
│   │   ├── home/
│   │   ├── farms/
│   │   ├── ai/
│   │   └── profile/
│   │
│   ├── services/
│   │   ├── firebase/
│   │   └── ai/
│   │
│   ├── widgets/
│   └── models/
│
├── test/
├── pubspec.yaml
├── firebase_options.dart
├── analysis_options.yaml
├── .gitignore
└── README.md
```

---

# 🔒 Security

Sensitive credentials must not be committed to the GitHub repository.

Do not commit:

```text
.env
API keys
Passwords
Private keys
Firebase service-account credentials
Service-account JSON files
```

The Gemini API key should be supplied using the project's secure configuration method rather than being exposed directly in the source code.

---

# ⚙️ Setup

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/KshetraIQ.git
```

## 2. Open the Project

Open the cloned project in Android Studio.

## 3. Install Flutter Dependencies

```bash
flutter pub get
```

## 4. Configure Firebase

Connect the project to your Firebase project and configure:

* Firebase Authentication
* Cloud Firestore

## 5. Configure Gemini AI

Provide the Gemini API key using the secure configuration method used by the project.

Do not hard-code the API key or commit it to GitHub.

## 6. Run the Application

```bash
flutter run
```

---

# 🎓 Academic Project

**Project Name:** KshetraIQ

**Project Title:**
**KshetraIQ: An AI-Powered Agricultural Decision Support and Farm Intelligence System**

**Degree:** MSc Artificial Intelligence

**Domain:** Artificial Intelligence / Agriculture

**Platform:** Android

**Framework:** Flutter

KshetraIQ demonstrates the practical integration of mobile application development, cloud-based data storage and Generative AI for an agricultural decision-support application.

---

# 📌 Disclaimer

KshetraIQ is an academic/project prototype designed to demonstrate the application of Artificial Intelligence in agriculture.

AI-generated analysis and recommendations are based on the information provided to the system and should not be interpreted as guaranteed agricultural outcomes or as a substitute for professional agricultural advice, laboratory testing or field-specific expert assessment.

---

# 👨‍💻 Developer

**Yash**

MSc Artificial Intelligence

---

# 🚀 Future Scope

Potential future improvements include:

* Real-time weather integration
* IoT-based soil monitoring
* Sensor-based agricultural monitoring
* Advanced crop disease detection
* Regional agricultural datasets
* Historical yield prediction
* Multilingual AI assistance
* Offline agricultural support
* Integration with additional agricultural data sources
* More advanced image-based crop analysis

---

# 📄 License

This project is developed as an academic project.

License information can be added according to the intended distribution of the project.

## 📱 Screenshots

|                                                                                                         |                                                                                                         |                                                                                                         |                                                                                                         |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/4d62c2a2-1737-4da3-806e-a90b26406883" width="180"> | <img src="https://github.com/user-attachments/assets/d8f6e3e1-31d4-4cd0-bca7-ebe88c8be192" width="180"> | <img src="https://github.com/user-attachments/assets/20b4f4aa-6f6e-41bf-8b6f-3a602a0e7ae3" width="180"> | <img src="https://github.com/user-attachments/assets/d07c83f7-7fce-4495-8797-2ef9d3e1d9bd" width="180"> |
| <img src="https://github.com/user-attachments/assets/1eb04579-f736-4784-b1bc-71af133c335c" width="180"> | <img src="https://github.com/user-attachments/assets/82bde3f8-b600-4726-8e84-a735a82a72a0" width="180"> | <img src="https://github.com/user-attachments/assets/ee4fe19d-87f8-45ee-a3f5-cbbcbfb3eb8d" width="180"> | <img src="https://github.com/user-attachments/assets/bffa0ffb-378f-4bff-b815-c26d18ba531c" width="180"> |
| <img src="https://github.com/user-attachments/assets/9dcec9fa-42af-4efd-9501-f93ac568a0ae" width="180"> | <img src="https://github.com/user-attachments/assets/3b934676-592c-4f76-98c4-d1bbf3d372f4" width="180"> | <img src="https://github.com/user-attachments/assets/e63981b2-ce20-44ab-8810-ce6a223d6216" width="180"> | <img src="https://github.com/user-attachments/assets/2542939d-b80e-4d2e-b538-9c6deebcb999" width="180"> |
| <img src="https://github.com/user-attachments/assets/1220bcb4-158f-4f70-a861-e02e22f341fd" width="180"> | <img src="https://github.com/user-attachments/assets/49405bd6-82e3-4dd2-9a74-4e1d5d63793e" width="180"> | <img src="https://github.com/user-attachments/assets/824e25a3-6ed1-47af-a000-778355c44492" width="180"> | <img src="https://github.com/user-attachments/assets/52b33e51-ddb4-431a-b0ec-48458f48b413" width="180"> |
| <img src="https://github.com/user-attachments/assets/39358900-cabf-49c5-a002-0084cad1fc70" width="180"> | <img src="https://github.com/user-attachments/assets/658eadf6-37a8-4a65-bc4a-d5f765988bd2" width="180"> | <img src="https://github.com/user-attachments/assets/cc73d71b-6861-4c91-8133-c967f0a047e9" width="180"> | <img src="https://github.com/user-attachments/assets/008907f3-8cdd-411d-8b16-6eed95747f9c" width="180"> |
| <img src="https://github.com/user-attachments/assets/73daab14-5ccc-4ca7-92d2-d81c0e2c7ac0" width="180"> |                                                                                                         |                                                                                                         |                                                                                                         |


