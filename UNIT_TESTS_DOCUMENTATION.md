#  Documentación de Tests Unitarios - Microservicios E-commerce

Este documento explica qué está probando cada test unitario en cada microservicio del sistema e-commerce.

---

##  Product Service (`product-service`)

### Tests Unitarios (`ProductServiceTest.java`)

1. **`testProductCreation_ShouldWork`**
   - **Propósito**: Verifica que se pueden crear productos con datos válidos
   - **Qué prueba**: Validación de creación de producto con nombre, precio y cantidad
   - **Assertions**: Verifica que el nombre no sea null, precio > 0, cantidad > 0

2. **`testProductValidation_ShouldWork`**
   - **Propósito**: Valida que el sistema puede distinguir entre SKUs válidos e inválidos
   - **Qué prueba**: Validación de formato de SKU (código de producto)
   - **Assertions**: SKU válido tiene longitud > 0, SKU inválido está vacío

3. **`testProductPricing_ShouldWork`**
   - **Propósito**: Verifica el cálculo de precios con descuentos
   - **Qué prueba**: Cálculo de precio final después de aplicar descuento
   - **Assertions**: Precio final = precio base * (1 - descuento), descuento entre 0 y 1

4. **`testProductInventory_ShouldWork`**
   - **Propósito**: Valida el manejo de inventario de productos
   - **Qué prueba**: Cálculo de stock restante después de ventas
   - **Assertions**: Stock restante = stock inicial - items vendidos, stock restante > 0

5. **`testProductCategories_ShouldWork`**
   - **Propósito**: Verifica el manejo de categorías de productos
   - **Qué prueba**: Asignación y validación de categorías
   - **Assertions**: Array de categorías no es null, contiene categorías válidas

---

## User Service (`user-service`)

### Tests Unitarios (`UserServiceTest.java`)

1. **`testUserCreation_ShouldWork`**
   - **Propósito**: Verifica creación de usuarios con datos válidos
   - **Qué prueba**: Validación de creación de usuario con username y email
   - **Assertions**: Username no es null, email contiene "@"

2. **`testUserValidation_ShouldWork`**
   - **Propósito**: Valida que el sistema puede distinguir usuarios válidos de inválidos
   - **Qué prueba**: Validación de formato de username
   - **Assertions**: Username válido tiene longitud > 0, inválido está vacío

3. **`testUserAuthentication_ShouldWork`**
   - **Propósito**: Verifica el proceso de hash de contraseñas
   - **Qué prueba**: Hash de contraseñas para almacenamiento seguro
   - **Assertions**: Contraseña hasheada no es igual a la original, contiene prefijo "hashed_"

4. **`testUserProfile_ShouldWork`**
   - **Propósito**: Valida la construcción de nombres completos
   - **Qué prueba**: Concatenación de nombre y apellido
   - **Assertions**: Nombre completo contiene nombre y apellido

5. **`testUserPermissions_ShouldWork`**
   - **Propósito**: Verifica el manejo de permisos y roles de usuario
   - **Qué prueba**: Asignación de permisos (READ, WRITE, DELETE) y roles
   - **Assertions**: Array de permisos no es null, contiene permisos válidos

---

## Payment Service (`payment-service`)

### Tests Unitarios (`PaymentServiceTest.java`)

1. **`testPaymentCreation_ShouldWork`**
   - **Propósito**: Verifica creación de pagos con datos válidos
   - **Qué prueba**: Validación de creación de pago con ID, monto y moneda
   - **Assertions**: ID no es null, monto > 0, moneda es "USD"

2. **`testPaymentValidation_ShouldWork`**
   - **Propósito**: Valida formato de números de tarjeta de crédito
   - **Qué prueba**: Validación de longitud de número de tarjeta
   - **Assertions**: Tarjeta válida tiene >= 16 dígitos, inválida < 16

