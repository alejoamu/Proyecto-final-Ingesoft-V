"""
Locust Performance Tests for E-commerce Microservices
5 Real-world Use Cases per Microservice (50 total scenarios)
Intelligent tests that create data before using it and use only public endpoints
"""

from locust import HttpUser, task, between
import json
import random
import time


class EcommerceUser(HttpUser):
    """Main user class for e-commerce performance testing"""
    wait_time = between(1, 3)
    
    def on_start(self):
        """Initialize user session data and create test data"""
        self.created_product_ids = []
        self.created_user_ids = []
        self.created_order_ids = []
        self.created_payment_ids = []
        self.created_shipping_ids = []
        self.created_favourite_ids = []
        
        # Create initial test data
        self._create_initial_test_data()
    
    def _create_initial_test_data(self):
        """Create initial test data for this user session"""
        # Create a product for testing
        product_data = {
            "productTitle": f"PerfTest Product {random.randint(10000, 99999)}",
            "sku": f"PERF{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(10.0, 1000.0), 2),
            "quantity": random.randint(10, 100),
            "categoryDto": {
                "categoryId": 1,
                "categoryTitle": "Electronics"
            }
        }
        
        try:
            response = self.client.post("/app/api/products", 
                                       json=product_data, 
                                       headers={"Content-Type": "application/json"},
                                       catch_response=True)
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    if "productId" in data:
                        self.created_product_ids.append(data["productId"])
                    elif isinstance(data, dict) and any(k in data for k in ["id", "product_id"]):
                        product_id = data.get("id") or data.get("product_id")
                        if product_id:
                            self.created_product_ids.append(product_id)
                except:
                    pass
        except:
            pass
    
    def _get_existing_product_id(self):
        """Get an existing product ID from the catalog or use a created one"""
        if self.created_product_ids:
            return random.choice(self.created_product_ids)
        
        # Try to get product list and extract an ID
        try:
            response = self.client.get("/app/api/products", catch_response=True)
            if response.status_code == 200:
                try:
                    data = response.json()
                    products = []
                    if isinstance(data, list):
                        products = data
                    elif isinstance(data, dict) and "collection" in data:
                        products = data["collection"]
                    elif isinstance(data, dict) and "content" in data:
                        products = data["content"]
                    
                    if products and len(products) > 0:
                        product = random.choice(products)
                        product_id = product.get("productId") or product.get("id") or product.get("product_id")
                        if product_id:
                            return product_id
                except:
                    pass
        except:
            pass
        
        # Fallback: return None to skip this test
        return None
    
    def _get_existing_user_id(self):
        """Get an existing user ID from the list or use a created one"""
        if self.created_user_ids:
            return random.choice(self.created_user_ids)
        
        # Try to get user list and extract an ID
        try:
            response = self.client.get("/app/api/users", catch_response=True)
            if response.status_code == 200:
                try:
                    data = response.json()
                    users = []
                    if isinstance(data, list):
                        users = data
                    elif isinstance(data, dict) and "collection" in data:
                        users = data["collection"]
                    elif isinstance(data, dict) and "content" in data:
                        users = data["content"]
                    
                    if users and len(users) > 0:
                        user = random.choice(users)
                        user_id = user.get("userId") or user.get("id") or user.get("user_id")
                        if user_id:
                            return user_id
                except:
                    pass
        except:
            pass
        
        return None
    
    # ==================== PRODUCT SERVICE TESTS ====================
    
    @task(15)
    def product_browse_catalog(self):
        """Use Case 1: Browse product catalog - most common action (public endpoint)"""
        with self.client.get("/app/api/products", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    # Accept any 200 response as success for performance testing
                    response.success()
            elif response.status_code in [404, 503, 502]:
                # Service unavailable - mark as failure but don't fail the test
                response.failure(f"Service unavailable: HTTP {response.status_code}")
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(12)
    def product_search_by_id(self):
        """Use Case 2: Search for specific product by ID (using real product ID)"""
        product_id = self._get_existing_product_id()
        if not product_id:
            # Skip this test if no product ID available
            return
        
        with self.client.get(f"/app/api/products/{product_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(8)
    def product_create_new(self):
        """Use Case 3: Create new product"""
        product_data = {
            "productTitle": f"PerfTest Product {random.randint(10000, 99999)}",
            "sku": f"PERF{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(10.0, 1000.0), 2),
            "quantity": random.randint(1, 100),
            "categoryDto": {
                "categoryId": random.randint(1, 3),
                "categoryTitle": random.choice(["Electronics", "Clothing", "Books"])
            }
        }
        
        with self.client.post("/app/api/products", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    product_id = data.get("productId") or data.get("id") or data.get("product_id")
                    if product_id:
                        self.created_product_ids.append(product_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def product_update_existing(self):
        """Use Case 4: Update existing product (only update products we created)"""
        if not self.created_product_ids:
            # Skip if no products created
            return
        
        product_id = random.choice(self.created_product_ids)
        product_data = {
            "productTitle": f"Updated Product {random.randint(1000, 9999)}",
            "sku": f"UPD{random.randint(1000, 9999)}",
            "priceUnit": round(random.uniform(20.0, 500.0), 2),
            "quantity": random.randint(5, 50)
        }
        
        with self.client.put(f"/app/api/products/{product_id}", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def product_delete_existing(self):
        """Use Case 5: Delete product (only delete products we created)"""
        if not self.created_product_ids:
            # Skip if no products created
            return
        
        product_id = self.created_product_ids.pop(0)  # Remove from list
        with self.client.delete(f"/app/api/products/{product_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                # Put it back if deletion failed
                self.created_product_ids.append(product_id)
                response.failure(f"HTTP {response.status_code}")
    
    # ==================== USER SERVICE TESTS ====================
    
    @task(12)
    def user_browse_users(self):
        """Use Case 1: Browse user list"""
        with self.client.get("/app/api/users", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(10)
    def user_get_by_username(self):
        """Use Case 2: Get user by username (using known usernames)"""
        usernames = ["testuser", "admin", "selimhorri", "amineladjimi", "omarderouiche"]
        username = random.choice(usernames)
        with self.client.get(f"/app/api/users/username/{username}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    user_id = data.get("userId") or data.get("id")
                    if user_id and user_id not in self.created_user_ids:
                        self.created_user_ids.append(user_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(8)
    def user_register_new(self):
        """Use Case 3: Register new user"""
        user_data = {
            "firstName": f"PerfUser{random.randint(10000, 99999)}",
            "lastName": f"LastName{random.randint(10000, 99999)}",
            "email": f"perf{random.randint(10000, 99999)}@example.com",
            "phone": f"+123456{random.randint(10000, 99999)}",
            "credential": {
                "username": f"perfuser{random.randint(10000, 99999)}",
                "password": "Test123!",
                "roleBasedAuthority": "ROLE_USER",
                "isEnabled": True
            }
        }
        
        with self.client.post("/app/api/users", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    user_id = data.get("userId") or data.get("id")
                    if user_id:
                        self.created_user_ids.append(user_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def user_update_profile(self):
        """Use Case 4: Update user profile (only update users we know exist)"""
        user_id = self._get_existing_user_id()
        if not user_id:
            return
        
        user_data = {
            "firstName": f"UpdatedUser{random.randint(1000, 9999)}",
            "lastName": f"UpdatedLastName{random.randint(1000, 9999)}",
            "email": f"updated{random.randint(1000, 9999)}@example.com",
            "phone": f"+123456{random.randint(1000, 9999)}"
        }
        
        with self.client.put(f"/app/api/users/{user_id}", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def user_delete_account(self):
        """Use Case 5: Delete user account (only delete users we created)"""
        if not self.created_user_ids:
            return
        
        user_id = self.created_user_ids.pop(0)
        with self.client.delete(f"/app/api/users/{user_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                self.created_user_ids.append(user_id)
                response.failure(f"HTTP {response.status_code}")
    
    # ==================== ORDER SERVICE TESTS ====================
    
    @task(10)
    def order_browse_orders(self):
        """Use Case 1: Browse orders"""
        with self.client.get("/app/api/orders", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(8)
    def order_create_new(self):
        """Use Case 2: Create new order"""
        user_id = self._get_existing_user_id()
        if not user_id:
            user_id = random.randint(1, 10)  # Fallback
        
        order_data = {
            "orderDesc": f"PerfTest Order {random.randint(10000, 99999)}",
            "orderFee": round(random.uniform(50.0, 500.0), 2),
            "cart": {
                "cartId": random.randint(1, 100),
                "userId": user_id
            }
        }
        
        with self.client.post("/app/api/orders", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    order_id = data.get("orderId") or data.get("id")
                    if order_id:
                        self.created_order_ids.append(order_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def order_get_by_id(self):
        """Use Case 3: Get order by ID (only orders we created or exist)"""
        if self.created_order_ids:
            order_id = random.choice(self.created_order_ids)
        else:
            # Try to get from list
            try:
                response = self.client.get("/app/api/orders", catch_response=True)
                if response.status_code == 200:
                    try:
                        data = response.json()
                        orders = []
                        if isinstance(data, list):
                            orders = data
                        elif isinstance(data, dict) and "collection" in data:
                            orders = data["collection"]
                        
                        if orders and len(orders) > 0:
                            order = random.choice(orders)
                            order_id = order.get("orderId") or order.get("id")
                            if order_id:
                                with self.client.get(f"/app/api/orders/{order_id}", catch_response=True) as resp:
                                    if resp.status_code == 200:
                                        resp.success()
                                    else:
                                        resp.failure(f"HTTP {resp.status_code}")
                                return
                    except:
                        pass
            except:
                pass
            return  # Skip if no orders available
        
        with self.client.get(f"/app/api/orders/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def order_update_status(self):
        """Use Case 4: Update order status (only orders we created)"""
        if not self.created_order_ids:
            return
        
        order_id = random.choice(self.created_order_ids)
        order_data = {
            "orderDesc": f"Updated Order {random.randint(1000, 9999)}",
            "orderFee": round(random.uniform(100.0, 600.0), 2)
        }
        
        with self.client.put(f"/app/api/orders/{order_id}", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(2)
    def order_cancel_order(self):
        """Use Case 5: Cancel order (only orders we created)"""
        if not self.created_order_ids:
            return
        
        order_id = self.created_order_ids.pop(0)
        with self.client.delete(f"/app/api/orders/{order_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                self.created_order_ids.append(order_id)
                response.failure(f"HTTP {response.status_code}")
    
    # ==================== PAYMENT SERVICE TESTS ====================
    
    @task(10)
    def payment_browse_payments(self):
        """Use Case 1: Browse payment history"""
        with self.client.get("/app/api/payments", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(8)
    def payment_process_payment(self):
        """Use Case 2: Process payment"""
        order_id = None
        if self.created_order_ids:
            order_id = random.choice(self.created_order_ids)
        else:
            # Try to get from list
            try:
                response = self.client.get("/app/api/orders", catch_response=True)
                if response.status_code == 200:
                    try:
                        data = response.json()
                        orders = []
                        if isinstance(data, list):
                            orders = data
                        elif isinstance(data, dict) and "collection" in data:
                            orders = data["collection"]
                        
                        if orders and len(orders) > 0:
                            order = random.choice(orders)
                            order_id = order.get("orderId") or order.get("id")
                    except:
                        pass
            except:
                pass
        
        if not order_id:
            order_id = random.randint(1, 10)  # Fallback
        
        payment_data = {
            "isPayed": random.choice([True, False]),
            "paymentStatus": random.choice(["IN_PROGRESS", "COMPLETED", "FAILED"]),
            "order": {
                "orderId": order_id,
                "orderDesc": f"Payment Test Order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(50.0, 500.0), 2)
            }
        }
        
        with self.client.post("/app/api/payments", 
                            json=payment_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    payment_id = data.get("paymentId") or data.get("id")
                    if payment_id:
                        self.created_payment_ids.append(payment_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def payment_get_by_id(self):
        """Use Case 3: Get payment by ID"""
        if self.created_payment_ids:
            payment_id = random.choice(self.created_payment_ids)
            with self.client.get(f"/app/api/payments/{payment_id}", catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def payment_update_status(self):
        """Use Case 4: Update payment status (only payments we created)"""
        if not self.created_payment_ids:
            return
        
        payment_id = random.choice(self.created_payment_ids)
        payment_data = {
            "isPayed": True,
            "paymentStatus": "COMPLETED"
        }
        
        with self.client.put(f"/app/api/payments/{payment_id}", 
                            json=payment_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(2)
    def payment_refund_payment(self):
        """Use Case 5: Refund payment (only payments we created)"""
        if not self.created_payment_ids:
            return
        
        payment_id = self.created_payment_ids.pop(0)
        with self.client.delete(f"/app/api/payments/{payment_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                self.created_payment_ids.append(payment_id)
                response.failure(f"HTTP {response.status_code}")
    
    # ==================== SHIPPING SERVICE TESTS ====================
    
    @task(10)
    def shipping_browse_shippings(self):
        """Use Case 1: Browse shipping records"""
        with self.client.get("/app/api/shippings", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(8)
    def shipping_create_shipment(self):
        """Use Case 2: Create new shipment"""
        order_id = None
        if self.created_order_ids:
            order_id = random.choice(self.created_order_ids)
        else:
            try:
                response = self.client.get("/app/api/orders", catch_response=True)
                if response.status_code == 200:
                    try:
                        data = response.json()
                        orders = []
                        if isinstance(data, list):
                            orders = data
                        elif isinstance(data, dict) and "collection" in data:
                            orders = data["collection"]
                        
                        if orders and len(orders) > 0:
                            order = random.choice(orders)
                            order_id = order.get("orderId") or order.get("id")
                    except:
                        pass
            except:
                pass
        
        if not order_id:
            order_id = random.randint(1, 10)
        
        shipping_data = {
            "shippingAddress": f"{random.randint(100, 999)} PerfTest Street, Test City",
            "shippingStatus": random.choice(["PENDING", "SHIPPED", "DELIVERED"]),
            "order": {
                "orderId": order_id,
                "orderDesc": f"Shipping Test Order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(50.0, 500.0), 2)
            }
        }
        
        with self.client.post("/app/api/shippings", 
                            json=shipping_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    shipping_id = data.get("shippingId") or data.get("id")
                    if shipping_id:
                        self.created_shipping_ids.append(shipping_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def shipping_track_shipment(self):
        """Use Case 3: Track shipment"""
        if self.created_shipping_ids:
            shipping_id = random.choice(self.created_shipping_ids)
            with self.client.get(f"/app/api/shippings/{shipping_id}", catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def shipping_update_status(self):
        """Use Case 4: Update shipping status (only shipments we created)"""
        if not self.created_shipping_ids:
            return
        
        shipping_id = random.choice(self.created_shipping_ids)
        shipping_data = {
            "shippingStatus": random.choice(["SHIPPED", "IN_TRANSIT", "DELIVERED"]),
            "shippingAddress": f"{random.randint(100, 999)} Updated Street, Test City"
        }
        
        with self.client.put(f"/app/api/shippings/{shipping_id}", 
                            json=shipping_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(2)
    def shipping_cancel_shipment(self):
        """Use Case 5: Cancel shipment (only shipments we created)"""
        if not self.created_shipping_ids:
            return
        
        shipping_id = self.created_shipping_ids.pop(0)
        with self.client.delete(f"/app/api/shippings/{shipping_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                self.created_shipping_ids.append(shipping_id)
                response.failure(f"HTTP {response.status_code}")
    
    # ==================== FAVOURITE SERVICE TESTS ====================
    
    @task(8)
    def favourite_browse_favourites(self):
        """Use Case 1: Browse user favourites"""
        with self.client.get("/app/api/favourites", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(6)
    def favourite_add_to_favourites(self):
        """Use Case 2: Add product to favourites"""
        user_id = self._get_existing_user_id()
        if not user_id:
            user_id = random.randint(1, 10)
        
        product_id = self._get_existing_product_id()
        if not product_id:
            return
        
        favourite_data = {
            "userId": user_id,
            "productId": product_id,
            "user": {
                "userId": user_id,
                "firstName": f"User{random.randint(1000, 9999)}",
                "lastName": f"LastName{random.randint(1000, 9999)}",
                "email": f"user{random.randint(1000, 9999)}@example.com"
            },
            "product": {
                "productId": product_id,
                "productTitle": f"Favourite Product {random.randint(1000, 9999)}",
                "sku": f"FAV{random.randint(1000, 9999)}",
                "priceUnit": round(random.uniform(10.0, 1000.0), 2),
                "quantity": random.randint(1, 100)
            }
        }
        
        with self.client.post("/app/api/favourites", 
                            json=favourite_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    favourite_id = data.get("id") or f"{user_id}_{product_id}"
                    if favourite_id:
                        self.created_favourite_ids.append(favourite_id)
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(4)
    def favourite_get_user_favourites(self):
        """Use Case 3: Get user's favourites"""
        user_id = self._get_existing_user_id()
        if not user_id:
            return
        
        with self.client.get(f"/app/api/favourites/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(3)
    def favourite_update_favourite(self):
        """Use Case 4: Update favourite"""
        if not self.created_favourite_ids:
            return
        
        favourite_id = random.choice(self.created_favourite_ids)
        user_id = self._get_existing_user_id() or random.randint(1, 10)
        product_id = self._get_existing_product_id()
        if not product_id:
            return
        
        favourite_data = {
            "userId": user_id,
            "productId": product_id
        }
        
        with self.client.put(f"/app/api/favourites/{favourite_id}", 
                            json=favourite_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")
    
    @task(2)
    def favourite_remove_from_favourites(self):
        """Use Case 5: Remove from favourites (only favourites we created)"""
        if not self.created_favourite_ids:
            return
        
        favourite_id = self.created_favourite_ids.pop(0)
        with self.client.delete(f"/app/api/favourites/{favourite_id}", catch_response=True) as response:
            if response.status_code in [200, 204]:
                response.success()
            else:
                self.created_favourite_ids.append(favourite_id)
                response.failure(f"HTTP {response.status_code}")


class HighLoadUser(HttpUser):
    """High load user for stress testing - only uses public GET endpoints"""
    wait_time = between(0.1, 0.5)
    weight = 1
    
    @task(20)
    def rapid_product_catalog(self):
        """Stress test: Rapid product catalog queries"""
        self.client.get("/app/api/products")
    
    @task(15)
    def rapid_user_queries(self):
        """Stress test: Rapid user queries by username"""
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


class EcommerceWorkflowUser(HttpUser):
    """User that performs complete e-commerce workflows"""
    wait_time = between(2, 5)
    weight = 2
    
    def on_start(self):
        """Initialize workflow user"""
        self.workflow_data = {
            "product_id": None,
            "order_id": None,
            "payment_id": None,
            "shipping_id": None
        }
        # Create a product first
        self._create_test_product()
    
    def _create_test_product(self):
        """Create a test product for workflow"""
        product_data = {
            "productTitle": f"Workflow Product {random.randint(10000, 99999)}",
            "sku": f"WF{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(50.0, 300.0), 2),
            "quantity": random.randint(10, 50),
            "categoryDto": {
                "categoryId": 1,
                "categoryTitle": "Electronics"
            }
        }
        
        try:
            response = self.client.post("/app/api/products", 
                                      json=product_data, 
                                      headers={"Content-Type": "application/json"},
                                      catch_response=True)
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    self.workflow_data["product_id"] = data.get("productId") or data.get("id")
                except:
                    pass
        except:
            pass
    
    @task(3)
    def complete_purchase_workflow(self):
        """Complete purchase workflow: Browse -> Order -> Payment -> Shipping"""
        
        # 1. Browse products
        self.client.get("/app/api/products")
        
        # 2. Get specific product (if we created one)
        if self.workflow_data["product_id"]:
            self.client.get(f"/app/api/products/{self.workflow_data['product_id']}")
        
        # 3. Create order
        order_data = {
            "orderDesc": f"Workflow Order {random.randint(10000, 99999)}",
            "orderFee": round(random.uniform(100.0, 500.0), 2),
            "cart": {
                "cartId": random.randint(1, 100),
                "userId": random.randint(1, 10)
            }
        }
        
        with self.client.post("/app/api/orders", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    self.workflow_data["order_id"] = data.get("orderId") or data.get("id")
                except:
                    pass
        
        # 4. Create payment (if order was created)
        if self.workflow_data["order_id"]:
            payment_data = {
                "isPayed": True,
                "paymentStatus": "COMPLETED",
                "order": {
                    "orderId": self.workflow_data["order_id"],
                    "orderDesc": order_data["orderDesc"],
                    "orderFee": order_data["orderFee"]
                }
            }
            
            with self.client.post("/app/api/payments", 
                                json=payment_data, 
                                headers={"Content-Type": "application/json"},
                                catch_response=True) as response:
                if response.status_code in [200, 201]:
                    try:
                        data = response.json()
                        self.workflow_data["payment_id"] = data.get("paymentId") or data.get("id")
                    except:
                        pass
        
        # 5. Create shipping (if order was created)
        if self.workflow_data["order_id"]:
            shipping_data = {
                "shippingAddress": f"{random.randint(100, 999)} Workflow Street, Test City",
                "shippingStatus": "SHIPPED",
                "order": {
                    "orderId": self.workflow_data["order_id"],
                    "orderDesc": order_data["orderDesc"],
                    "orderFee": order_data["orderFee"]
                }
            }
            
            self.client.post("/app/api/shippings", 
                           json=shipping_data, 
                           headers={"Content-Type": "application/json"})
    
    @task(2)
    def user_management_workflow(self):
        """User management workflow: Register -> Get by username"""
        
        # 1. Create user
        user_data = {
            "firstName": f"WorkflowUser{random.randint(10000, 99999)}",
            "lastName": f"LastName{random.randint(10000, 99999)}",
            "email": f"workflow{random.randint(10000, 99999)}@example.com",
            "phone": f"+123456{random.randint(10000, 99999)}",
            "credential": {
                "username": f"workflowuser{random.randint(10000, 99999)}",
                "password": "Test123!",
                "roleBasedAuthority": "ROLE_USER",
                "isEnabled": True
            }
        }
        
        with self.client.post("/app/api/users", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                # 2. Get user by username
                self.client.get(f"/app/api/users/username/{user_data['credential']['username']}")
    
    @task(1)
    def product_management_workflow(self):
        """Product management workflow: Create -> Get -> Update"""
        
        # 1. Create product
        product_data = {
            "productTitle": f"Workflow Product {random.randint(10000, 99999)}",
            "sku": f"WF{random.randint(10000, 99999)}",
            "priceUnit": round(random.uniform(50.0, 300.0), 2),
            "quantity": random.randint(10, 50),
            "categoryDto": {
                "categoryId": 1,
                "categoryTitle": "Electronics"
            }
        }
        
        with self.client.post("/app/api/products", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code in [200, 201]:
                try:
                    data = response.json()
                    product_id = data.get("productId") or data.get("id")
                    
                    if product_id:
                        # 2. Get product
                        self.client.get(f"/app/api/products/{product_id}")
                        
                        # 3. Update product
                        product_data["productTitle"] = f"Updated {product_data['productTitle']}"
                        product_data["priceUnit"] = round(product_data["priceUnit"] * 1.1, 2)
                        
                        self.client.put(f"/app/api/products/{product_id}", 
                                      json=product_data, 
                                      headers={"Content-Type": "application/json"})
                except:
                    pass
