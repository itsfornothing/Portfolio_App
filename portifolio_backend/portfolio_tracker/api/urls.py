from django.urls import path
from . import views


urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.LogoutView.as_view(), name='logout'),

    path('home/', views.HomeScreenView.as_view(), name='home'),

    path('admin-profile/update/', views.CreateAdminProfileView.as_view(), name='admin-profile-update'),

    path('skills/add/', views.CreateAdminSkillView.as_view(), name='add-skill'),
    path('skills/delete/<int:pk>/', views.CreateAdminSkillView.as_view(), name='delete-skill'),

    path('project/add/', views.CreateAdminProjectView.as_view(), name='project-add'),
    path('project/delete/<int:pk>/', views.CreateAdminProjectView.as_view(), name='project-delete'),
    
    path('blog/add/', views.CreateAdminBlogView.as_view(), name='blog-add'),
    path('blog/delete/<str:title>/', views.CreateAdminBlogView.as_view(), name='blog-delete'),
    path('blogs/', views.AdminBlogView.as_view(), name='get-blogs'),

    path('blog/comments/<str:title>/', views.BlogCommentsView.as_view(), name='blog-comments'),
    path('project/comments/<str:title>/', views.ProjectCommentsView.as_view(), name='project-comments'),


    path('user-profile/', views.ProfileView.as_view(), name='profile')
]