3. **`testPaymentProcessing_ShouldWork`**
   - **Propósito**: Verifica cambio de estados de pago
   - **Qué prueba**: Transición de estado PENDING a SUCCESS
   - **Assertions**: Estados no son null, son diferentes entre sí

4. **`testPaymentRefund_ShouldWork`**
   - **Propósito**: Valida cálculo de reembolsos
   - **Qué prueba**: Cálculo de monto restante después de reembolso parcial
   - **Assertions**: Monto restante = monto original - reembolso, reembolso <= monto original

5. **`testPaymentHistory_ShouldWork`**
   - **Propósito**: Verifica manejo de historial de pagos
   - **Qué prueba**: Almacenamiento y recuperación de pagos previos
   - **Assertions**: Array de historial no es null, contiene múltiples pagos

---

## Order Service (`order-service`)

### Tests Unitarios (`OrderServiceTest.java`)

1. **`testOrderCreation_ShouldWork`**
   - **Propósito**: Verifica creación de órdenes con datos válidos
   - **Qué prueba**: Validación de creación de orden con ID, customer ID y monto total
   - **Assertions**: IDs no son null, monto total > 0

2. **`testOrderStatus_ShouldWork`**
   - **Propósito**: Valida manejo de estados de orden
   - **Qué prueba**: Estados válidos: PENDING, CONFIRMED, SHIPPED, DELIVERED, CANCELLED
   - **Assertions**: Array de estados no es null, contiene 5 estados válidos

3. **`testOrderItems_ShouldWork`**
   - **Propósito**: Verifica cálculo de totales de órdenes
   - **Qué prueba**: Cálculo de precio total basado en cantidad de items y precio unitario
   - **Assertions**: Precio total = cantidad items * precio unitario, total > 0

4. **`testOrderValidation_ShouldWork`**
   - **Propósito**: Valida formato de IDs de orden
   - **Qué prueba**: Validación de ID de orden válido vs inválido
   - **Assertions**: ID válido tiene longitud > 0, inválido está vacío

5. **`testOrderCalculation_ShouldWork`**
   - **Propósito**: Verifica cálculo de totales con impuestos y envío
   - **Qué prueba**: Cálculo de total = subtotal + tax + shipping
   - **Assertions**: Total > subtotal, tax > 0, shipping > 0

---

## Shipping Service (`shipping-service`)

### Tests Unitarios (`ShippingServiceTest.java`)

1. **`testShippingCreation_ShouldWork`**
   - **Propósito**: Verifica creación de envíos con datos válidos
   - **Qué prueba**: Validación de creación de envío con ID, order ID y carrier
   - **Assertions**: IDs no son null, carrier es "FEDEX"

2. **`testShippingStatus_ShouldWork`**
   - **Propósito**: Valida manejo de estados de envío
   - **Qué prueba**: Estados válidos: PENDING, PICKED_UP, IN_TRANSIT, OUT_FOR_DELIVERY, DELIVERED
   - **Assertions**: Array de estados no es null, contiene 5 estados válidos

3. **`testShippingCalculation_ShouldWork`**
   - **Propósito**: Verifica cálculo de costos de envío
   - **Qué prueba**: Cálculo basado en peso, distancia y tarifa base
   - **Assertions**: Costo total = baseRate + (peso * 2.0) + (distancia * 0.1), costo > tarifa base

4. **`testShippingValidation_ShouldWork`**
   - **Propósito**: Valida formato de direcciones de envío
   - **Qué prueba**: Validación de dirección válida vs inválida
   - **Assertions**: Dirección válida tiene longitud > 10, inválida está vacía

5. **`testShippingTracking_ShouldWork`**
   - **Propósito**: Verifica manejo de números de seguimiento
   - **Qué prueba**: Validación de número de tracking y eventos de seguimiento
   - **Assertions**: Número de tracking tiene longitud > 10, array de eventos no es null

---

## Favourite Service (`favourite-service`)

### Tests Unitarios (`FavouriteServiceTest.java`)

