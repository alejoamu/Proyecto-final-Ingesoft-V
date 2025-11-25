# Métricas de Negocio - Implementación

## ¿Qué son las Métricas de Negocio?

Las **métricas de negocio** miden aspectos relacionados con el dominio del negocio y el valor que genera la aplicación, a diferencia de las métricas técnicas que miden aspectos operacionales (CPU, memoria, latencia, etc.).

### Ejemplos de Métricas de Negocio vs Técnicas

**Métricas Técnicas** (ya implementadas):
- Request rate (req/s)
- Latencia (ms)
- Error rate (%)
- CPU, memoria, threads
- Circuit breaker status

**Métricas de Negocio** (a implementar):
- Órdenes creadas por día
- Valor total de órdenes
- Pagos exitosos vs fallidos
- Usuarios registrados
- Productos vendidos
- Conversión de carrito a orden
- Ingresos totales

## Cómo Implementar Métricas de Negocio

### 1. Usar Micrometer (ya configurado)

Micrometer ya está configurado en el proyecto. Solo necesitas inyectar `MeterRegistry` y crear tus métricas personalizadas.

### 2. Tipos de Métricas Disponibles

**Counter**: Para contar eventos (órdenes creadas, pagos procesados)
```java
private final Counter ordersCreatedCounter;

ordersCreatedCounter = MeterRegistry.counter("business.orders.created", "status", "success");
ordersCreatedCounter.increment();
```

**Gauge**: Para valores que suben y bajan (número actual de usuarios, productos en catálogo)
```java
MeterRegistry.gauge("business.users.active", users.size());
```

**Timer**: Para medir duración de operaciones (tiempo de procesamiento de pago)
```java
Timer.Sample sample = Timer.start(meterRegistry);
// ... operación ...
sample.stop(Timer.builder("business.payment.processing.time").register(meterRegistry));
```

**Summary**: Para distribuciones de valores (monto promedio de órdenes)
```java
DistributionSummary orderValueSummary = DistributionSummary.builder("business.orders.value")
    .description("Valor de las órdenes")
    .baseUnit("currency")
    .register(meterRegistry);

orderValueSummary.record(orderFee);
```

## Implementación por Servicio

### Order Service

**Métricas a implementar:**
- `business.orders.created` - Órdenes creadas (counter)
- `business.orders.value.total` - Valor total de órdenes (summary)
- `business.orders.value.average` - Valor promedio de órdenes (summary)
- `business.orders.deleted` - Órdenes eliminadas (counter)

### Payment Service

**Métricas a implementar:**
- `business.payments.created` - Pagos creados (counter)
- `business.payments.successful` - Pagos exitosos (counter)
- `business.payments.failed` - Pagos fallidos (counter)
- `business.payments.amount.total` - Monto total pagado (summary)
- `business.payments.by.status` - Pagos por estado (counter con tags)

### User Service

**Métricas a implementar:**
- `business.users.registered` - Usuarios registrados (counter)
- `business.users.active` - Usuarios activos (gauge)
- `business.users.logins` - Logins exitosos (counter)

### Product Service

**Métricas a implementar:**
- `business.products.created` - Productos creados (counter)
- `business.products.updated` - Productos actualizados (counter)
- `business.products.deleted` - Productos eliminados (counter)
- `business.products.total` - Total de productos en catálogo (gauge)

## Próximos Pasos

Ver archivos de ejemplo de implementación en:
- `order-service/src/main/java/com/selimhorri/app/metrics/BusinessMetricsService.java`
- `payment-service/src/main/java/com/selimhorri/app/metrics/BusinessMetricsService.java`

