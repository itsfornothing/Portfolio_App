#Portfolio App
A full-stack portfolio application built with a Flutter frontend and a Django REST Framework backend. The app allows users to showcase their skills, projects, and blog posts, with features for user authentication, commenting, and profile management. The frontend is a responsive Flutter app, and the backend provides a RESTful API with JWT authentication.
Table of Contents

Features
Technologies
Project Structure
Setup Instructions
Backend Setup (Django)
Frontend Setup (Flutter)


API Endpoints
Usage
Testing
Contributing

Features

User Authentication: Register, login, and logout with JWT-based authentication.
Profile Management: View and update user profiles, including profile pictures and personal details (career, city, country, about me).
Skills Management: Admins can add and display skills.
Projects Showcase: Create, view, and delete projects with titles, descriptions, and images.
Blog Posts: Create, view, and delete blog posts with categories, content, and images.
Comments System: Add and view comments on blogs and projects, with timestamps displayed as "Today", "Yesterday", or "X days ago".
Responsive UI: Flutter frontend with a clean, scrollable layout and pinned comment input at the bottom.
Auto-Scrolling: Comments list auto-scrolls to the latest comment upon submission.
Error Handling: Robust error handling for API requests and invalid inputs.

Technologies

Frontend:
Flutter (Dart) for cross-platform mobile development
Dependencies: http, flutter_secure_storage, intl


Backend:
Django REST Framework (Python) for the API
Django for ORM and authentication
JWT (JSON Web Tokens) for secure authentication
SQLite (default) for database


Other:
Postman for API testing
Git for version control



Project Structure
portfolio_app/
├── backend/                     # Django backend
│   ├── portfolio/               # Main Django app
│   │   ├── migrations/          # Database migrations
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── authentication.py    # JWT authentication logic
│   │   ├── models.py           # Database models (CustomUser, Project, BlogPost, etc.)
│   │   ├── permissions.py       # Custom permissions
│   │   ├── serializers.py       # API serializers
│   │   ├── urls.py             # API routes
│   │   └── views.py            # API views
│   ├── manage.py               # Django management script
│   └── requirements.txt        # Python dependencies
├── frontend/                    # Flutter frontend
│   ├── lib/
│   │   ├── utils/
│   │   │   └── date_utils.dart  # Utility for formatting dates
│   │   ├── api_service.dart     # API client for backend communication
│   │   ├── blog_detail.dart     # Blog detail screen
│   │   ├── project_detail.dart  # Project detail screen
│   │   └── main.dart           # App entry point
│   ├── pubspec.yaml            # Flutter dependencies
│   └── android/ios/            # Platform-specific configs
├── README.md                   # This file

Setup Instructions
Backend Setup (Django)

Prerequisites:

Python 3.8+
pip
Virtualenv (recommended)


Clone the Repository:
git clone <repository-url>
cd portfolio_app/backend


Set Up Virtual Environment:
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate


Install Dependencies:
pip install -r requirements.txt

Note: Create a requirements.txt with:
django==4.2
djangorestframework==3.14
djangorestframework-simplejwt==5.2


Configure Settings:

Update portfolio/settings.py with your JWT_SECRET_KEY and database settings (default: SQLite).
Example:JWT_SECRET_KEY = 'your-secret-key'
JWT_ALGORITHM = 'HS256'




Run Migrations:
python manage.py makemigrations
python manage.py migrate


Create Superuser:
python manage.py createsuperuser


Run the Server:
python manage.py runserver


API will be available at http://127.0.0.1:8080/api/.



Frontend Setup (Flutter)

Prerequisites:

Flutter SDK (2.0+)
Dart
Android Studio/Xcode for emulators


Clone the Repository (if not already done):
git clone <repository-url>
cd portfolio_app/frontend


Install Dependencies:
flutter pub get

Ensure pubspec.yaml includes:
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  intl: ^0.19.0


Update API Base URL:

In lib/api_service.dart, ensure baseUrl matches your backend:static const String baseUrl = 'http://127.0.0.1:8080/api/';




Run the App:
flutter run


Select a device/emulator to launch the app.



API Endpoints



Endpoint
Method
Description
Authentication



/api/register/
POST
Register a new user
None


/api/login/
POST
Login and get JWT token
None


/api/logout/
POST
Logout and blacklist token
JWT


/api/home/
GET
Fetch homepage data (profile, skills, projects)
JWT


/api/admin-profile/update/
PATCH
Update admin profile
JWT, Admin


/api/skills/add/
POST
Add a skill
JWT, Admin


/api/project/add/
POST
Create a project
JWT, Admin


/api/project/delete/<pk>/
DELETE
Delete a project
JWT, Admin


/api/blog/add/
POST
Create a blog post
JWT, Admin


/api/blog/delete/<title>/
DELETE
Delete a blog post
JWT, Admin


/api/blogs/
GET
Fetch all blogs
JWT


/api/blog/comments/<title>/
GET/POST
Get/Add blog comments
JWT


/api/blog/comments/<pk>/
PATCH
Update a blog comment
JWT


/api/project/comments/<title>/
GET/POST
Get/Add project comments
JWT


/api/project/comments/<pk>/
PATCH
Update a project comment
JWT


/api/user-profile/
GET/PATCH
Get/Update user profile
JWT


Note: Replace <title> with the blog/project title and <pk> with the comment ID.
Usage

Register/Login: Create an account or log in to access the app.
Homepage: View admin profile, skills, and projects.
Blog/Project Details:
View blog posts or projects with details and images.
Add comments (pinned input at the bottom).
Comments auto-scroll to the latest upon submission.
Timestamps display as "Today", "Yesterday", or "X days ago".


Admin Actions (superuser only):
Update profile, add skills, create/delete projects/blogs via API.



Testing

Backend:
Use Postman to test API endpoints.
Example: POST /api/login/ with {"email": "user@example.com", "password": "Password123"}.
Verify responses match expected formats (e.g., {"status": "success", "data": {...}}).


Frontend:
Run flutter test for unit tests (if added).
Test on emulators/devices for UI behavior (e.g., auto-scroll, comment display).
Check console logs for API errors (print statements in api_service.dart).


Common Issues:
Ensure backend is running at http://127.0.0.1:8080.
Verify JWT token in requests (stored via flutter_secure_storage).
Check date formats for comments (ISO 8601, e.g., 2025-08-24T07:36:47.858184Z).



Contributing

Fork the repository.
Create a feature branch (git checkout -b feature-name).
Commit changes (git commit -m "Add feature").
Push to the branch (git push origin feature-name).
Open a pull request.
