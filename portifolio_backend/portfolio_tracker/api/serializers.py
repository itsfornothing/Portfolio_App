from rest_framework import serializers
from .models import CustomUser, AdminProfile, Skill, Project, BlogPost, BlogComment, ProjectComment
from django.contrib.auth import authenticate


class RegisterationSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    fullname = serializers.CharField(required=True)
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = CustomUser
        fields = ['email', 'username', 'fullname', 'password']

    def validate_email(self, value):
        if CustomUser.objects.filter(email__iexact=value.lower()).exists():
            raise serializers.ValidationError('This email is already in use.')
        return value.lower()

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError('Password must be at least 8 characters long.')
        if not any(char.isupper() for char in value):
            raise serializers.ValidationError('Password must contain at least one uppercase letter.')
        if not any(char.isdigit() for char in value):
            raise serializers.ValidationError('Password must contain at least one number.')
        return value

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            fullname=validated_data['fullname'],
            username=validated_data.get('username', validated_data['fullname']),
            email=validated_data['email']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')
        user = authenticate(email=email, password=password)
        if user:
            data['user'] = user
            return data
        raise serializers.ValidationError({'error': 'Invalid credentials'})


class AdminProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdminProfile
        fields = ['user', 'career', 'country', 'city', 'about_me']
        extra_kwargs = {
                    'user': {'write_only': True}
                }

class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['email', 'fullname', 'profile_url']
        read_only_fields = ['email', 'fullname']


class AdminSkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ['user', 'name', 'last_updated']
        read_only_fields = ['user', 'last_updated']


class AdminProjectSerializer(serializers.ModelSerializer):
    user = ProfileSerializer(read_only=True)
    class Meta:
        model = Project
        fields = ['user', 'title', 'description', 'image']
        read_only_fields = ['user']


class AdminBlogSerializer(serializers.ModelSerializer):
    author = ProfileSerializer(read_only=True)
    class Meta:
        model = BlogPost
        fields = ['title',  'content', 'category', 'image', 'author', 'created_at', 'updated_at']
        read_only_fields = ['author', 'created_at', 'updated_at']


class BlogCommentsSerializer(serializers.ModelSerializer):
    user = ProfileSerializer(read_only=True)
    blog_post = AdminBlogSerializer(read_only=True)
    class Meta:
        model = BlogComment
        fields = ['blog_post', 'user', 'content', 'created_at']
        read_only_fields = ['user', 'created_at']

    def validate_content(self, value):
        if len(value.strip()) < 1:
            raise serializers.ValidationError('Comment content cannot be empty.')
        return value
    

class ProjectCommentsSerializer(serializers.ModelSerializer):
    user = ProfileSerializer(read_only=True)
    project = AdminProjectSerializer(read_only=True)
    class Meta:
        model = ProjectComment
        fields = ['project', 'user', 'content', 'created_at']
        read_only_fields = ['user', 'created_at']

    def validate_content(self, value):
        if len(value.strip()) < 1:
            raise serializers.ValidationError('Comment content cannot be empty.')
        return value


class HomeScreenSerializer(serializers.ModelSerializer):
    profile = AdminProfileSerializer(source="adminprofile", read_only=True)
    skills = AdminSkillSerializer(source="skill_set", many=True, read_only=True)  # Changed from 'skill_set'
    projects = AdminProjectSerializer(source="project_set", many=True, read_only=True)  # Changed from 'project_set'

    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'fullname', 'profile_url', 'profile', 'skills', 'projects']

    