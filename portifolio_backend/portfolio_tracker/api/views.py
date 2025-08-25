import jwt
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, timedelta, timezone
from django.conf import settings
from .serializers import RegisterationSerializer, LoginSerializer, AdminProfileSerializer, ProfileSerializer, AdminProjectSerializer, AdminSkillSerializer, AdminBlogSerializer, BlogCommentsSerializer, HomeScreenSerializer, ProjectCommentsSerializer
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.throttling import AnonRateThrottle
from .authentication import JWTAuthentication
from .models import BlacklistedToken, CustomUser, Skill, Project, BlogPost, BlogComment, AdminProfile, ProjectComment
from .permissions import IsAdminUser
from rest_framework.pagination import PageNumberPagination

def generate_token(user):
    try:
        expire_time = datetime.now(timezone.utc) + timedelta(days=7)
        payload = {
            'user_id': user.id,
            'username': user.username,
            'is_admin': user.is_superuser,  
            'exp': expire_time,
            'iat': datetime.now(timezone.utc),
        }
        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        return token, expire_time
    except Exception as e:
        raise Exception(f"Failed to generate token: {str(e)}")

class HomeScreenView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [AllowAny] 
    def get(self, request):
        try:
            admin = CustomUser.objects.get(is_superuser=True)
            serializer = HomeScreenSerializer(admin, context={'request': request})
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({"status": "error", "message": "Admin not found"}, status=status.HTTP_404_NOT_FOUND)

class RegisterView(APIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]
    authentication_classes = []
    def post(self, request):
        serializer = RegisterationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, expire_time = generate_token(user)
            return Response({"status": "success", "data": {"token": token, "expires_at": expire_time}}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, expire_time = generate_token(user)
            return Response({"status": "success", "data": {"token": token, "expires_at": expire_time}}, status=status.HTTP_200_OK)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_401_UNAUTHORIZED)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    authentication_classes = [JWTAuthentication]
    def post(self, request):
        try:
            token = request.auth
            user = request.user
            is_admin = user.is_superuser
            BlacklistedToken.objects.create(token=token)
            return Response({
                "status": "success",
                "message": "Successfully logged out",
                "is_admin": is_admin  
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CreateAdminProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated, IsAdminUser]
    def patch(self, request):
        try:
            profile, created = AdminProfile.objects.get_or_create(user=request.user)
            serializer = AdminProfileSerializer(
                profile,
                data=request.data,
                partial=True,
                context={'request': request}
            )
            if serializer.is_valid():
                serializer.save()
                print(f"Saved AdminProfile for {request.user.email}: {serializer.data}")  # Debug
                return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
            return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            print(f"Error updating AdminProfile: {str(e)}")  # Debug
            return Response({"status": "error", "message": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class CreateAdminSkillView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated, IsAdminUser]
    def post(self, request):
        serializer = AdminSkillSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        try:
            skill = Skill.objects.get(pk=pk, user=request.user)
            skill.delete()
            return Response({"status": "success", "message": "Skill deleted"}, status=status.HTTP_204_NO_CONTENT)
        except Skill.DoesNotExist:
            return Response({"status": "error", "message": "Skill not found"}, status=status.HTTP_404_NOT_FOUND)

class CreateAdminProjectView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated, IsAdminUser]
    def post(self, request):
        serializer = AdminProjectSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk):
        try:
            project = Project.objects.get(pk=pk, user=request.user)
            project.delete()
            return Response({"status": "success", "message": "Project deleted"}, status=status.HTTP_204_NO_CONTENT)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found"}, status=status.HTTP_404_NOT_FOUND)

class CreateAdminBlogView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated, IsAdminUser]
    def post(self, request):
        serializer = AdminBlogSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(author=request.user)
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, title):
        try:
            blog = BlogPost.objects.get(title=title, author=request.user)
            blog.delete()
            return Response({"status": "success", "message": "Blog deleted"}, status=status.HTTP_204_NO_CONTENT)
        except BlogPost.DoesNotExist:
            return Response({"status": "error", "message": "Blog not found"}, status=status.HTTP_404_NOT_FOUND)

class AdminBlogView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination
    def get(self, request):
        try:
            admin = CustomUser.objects.get(is_superuser=True)
            blogs = BlogPost.objects.filter(author=admin)
            paginator = self.pagination_class()
            page = paginator.paginate_queryset(blogs, request)
            serializer = AdminBlogSerializer(page, many=True)
            return paginator.get_paginated_response({"status": "success", "data": serializer.data})
        except CustomUser.DoesNotExist:
            return Response({"status": "error", "message": "Admin not found"}, status=status.HTTP_404_NOT_FOUND)

class BlogCommentsView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination

    def post(self, request, title):
        try:
            blog = BlogPost.objects.get(title=title)
        except BlogPost.DoesNotExist:
            return Response({"status": "error", "message": "Blog not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = BlogCommentsSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user, blog_post=blog)
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, title):
        try:
            blog = BlogPost.objects.get(title=title)
            comments = BlogComment.objects.filter(blog_post=blog)
            paginator = self.pagination_class()
            page = paginator.paginate_queryset(comments, request)
            serializer = BlogCommentsSerializer(page, many=True, context={'request': request})
            return paginator.get_paginated_response({"status": "success", "data": serializer.data})
        except BlogPost.DoesNotExist:
            return Response({"status": "error", "message": "Blog not found"}, status=status.HTTP_404_NOT_FOUND)

    # def patch(self, request, pk):
    #     try:
    #         comment = BlogComment.objects.get(pk=pk, user=request.user)
    #         serializer = BlogCommentsSerializer(comment, data=request.data, partial=True, context={'request': request})
    #         if serializer.is_valid():
    #             serializer.save()
    #             return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    #         return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    #     except BlogComment.DoesNotExist:
    #         return Response({"status": "error", "message": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)


class ProjectCommentsView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination

    def post(self, request, title):
        try:
            project = Project.objects.get(title=title)
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = ProjectCommentsSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save(user=request.user, project=project)
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, title):
        try:
            project = Project.objects.get(title=title)
            comments = ProjectComment.objects.filter(project=project)
            paginator = self.pagination_class()
            page = paginator.paginate_queryset(comments, request)
            serializer = ProjectCommentsSerializer(page, many=True, context={'request': request})
            return paginator.get_paginated_response({"status": "success", "data": serializer.data})
        except Project.DoesNotExist:
            return Response({"status": "error", "message": "Project not found"}, status=status.HTTP_404_NOT_FOUND)

    # def patch(self, request, pk):
    #     try:
    #         comment = ProjectComment.objects.get(pk=pk, user=request.user)
    #         serializer = ProjectCommentsSerializer(comment, data=request.data, partial=True, context={'request': request})
    #         if serializer.is_valid():
    #             serializer.save()
    #             return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    #         return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    #     except ProjectComment.DoesNotExist:
    #         return Response({"status": "error", "message": "Comment not found"}, status=status.HTTP_404_NOT_FOUND)

class ProfileView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]
    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    def patch(self, request):
        serializer = ProfileSerializer(
            request.user,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response({"status": "success", "data": serializer.data}, status=status.HTTP_200_OK)
        return Response({"status": "error", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)