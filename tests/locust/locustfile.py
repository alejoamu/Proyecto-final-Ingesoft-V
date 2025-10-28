from locust import HttpUser, task, between
import os

BASE_HOST = os.getenv("BASE_HOST", "http://localhost")

class EcommerceUser(HttpUser):
    wait_time = between(0.25, 0.75)

    @task(3)
    def products_list(self):
        # product-service exposed locally via port-forward 8500
        self.client.get("http://localhost:8500/product-service/api/products", name="GET /products")

    @task(3)
    def users_list(self):
        # user-service exposed locally via port-forward 8700
        self.client.get("http://localhost:8700/user-service/api/users", name="GET /users")

    # Optional smoke hits to other services if they are up; don't dominate load
    @task(1)
    def shipping_list(self):
        try:
            self.client.get("http://localhost:8600/shipping-service/api/shippings", name="GET /shippings", timeout=5)
        except Exception:
            pass

    @task(1)
    def payments_list(self):
        try:
            self.client.get("http://localhost:8400/payment-service/api/payments", name="GET /payments", timeout=5)
        except Exception:
            pass

    @task(1)
    def orders_list(self):
        try:
            self.client.get("http://localhost:8300/order-service/api/orders", name="GET /orders", timeout=5)
        except Exception:
            pass

    @task(1)
    def favourites_list(self):
        try:
            self.client.get("http://localhost:8800/favourite-service/api/favourites", name="GET /favourites", timeout=5)
        except Exception:
            pass

