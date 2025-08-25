from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.core.validators import RegexValidator

class CustomUserManager(BaseUserManager):
    def create_user(self, email, fullname, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        user = self.model(email=email, fullname=fullname, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, fullname, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, fullname, password, **extra_fields)

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    fullname = models.CharField(max_length=50, validators=[RegexValidator(r'^[a-zA-Z\s-]+$', 'Full name can only contain letters, spaces, or hyphens.')])
    username = models.CharField(max_length=150, unique=False, blank=True, null=True)
    profile_url = models.URLField(max_length=1250, blank=True, null=True) 
    
    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['fullname']

    def save(self, *args, **kwargs):
        if not self.username:  
            self.username = self.fullname.lower().replace(' ', '_')[:150]
        super().save(*args, **kwargs)


class AdminProfile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE, related_name='adminprofile')
    career = models.CharField(max_length=255, unique=True, blank=True, null=True)
    country = models.CharField(max_length=50, unique=True, blank=True, null=True)
    city = models.CharField(max_length=100, unique=True, blank=True, null=True)
    about_me = models.TextField(blank=True)


class BlacklistedToken(models.Model):
    token = models.CharField(max_length=500, unique=True)
    blacklisted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'blacklisted_tokens'
        indexes = [models.Index(fields=['blacklisted_at'])]


class Skill(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='skill_set')
    name = models.CharField(max_length=50, unique=True)
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'name']


class Project(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='project_set') 
    title = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    image = models.URLField(blank=True, null=True)

    class Meta:
        unique_together = ['user', 'title']  
        indexes = [models.Index(fields=['user'])]  


class BlogPost(models.Model):
    title = models.CharField(max_length=100, unique=True)
    content = models.TextField()
    category = models.CharField(max_length=100)
    image = models.URLField(blank=True, null=True)  
    author = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='blogs')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


    class Meta:
        indexes = [models.Index(fields=['author'])]


class BlogComment(models.Model):
    blog_post = models.ForeignKey(BlogPost, on_delete=models.CASCADE, related_name='blog_comments')
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='blog_comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [models.Index(fields=['blog_post', 'created_at'])]


class ProjectComment(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='project_comments')
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='project_comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [models.Index(fields=['project', 'created_at'])]
