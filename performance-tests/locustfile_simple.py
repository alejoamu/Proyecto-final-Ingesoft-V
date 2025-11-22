"""
Locust Performance Tests for E-commerce Microservices - Simplified Version
Focus on GET operations that work without authentication
"""

from locust import HttpUser, task, between
import json
import random
import time

class EcommerceUser(HttpUser):
    """Main user class for e-commerce performance testing - simplified"""
    wait_time = between(1, 3)
    
    def on_start(self):
        """Initialize user session data"""
        self.user_id = random.randint(1, 10)
        self.product_id = random.randint(1, 10)

    # ==================== PRODUCT SERVICE TESTS ====================
    
    @task(20)
    def product_browse_catalog(self):
        """Use Case 1: Browse product catalog - most common action"""
        with self.client.get("/app/api/products", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data and len(data["collection"]) > 0:
                        response.success()
                    else:
                        response.failure("Empty or invalid product catalog")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(15)
    def product_search_by_id(self):
        """Use Case 2: Search for specific product by ID"""
        product_id = random.randint(1, 10)
        with self.client.get(f"/app/api/products/{product_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "productId" in data or "productTitle" in data:
                        response.success()
                    else:
                        response.failure("Invalid product data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(10)
    def product_search_by_sku(self):
        """Use Case 3: Search for product by SKU"""
        skus = ["SKU001", "SKU002", "SKU003", "SKU004", "SKU005"]
        sku = random.choice(skus)
        with self.client.get(f"/app/api/products/sku/{sku}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "productId" in data or "sku" in data:
                        response.success()
                    else:
                        response.failure("Invalid product data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def product_search_by_category(self):
        """Use Case 4: Search products by category"""
        categories = ["Electronics", "Clothing", "Books", "Home", "Sports"]
        category = random.choice(categories)
        with self.client.get(f"/app/api/products/category/{category}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid category data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(5)
    def product_search_by_price_range(self):
        """Use Case 5: Search products by price range"""
        min_price = random.randint(10, 100)
        max_price = min_price + random.randint(50, 200)
        with self.client.get(f"/app/api/products/price-range?min={min_price}&max={max_price}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid price range data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== USER SERVICE TESTS ====================
    
    @task(12)
    def user_browse_users(self):
        """Use Case 1: Browse user list (admin action)"""
        with self.client.get("/app/api/users", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(10)
    def user_get_by_username(self):
        """Use Case 2: Get user by username (login scenario)"""
        usernames = ["testuser", "admin", "selimhorri", "amineladjimi", "omarderouiche"]
        username = random.choice(usernames)
        with self.client.get(f"/app/api/users/username/{username}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "firstName" in data:
                        response.success()
                    else:
                        response.failure("Invalid user data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def user_get_by_email(self):
        """Use Case 3: Get user by email"""
        emails = ["test@example.com", "admin@example.com", "selim@example.com"]
        email = random.choice(emails)
        with self.client.get(f"/app/api/users/email/{email}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "email" in data:
                        response.success()
                    else:
                        response.failure("Invalid user data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def user_get_by_phone(self):
        """Use Case 4: Get user by phone number"""
        phones = ["+1234567890", "+0987654321", "+1122334455"]
        phone = random.choice(phones)
        with self.client.get(f"/app/api/users/phone/{phone}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "phone" in data:
                        response.success()
                    else:
                        response.failure("Invalid user data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def user_get_by_id(self):
        """Use Case 5: Get user by ID"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/users/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "firstName" in data:
                        response.success()
                    else:
                        response.failure("Invalid user data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== ORDER SERVICE TESTS ====================
    
    @task(10)
    def order_browse_orders(self):
        """Use Case 1: Browse orders (order history)"""
        with self.client.get("/app/api/orders", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid order list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def order_get_by_id(self):
        """Use Case 2: Get order by ID (order details)"""
        order_id = random.randint(1, 10)
        with self.client.get(f"/app/api/orders/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "orderId" in data or "orderDesc" in data:
                        response.success()
                    else:
                        response.failure("Invalid order data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def order_get_by_user(self):
        """Use Case 3: Get orders by user ID"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/orders/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user orders data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def order_get_by_status(self):
        """Use Case 4: Get orders by status"""
        statuses = ["PENDING", "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED"]
        status = random.choice(statuses)
        with self.client.get(f"/app/api/orders/status/{status}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid status orders data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def order_get_by_date_range(self):
        """Use Case 5: Get orders by date range"""
        start_date = "2024-01-01"
        end_date = "2024-12-31"
        with self.client.get(f"/app/api/orders/date-range?start={start_date}&end={end_date}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid date range orders data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== PAYMENT SERVICE TESTS ====================
    
    @task(10)
    def payment_browse_payments(self):
        """Use Case 1: Browse payment history"""
        with self.client.get("/app/api/payments", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid payment list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def payment_get_by_id(self):
        """Use Case 2: Get payment by ID (payment details)"""
        payment_id = random.randint(1, 10)
        with self.client.get(f"/app/api/payments/{payment_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "paymentId" in data or "isPayed" in data:
                        response.success()
                    else:
                        response.failure("Invalid payment data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def payment_get_by_order(self):
        """Use Case 3: Get payment by order ID"""
        order_id = random.randint(1, 10)
        with self.client.get(f"/app/api/payments/order/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "paymentId" in data or "order" in data:
                        response.success()
                    else:
                        response.failure("Invalid order payment data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def payment_get_by_status(self):
        """Use Case 4: Get payments by status"""
        statuses = ["IN_PROGRESS", "COMPLETED", "FAILED", "REFUNDED"]
        status = random.choice(statuses)
        with self.client.get(f"/app/api/payments/status/{status}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid status payments data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def payment_get_by_user(self):
        """Use Case 5: Get payments by user ID"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/payments/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user payments data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== SHIPPING SERVICE TESTS ====================
    
    @task(10)
    def shipping_browse_shippings(self):
        """Use Case 1: Browse shipping records"""
        with self.client.get("/app/api/shippings", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid shipping list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def shipping_track_shipment(self):
        """Use Case 2: Track shipment (tracking functionality)"""
        shipping_id = random.randint(1, 10)
        with self.client.get(f"/app/api/shippings/{shipping_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "shippingId" in data or "shippingStatus" in data:
                        response.success()
                    else:
                        response.failure("Invalid shipping data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def shipping_get_by_order(self):
        """Use Case 3: Get shipping by order ID"""
        order_id = random.randint(1, 10)
        with self.client.get(f"/app/api/shippings/order/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "shippingId" in data or "order" in data:
                        response.success()
                    else:
                        response.failure("Invalid order shipping data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def shipping_get_by_status(self):
        """Use Case 4: Get shippings by status"""
        statuses = ["PENDING", "SHIPPED", "IN_TRANSIT", "DELIVERED", "CANCELLED"]
        status = random.choice(statuses)
        with self.client.get(f"/app/api/shippings/status/{status}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid status shippings data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def shipping_get_by_user(self):
        """Use Case 5: Get shippings by user ID"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/shippings/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user shippings data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== FAVOURITE SERVICE TESTS ====================
    
    @task(8)
    def favourite_browse_favourites(self):
        """Use Case 1: Browse user favourites"""
        with self.client.get("/app/api/favourites", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid favourite list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def favourite_get_user_favourites(self):
        """Use Case 2: Get user's favourites (wishlist view)"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/favourites/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user favourites format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def favourite_get_by_product(self):
        """Use Case 3: Get favourites by product ID"""
        product_id = random.randint(1, 10)
        with self.client.get(f"/app/api/favourites/product/{product_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid product favourites format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(3)
    def favourite_get_by_id(self):
        """Use Case 4: Get favourite by ID"""
        favourite_id = random.randint(1, 10)
        with self.client.get(f"/app/api/favourites/{favourite_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "productId" in data:
                        response.success()
                    else:
                        response.failure("Invalid favourite data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def favourite_get_by_category(self):
        """Use Case 5: Get favourites by category"""
        categories = ["Electronics", "Clothing", "Books", "Home", "Sports"]
        category = random.choice(categories)
        with self.client.get(f"/app/api/favourites/category/{category}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid category favourites format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")


class HighLoadUser(HttpUser):
    """High load user for stress testing - simplified"""
    wait_time = between(0.1, 0.5)
    weight = 1  # 1 in 10 users will be high load
    
    @task(20)
    def rapid_product_queries(self):
        """Stress test: Rapid product queries"""
        product_id = random.randint(1, 50)
        self.client.get(f"/app/api/products/{product_id}")
    
    @task(15)
    def rapid_user_queries(self):
        """Stress test: Rapid user queries"""
        usernames = ["testuser", "admin", "selimhorri", "amineladjimi", "omarderouiche"]
        username = random.choice(usernames)
        self.client.get(f"/app/api/users/username/{username}")
    
    @task(10)
    def rapid_collection_queries(self):
        """Stress test: Rapid collection queries"""
        endpoints = ["/app/api/products", "/app/api/users", "/app/api/orders", 
                    "/app/api/payments", "/app/api/shippings", "/app/api/favourites"]
        endpoint = random.choice(endpoints)
        self.client.get(endpoint)
