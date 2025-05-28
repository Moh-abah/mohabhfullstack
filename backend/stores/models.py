from django.apps import AppConfig
from django.conf import settings
from django.db import models
from django.forms import ValidationError


class Store(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='stores',
        limit_choices_to={"user_type": "merchant"}  # فقط التجار يمكنهم إنشاء متجر
    )

   
    name_store = models.CharField(max_length=100)
    category = models.CharField(max_length=50, null=True, blank=True)
    subcategory = models.CharField(max_length=50, null=True, blank=True)
    description = models.TextField(null=True, blank=True)  # إضافة حقل الوصف
    location = models.JSONField(default=dict)  # حفظ الإحداثيات
    images = models.JSONField()  # قائمة الصور
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def clean(self):
        if not self.location or 'latitude' not in self.location or 'longitude' not in self.location:
            raise ValidationError("Location must include both latitude and longitude.")
        
        
    def save(self, *args, **kwargs):
        self.clean()  # التأكد من صحة البيانات قبل الحفظ
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name_store
    