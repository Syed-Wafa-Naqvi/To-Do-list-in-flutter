from django.db import models
from .product_model import Product

class CartItem(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    session_id = models.CharField(max_length=255, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Cart Item'
        verbose_name_plural = 'Cart Items'
        unique_together = ('product', 'session_id')

    def __str__(self):
        return f"{self.quantity} x {self.product.name} (Session: {self.session_id[:8]})"

    @property
    def total_price(self):
        return self.product.price * self.quantity