1. **`testFavouriteCreation_ShouldWork`**
   - **Propósito**: Verifica creación de favoritos con datos válidos
   - **Qué prueba**: Validación de creación de favorito con ID, user ID y product ID
   - **Assertions**: IDs no son null

2. **`testFavouriteValidation_ShouldWork`**
   - **Propósito**: Valida formato de IDs de usuario y producto
   - **Qué prueba**: Validación de user ID y product ID válidos vs inválidos
   - **Assertions**: IDs válidos tienen longitud > 0, inválidos están vacíos

3. **`testFavouriteList_ShouldWork`**
   - **Propósito**: Verifica manejo de listas de favoritos
   - **Qué prueba**: Almacenamiento y recuperación de múltiples productos favoritos
   - **Assertions**: Array de favoritos no es null, contiene múltiples productos

4. **`testFavouriteRemoval_ShouldWork`**
   - **Propósito**: Valida eliminación de favoritos
   - **Qué prueba**: Reducción de lista después de eliminar un favorito
   - **Assertions**: Lista actualizada tiene menos elementos que la inicial

5. **`testFavouriteSearch_ShouldWork`**
   - **Propósito**: Verifica búsqueda de favoritos
   - **Qué prueba**: Búsqueda de productos favoritos por término
   - **Assertions**: Resultados no están vacíos, contienen término de búsqueda

---

## API Gateway (`api-gateway`)

### Tests Unitarios (`ApiGatewayTest.java`)

1. **`testRouteConfiguration_ShouldWork`**
   - **Propósito**: Verifica configuración de rutas del gateway
   - **Qué prueba**: Validación de rutas configuradas para diferentes servicios
   - **Assertions**: Array de rutas no es null, contiene rutas válidas

2. **`testRequestValidation_ShouldWork`**
   - **Propósito**: Valida validación de requests entrantes
   - **Qué prueba**: Distinción entre requests válidos e inválidos
   - **Assertions**: Request válido contiene método HTTP y ruta "/api/", inválido está vacío

3. **`testLoadBalancing_ShouldWork`**
   - **Propósito**: Verifica balanceamiento de carga
   - **Qué prueba**: Selección de instancias de servicio para balanceamiento
   - **Assertions**: Array de instancias no es null, contiene múltiples instancias

4. **`testAuthentication_ShouldWork`**
   - **Propósito**: Valida autenticación mediante tokens
   - **Qué prueba**: Validación de tokens Bearer válidos vs inválidos
   - **Assertions**: Token válido comienza con "Bearer ", inválido no

5. **`testRateLimiting_ShouldWork`**
   - **Propósito**: Verifica limitación de velocidad de requests
   - **Qué prueba**: Cálculo de requests restantes dentro del límite
   - **Assertions**: Requests restantes = maxRequests - currentRequests, currentRequests < maxRequests

---

## Cloud Config Service (`cloud-config`)

### Tests Unitarios (`CloudConfigTest.java`)

1. **`testConfigRetrieval_ShouldWork`**
   - **Propósito**: Verifica recuperación de configuraciones
   - **Qué prueba**: Obtención de valores de configuración por clave y perfil
   - **Assertions**: Clave, valor y perfil no son null, valor contiene "jdbc:mysql"

2. **`testConfigValidation_ShouldWork`**
   - **Propósito**: Valida formato de configuraciones
   - **Qué prueba**: Distinción entre configuraciones válidas e inválidas
   - **Assertions**: Config válida contiene claves esperadas, inválida está vacía

3. **`testConfigProfiles_ShouldWork`**
   - **Propósito**: Verifica manejo de perfiles de configuración
   - **Qué prueba**: Perfiles disponibles: dev, test, prod, stage
   - **Assertions**: Array de perfiles no es null, contiene 4 perfiles

