from locust import HttpUser, task, between
import os

BASE_HOST = os.getenv("BASE_HOST", "http://localhost")

# Endpoints configurables por entorno; por defecto usamos NodePort
PRODUCT_URL = os.getenv("PRODUCT_URL", "http://localhost:30500/api/products")
USER_URL = os.getenv("USER_URL", "http://localhost:30700/api/users")
SHIPPING_URL = os.getenv("SHIPPING_URL", "http://localhost:30600/api/shippings")
PAYMENT_URL = os.getenv("PAYMENT_URL", "http://localhost:30400/api/payments")
ORDER_URL = os.getenv("ORDER_URL", "http://localhost:30300/api/orders")
FAVOURITE_URL = os.getenv("FAVOURITE_URL", "http://localhost:30800/api/favourites")

class EcommerceUser(HttpUser):
    # Locust exige un host base aunque usemos URLs absolutas; esto lo satisface
    host = BASE_HOST
    wait_time = between(0.25, 0.75)

    @task(3)
    def products_list(self):
        self.client.get(PRODUCT_URL, name="GET /products")

    @task(3)
    def users_list(self):
        self.client.get(USER_URL, name="GET /users")

    # Optional smoke hits to other services if they are up; don't dominate load
    @task(1)
    def shipping_list(self):
        try:
            self.client.get(SHIPPING_URL, name="GET /shippings", timeout=5)
        except Exception:
            pass

    @task(1)
    def payments_list(self):
        try:
            self.client.get(PAYMENT_URL, name="GET /payments", timeout=5)
        except Exception:
            pass

    @task(1)
    def orders_list(self):
        try:
            self.client.get(ORDER_URL, name="GET /orders", timeout=5)
        except Exception:
            pass

    @task(1)
    def favourites_list(self):
        try:
            self.client.get(FAVOURITE_URL, name="GET /favourites", timeout=5)
        except Exception:
            pass