4. **`testConfigEncryption_ShouldWork`**
   - **Propósito**: Valida encriptación de configuraciones sensibles
   - **Qué prueba**: Encriptación de datos sensibles
   - **Assertions**: Texto encriptado no es igual al texto plano, tiene prefijo "encrypted_"

5. **`testConfigRefresh_ShouldWork`**
   - **Propósito**: Verifica actualización de configuraciones
   - **Qué prueba**: Cambio de versión de configuración
   - **Assertions**: Nueva configuración es diferente de la anterior, contiene nueva versión

---

## Service Discovery (`service-discovery`)

### Tests Unitarios (`ServiceDiscoveryTest.java`)

1. **`testServiceRegistration_ShouldWork`**
   - **Propósito**: Verifica registro de servicios en el discovery
   - **Qué prueba**: Registro de servicio con ID, URL y estado
   - **Assertions**: ID, URL y estado no son null, URL contiene "http", estado es "UP"

2. **`testServiceDiscovery_ShouldWork`**
   - **Propósito**: Valida descubrimiento de servicios registrados
   - **Qué prueba**: Búsqueda de servicio específico en lista de servicios registrados
   - **Assertions**: Array de servicios no es null, contiene servicio buscado

3. **`testServiceHealthCheck_ShouldWork`**
   - **Propósito**: Verifica verificación de salud de servicios
   - **Qué prueba**: Estados HEALTHY vs UNHEALTHY
   - **Assertions**: Estados no son null, son diferentes entre sí

4. **`testServiceLoadBalancing_ShouldWork`**
   - **Propósito**: Valida balanceamiento de carga entre instancias
   - **Qué prueba**: Selección de instancia de servicio para balanceamiento
   - **Assertions**: Array de instancias no es null, contiene múltiples instancias

5. **`testServiceDeregistration_ShouldWork`**
   - **Propósito**: Verifica desregistro de servicios
   - **Qué prueba**: Eliminación de servicio de la lista de servicios registrados
   - **Assertions**: Lista actualizada tiene menos elementos que la inicial

---

## Proxy Client (`proxy-client`)

### Tests Unitarios (`SimpleTest.java`)

1. **`testBasicMath`**
   - **Propósito**: Test básico de matemáticas
   - **Qué prueba**: Operaciones matemáticas simples
   - **Assertions**: 2 + 2 = 4, 5 > 3, 1 no es > 2

2. **`testStringOperations`**
   - **Propósito**: Test básico de strings
   - **Qué prueba**: Concatenación de strings
   - **Assertions**: "Hello" + " " + "World" = "Hello World"

3. **`testArrayOperations`**
   - **Propósito**: Test básico de arrays
   - **Qué prueba**: Operaciones con arrays
   - **Assertions**: Array tiene longitud 5, primer elemento es 1, último es 5

4. **`testBooleanLogic`**
   - **Propósito**: Test básico de lógica booleana
   - **Qué prueba**: Operaciones booleanas
   - **Assertions**: true OR false = true, true AND false = false

5. **`testNullChecks`**
   - **Propósito**: Test básico de verificaciones null
   - **Qué prueba**: Distinción entre valores null y no null
   - **Assertions**: String null es null, string no null no es null

---

## Resumen General

### Características Comunes de los Tests Unitarios

- **Cobertura**: Todos los tests verifican lógica de negocio básica
- **Estilo**: Tests simples que validan operaciones básicas sin dependencias externas
- **Limitaciones**: 
  - No hacen llamadas HTTP reales
  - No interactúan con bases de datos
  - No prueban integración entre servicios
  - Validan principalmente lógica de validación y cálculos básicos

### Recomendaciones para Mejora

1. **Tests más robustos**: Agregar mocks para dependencias
2. **Cobertura de casos edge**: Probar casos límite y errores
3. **Tests de integración**: Crear tests que prueben comunicación entre servicios
4. **Tests E2E**: Implementar tests end-to-end que prueben flujos completos

---

**Última actualización**: 2025-01-XX



