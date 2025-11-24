# e-Commerce-boot μServices 

## Important Note: This project's new milestone is to move The whole system to work on Kubernetes, so stay tuned.

<!--## Better Code Hub
I analysed this repository according to the clean code standards on [Better Code Hub](https://bettercodehub.com/) just to get an independent opinion of how bad the code is. Surprisingly, the compliance score is high!
-->
## Introduction
- This project is a development of a small set of **Spring Boot** and **Cloud** based Microservices projects that implement cloud-native intuitive, Reactive Programming, Event-driven, Microservices design patterns, and coding best practices.
- The project follows **CloudNative**<!--(https://www.cncf.io/)--> recommendations and The [**twelve-factor app**](https://12factor.net/) methodology for building *software-as-a-service apps* to show how μServices should be developed and deployed.
- This project uses cutting edge technologies like Docker, Kubernetes, Elasticsearch Stack for
 logging and monitoring, Java SE 11, H2, and MySQL databases, all components developed with TDD in mind, covering integration & performance testing, and many more.
 - This project is going to be developed as stages, and all such stage steps are documented under
  the project **e-Commerce-boot μServices** **README** file <!--[wiki page](https://github.com/mohamed-taman/Springy-Store-Microservices/wiki)-->.
---
## Getting started
### System components Structure
Let's explain first the system structure to understand its components:
```
ecommerce-microservice-backend-app [μService] --> Parent folder.
|- docs --> All docs and diagrams.
|- k8s --> All **Kubernetes** config files.
    |- proxy-client --> Authentication & Authorization µService, exposing all 
    |- api-gateway --> API Gateway server
    |- service-discovery --> Service Registery server
    |- cloud-config --> Centralized Configuration server
    |- user-service --> Manage app users (customers & admins) as well as their credentials
    |- product-service --> Manage app products and their respective categories
    |- favourite-service --> Manage app users' favourite products added to their own favourite list
    |- order-service --> Manage app orders based on carts
    |- shipping-service --> Manage app order-shipping products
    |- payment-service --> Manage app order payments
|- compose.yml --> contains all services landscape with Kafka  
|- run-em-all.sh --> Run all microservices in separate mode. 
|- setup.sh --> Install all shared POMs and shared libraries. 
|- stop-em-all.sh --> Stop all services runs in standalone mode. 
|- test-em-all.sh --> This will start all docker compose landscape and test them, then shutdown docker compose containers with test finishes (use switch start stop)
```
Now, as we have learned about different system components, then let's start.

### System Boundary *Architecture* - μServices Landscape

![System Boundary](app-architecture.drawio.png)

### Required software

The following are the initially required software pieces:

1. **Java 11**: JDK 11 LTS can be downloaded and installed from https://www.oracle.com/java/technologies/javase/jdk11-archive-downloads.html

1. **Git**: it can be downloaded and installed from https://git-scm.com/downloads

1. **Maven**: Apache Maven is a software project management and comprehension tool, it can be downloaded from here https://maven.apache.org/download.cgi

1. **curl**: this command-line tool for testing HTTP-based APIs can be downloaded and installed from https://curl.haxx.se/download.html

1. **jq**: This command-line JSON processor can be downloaded and installed from https://stedolan.github.io/jq/download/

1. **Spring Boot Initializer**: This *Initializer* generates *spring* boot project with just what you need to start quickly! Start from here https://start.spring.io/

1. **Docker**: The fastest way to containerize applications on your desktop, and you can download it from here [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)

1. **Kubernetes**: We can install **minikube** for testing puposes https://minikube.sigs.k8s.io/docs/start/

   > For each future stage, I will list the newly required software. 

Follow the installation guide for each software website link and check your software versions from the command line to verify that they are all installed correctly.

## Using an IDE

I recommend that you work with your Java code using an IDE that supports the development of Spring Boot applications such as Spring Tool Suite or IntelliJ IDEA Ultimate Edition. So you can use the Spring Boot Dashboard to run the services, run each microservice test case, and many more.

All that you want to do is just fire up your IDE **->** open or import the parent folder `ecommerce-microservice-backend-app`, and everything will be ready for you.

## Data Model
### Entity-Relationship-Diagram
![System Boundary](ecommerce-ERD.drawio.png)

## Playing With e-Commerce-boot Project

### Cloning It

The first thing to do is to open **git bash** command line, and then simply you can clone the project under any of your favorite places as the following:

```bash
> git clone https://github.com/SelimHorri/ecommerce-microservice-backend-app.git
```

### Build & Test Them In Isolation

To build and run the test cases for each service & shared modules in the project, we need to do the following:

#### Build & Test µServices
Now it is the time to build our **10 microservices** and run each service integration test in
 isolation by running the following commands:

```bash
selim@:~/ecommerce-microservice-backend-app$ ./mvnw clean package 
```

All build commands and test suite for each microservice should run successfully, and the final output should be like this:

```bash
---------------< com.selimhorri.app:ecommerce-microservice-backend >-----------
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for ecommerce-microservice-backend 0.1.0:
[INFO] 
[INFO] ecommerce-microservice-backend ..................... SUCCESS [  0.548 s]
[INFO] service-discovery .................................. SUCCESS [  3.126 s]
[INFO] cloud-config ....................................... SUCCESS [  1.595 s]
[INFO] api-gateway ........................................ SUCCESS [  1.697 s]
[INFO] proxy-client ....................................... SUCCESS [  3.632 s]
[INFO] user-service ....................................... SUCCESS [  2.546 s]
[INFO] product-service .................................... SUCCESS [  2.214 s]
[INFO] favourite-service .................................. SUCCESS [  2.072 s]
[INFO] order-service ...................................... SUCCESS [  2.241 s]
[INFO] shipping-service ................................... SUCCESS [  2.197 s]
[INFO] payment-service .................................... SUCCESS [  2.006 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  24.156 s
[INFO] Finished at: 2021-12-29T19:52:57+01:00
[INFO] ------------------------------------------------------------------------
```

### Running Them All

We now run the landscape in two steps to ensure all services resolve Zipkin, Eureka and Config Server by name inside a shared network:

1) Start core services (Zipkin, Eureka and Config Server):

```bash
# from the project root
docker-compose -f core.yml up -d
```

2) Wait until Eureka and Config Server are READY. Check logs:

```bash
docker logs -f <service-discovery-container-id>
docker logs -f <cloud-config-container-id>
```

You should see messages similar to:
- Eureka: "Finished initializing remote region registries."
- API Gateway (later): 200 OK responses to http://service-discovery-container:8761/eureka/...

3) Start the remaining microservices on the same network:

```bash
docker-compose -f compose.yml up -d
```

Windows helper scripts (optional):
- Double-click or run `run-all.cmd` to: bring up core, wait for readiness, then start the rest.
- Double-click or run `stop-all.cmd` to: stop app services, then stop core.

Example endpoints to verify:
- http://localhost:8080/app/api/products
- http://localhost:8600/shipping-service/api/shippings
- http://localhost:8700/user-service/api/users
- http://localhost:8500/product-service/api/products
- http://localhost:8800/favourite-service/api/favourites
- http://localhost:8400/payment-service/api/payments

To create a user (example):

```http
POST http://localhost:8700/user-service/api/users
Content-Type: application/json

{
  "userId": 123,
  "firstName": "Alejandro",
  "lastName": "Cordoba",
  "imageUrl": "https://example.com/img.jpg",
  "email": "alejandro@example.com",
  "addressDtos": [
    {
      "fullAddress": "123 Main St",
      "postalCode": "12345",
      "city": "New York"
    }
  ],
  "credential": {
    "username": "johndoe",
    "password": "securePassword123",
    "roleBasedAuthority": "ROLE_USER",
    "isEnabled": true,
    "isAccountNonExpired": true,
    "isAccountNonLocked": true,
    "isCredentialsNonExpired": true
  }
}
```

> Nota: En los archivos de Compose, las variables de entorno usan guiones bajos (por ejemplo `SPRING_ZIPKIN_BASE_URL`, `EUREKA_CLIENT_AVAILABILITY_ZONES_DEFAULT`) para que Spring las mapee correctamente.

### Access proxy-client APIs
You can manually test `proxy-client` APIs throughout its **Swagger** interface at the following
 URL [https://localhost:8900/swagger-ui.html](https://localhost:8900/swagger-ui.html).
### Access Service Discovery Server (Eureka)
If you would like to access the Eureka service discovery point to this URL [http://localhost:8761/eureka](https://localhost:8761/eureka) to see all the services registered inside it. 

### Access user-service APIs
 URL [https://localhost:8700/swagger-ui.html](https://localhost:8700/swagger-ui.html).

<!--
Note that it is accessed through API Gateway and is secured. Therefore the browser will ask you for `username:mt` and `password:p,` write them to the dialog, and you will access it. This type of security is a **basic form security**.
-->
The **API Gateway** and **Store Service** both act as a *resource server*. <!--To know more about calling Store API in a secure way you can check the `test-em-all.sh` script on how I have changed the calling of the services using **OAuth2** security.-->

#### Check all **Spring Boot Actuator** exposed metrics http://localhost:8080/app/actuator/metrics:

```bash
{
    "names": [
        "http.server.requests",
        "jvm.buffer.count",
        "jvm.buffer.memory.used",
        "jvm.buffer.total.capacity",
        "jvm.classes.loaded",
        "jvm.classes.unloaded",
        "jvm.gc.live.data.size",
        "jvm.gc.max.data size",
        "jvm.gc.memory.allocated",
        "jvm.gc.memory.promoted",
        "jvm.gc.pause",
        "jvm.memory.committed",
        "jvm.memory.max",
        "jvm.memory.used",
        "jvm.threads.daemon",
        "jvm.threads.live",
        "jvm.threads.peak",
        "jvm.threads.states",
        "logback.events",
        "process.cpu.usage",
        "process.files.max",
        "process.files.open",
        "process.start.time",
        "process.uptime",
        "resilience4j.circuitbreaker.buffered.calls",
        "resilience4j.circuitbreaker.calls",
        "resilience4j.circuitbreaker.failure.rate",
        "resilience4j.circuitbreaker.not.permitted.calls",
        "resilience4j.circuitbreaker.slow.call.rate",
        "resilience4j.circuitbreaker.slow.calls",
        "resilience4j.circuitbreaker.state",
        "system.cpu.count",
        "system.cpu.usage",
        "system.load.average.1m",
        "tomcat.sessions.active.current",
        "tomcat.sessions.active.max",
        "tomcat.sessions.alive.max",
        "tomcat.sessions.created",
        "tomcat.sessions.expired",
        "tomcat.sessions.rejected",
        "zipkin.reporter.messages",
        "zipkin.reporter.messages.dropped",
        "zipkin.reporter.messages.total",
        "zipkin.reporter.queue.bytes",
        "zipkin.reporter.queue.spans",
        "zipkin.reporter.spans",
        "zipkin.reporter.spans.dropped",
        "zipkin.reporter.spans.total"
    ]
}
```

#### Prometheus exposed metrics at http://localhost:8080/app/actuator/prometheus

```bash
# HELP resilience4j_circuitbreaker_not_permitted_calls_total Total number of not permitted calls
# TYPE resilience4j_circuitbreaker_not_permitted_calls_total counter
resilience4j_circuitbreaker_not_permitted_calls_total{kind="not_permitted",name="proxyService",} 0.0
# HELP jvm_gc_live_data_size_bytes Size of long-lived heap memory pool after reclamation
# TYPE jvm_gc_live_data_size_bytes gauge
jvm_gc_live_data_size_bytes 3721880.0
# HELP jvm_gc_pause_seconds Time spent in GC pause
# TYPE jvm_gc_pause_seconds summary
jvm_gc_pause_seconds_count{action="end of minor GC",cause="Metadata GC Threshold",} 1.0
jvm_gc_pause_seconds_sum{action="end of minor GC",cause="Metadata GC Threshold",} 0.071
jvm_gc_pause_seconds_count{action="end of minor GC",cause="G1 Evacuation Pause",} 6.0
jvm_gc_pause_seconds_sum{action="end of minor GC",cause="G1 Evacuation Pause",} 0.551
# HELP jvm_gc_pause_seconds_max Time spent in GC pause
# TYPE jvm_gc_pause_seconds_max gauge
jvm_gc_pause_seconds_max{action="end of minor GC",cause="Metadata GC Threshold",} 0.071
jvm_gc_pause_seconds_max{action="end of minor GC",cause="G1 Evacuation Pause",} 0.136
# HELP system_cpu_usage The "recent cpu usage" for the whole system
# TYPE system_cpu_usage gauge
system_cpu_usage 0.4069206655413552
# HELP jvm_buffer_total_capacity_bytes An estimate of the total capacity of the buffers in this pool
# TYPE jvm_buffer_total_capacity_bytes gauge
jvm_buffer_total_capacity_bytes{id="mapped",} 0.0
jvm_buffer_total_capacity_bytes{id="direct",} 24576.0
# HELP zipkin_reporter_spans_dropped_total Spans dropped (failed to report)
# TYPE zipkin_reporter_spans_dropped_total counter
zipkin_reporter_spans_dropped_total 4.0
# HELP zipkin_reporter_spans_bytes_total Total bytes of encoded spans reported
# TYPE zipkin_reporter_spans_bytes_total counter
zipkin_reporter_spans_bytes_total 1681.0
# HELP tomcat_sessions_active_current_sessions  
# TYPE tomcat_sessions_active_current_sessions gauge
tomcat_sessions_active_current_sessions 0.0
# HELP jvm_classes_loaded_classes The number of classes that are currently loaded in the Java virtual machine
# TYPE jvm_classes_loaded_classes gauge
jvm_classes_loaded_classes 13714.0
# HELP process_files_open_files The open file descriptor count
# TYPE process_files_open_files gauge
process_files_open_files 17.0
# HELP resilience4j_circuitbreaker_slow_call_rate The slow call of the circuit breaker
# TYPE resilience4j_circuitbreaker_slow_call_rate gauge
resilience4j_circuitbreaker_slow_call_rate{name="proxyService",} -1.0
# HELP system_cpu_count The number of processors available to the Java virtual machine
# TYPE system_cpu_count gauge
system_cpu_count 8.0
# HELP jvm_threads_daemon_threads The current number of live daemon threads
# TYPE jvm_threads_daemon_threads gauge
jvm_threads_daemon_threads 21.0
# HELP zipkin_reporter_messages_total Messages reported (or attempted to be reported)
# TYPE zipkin_reporter_messages_total counter
zipkin_reporter_messages_total 2.0
# HELP zipkin_reporter_messages_dropped_total  
# TYPE zipkin_reporter_messages_dropped_total counter
zipkin_reporter_messages_dropped_total{cause="ResourceAccessException",} 2.0
# HELP zipkin_reporter_messages_bytes_total Total bytes of messages reported
# TYPE zipkin_reporter_messages_bytes_total counter
zipkin_reporter_messages_bytes_total 1368.0
# HELP http_server_requests_seconds  
# TYPE http_server_requests_seconds summary
http_server_requests_seconds_count{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/metrics",} 1.0
http_server_requests_seconds_sum{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/metrics",} 1.339804427
http_server_requests_seconds_count{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/prometheus",} 1.0
http_server_requests_seconds_sum{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/prometheus",} 0.053689381
# HELP http_server_requests_seconds_max  
# TYPE http_server_requests_seconds_max gauge
http_server_requests_seconds_max{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/metrics",} 1.339804427
http_server_requests_seconds_max{exception="None",method="GET",outcome="SUCCESS",status="200",uri="/actuator/prometheus",} 0.053689381
# HELP resilience4j_circuitbreaker_slow_calls The number of slow successful which were slower than a certain threshold
# TYPE resilience4j_circuitbreaker_slow_calls gauge
resilience4j_circuitbreaker_slow_calls{kind="successful",name="proxyService",} 0.0
resilience4j_circuitbreaker_slow_calls{kind="failed",name="proxyService",} 0.0
# HELP jvm_classes_unloaded_classes_total The total number of classes unloaded since the Java virtual machine has started execution
# TYPE jvm_classes_unloaded_classes_total counter
jvm_classes_unloaded_classes_total 0.0
# HELP process_files_max_files The maximum file descriptor count
# TYPE process_files_max_files gauge
process_files_max_files 1048576.0
# HELP resilience4j_circuitbreaker_calls_seconds Total number of successful calls
# TYPE resilience4j_circuitbreaker_calls_seconds summary
resilience4j_circuitbreaker_calls_seconds_count{kind="successful",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_sum{kind="successful",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_count{kind="failed",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_sum{kind="failed",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_count{kind="ignored",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_sum{kind="ignored",name="proxyService",} 0.0
# HELP resilience4j_circuitbreaker_calls_seconds_max Total number of successful calls
# TYPE resilience4j_circuitbreaker_calls_seconds_max gauge
resilience4j_circuitbreaker_calls_seconds_max{kind="successful",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_max{kind="failed",name="proxyService",} 0.0
resilience4j_circuitbreaker_calls_seconds_max{kind="ignored",name="proxyService",} 0.0
# HELP zipkin_reporter_spans_total Spans reported
# TYPE zipkin_reporter_spans_total counter
zipkin_reporter_spans_total 5.0
# HELP zipkin_reporter_queue_bytes Total size of all encoded spans queued for reporting
# TYPE zipkin_reporter_queue_bytes gauge
zipkin_reporter_queue_bytes 0.0
# HELP tomcat_sessions_expired_sessions_total  
# TYPE tomcat_sessions_expired_sessions_total counter
tomcat_sessions_expired_sessions_total 0.0
# HELP tomcat_sessions_alive_max_seconds  
# TYPE tomcat_sessions_alive_max_seconds gauge
tomcat_sessions_alive_max_seconds 0.0
# HELP process_uptime_seconds The uptime of the Java virtual machine
# TYPE process_uptime_seconds gauge
process_uptime_seconds 224.402
# HELP tomcat_sessions_active_max_sessions  
# TYPE tomcat_sessions_active_max_sessions gauge
tomcat_sessions_active_max_sessions 0.0
# HELP process_cpu_usage The "recent cpu usage" for the Java Virtual Machine process
# TYPE process_cpu_usage gauge
process_cpu_usage 5.625879043600563E-4
# HELP jvm_gc_memory_promoted_bytes_total Count of positive increases in the size of the old generation memory pool before GC to after GC
# TYPE jvm_gc_memory_promoted_bytes_total counter
jvm_gc_memory_promoted_bytes_total 1.7851088E7
# HELP logback_events_total Number of error level events that made it to the logs
# TYPE logback_events_total counter
logback_events_total{level="warn",} 5.0
logback_events_total{level="debug",} 79.0
logback_events_total{level="error",} 0.0
logback_events_total{level="trace",} 0.0
logback_events_total{level="info",} 60.0
# HELP tomcat_sessions_created_sessions_total  
# TYPE tomcat_sessions_created_sessions_total counter
tomcat_sessions_created_sessions_total 0.0
# HELP jvm_threads_live_threads The current number of live threads including both daemon and non-daemon threads
# TYPE jvm_threads_live_threads gauge
jvm_threads_live_threads 25.0
# HELP jvm_threads_states_threads The current number of threads having NEW state
# TYPE jvm_threads_states_threads gauge
jvm_threads_states_threads{state="runnable",} 6.0
jvm_threads_states_threads{state="blocked",} 0.0
jvm_threads_states_threads{state="waiting",} 8.0
jvm_threads_states_threads{state="timed-waiting",} 11.0
jvm_threads_states_threads{state="new",} 0.0
jvm_threads_states_threads{state="terminated",} 0.0
# HELP tomcat_sessions_rejected_sessions_total  
# TYPE tomcat_sessions_rejected_sessions_total counter
tomcat_sessions_rejected_sessions_total 0.0
# HELP process_start_time_seconds Start time of the process since unix epoch.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.64088634006E9
# HELP resilience4j_circuitbreaker_buffered_calls The number of buffered failed calls stored in the ring buffer
# TYPE resilience4j_circuitbreaker_buffered_calls gauge
resilience4j_circuitbreaker_buffered_calls{kind="successful",name="proxyService",} 0.0
resilience4j_circuitbreaker_buffered_calls{kind="failed",name="proxyService",} 0.0
# HELP jvm_memory_max_bytes The maximum amount of memory in bytes that can be used for memory management
# TYPE jvm_memory_max_bytes gauge
jvm_memory_max_bytes{area="nonheap",id="CodeHeap 'profiled nmethods'",} 1.22908672E8
jvm_memory_max_bytes{area="heap",id="G1 Survivor Space",} -1.0
jvm_memory_max_bytes{area="heap",id="G1 Old Gen",} 5.182062592E9
jvm_memory_max_bytes{area="nonheap",id="Metaspace",} -1.0
jvm_memory_max_bytes{area="nonheap",id="CodeHeap 'non-nmethods'",} 5836800.0
jvm_memory_max_bytes{area="heap",id="G1 Eden Space",} -1.0
jvm_memory_max_bytes{area="nonheap",id="Compressed Class Space",} 1.073741824E9
jvm_memory_max_bytes{area="nonheap",id="CodeHeap 'non-profiled nmethods'",} 1.22912768E8
# HELP jvm_memory_committed_bytes The amount of memory in bytes that is committed for the Java virtual machine to use
# TYPE jvm_memory_committed_bytes gauge
jvm_memory_committed_bytes{area="nonheap",id="CodeHeap 'profiled nmethods'",} 1.6646144E7
jvm_memory_committed_bytes{area="heap",id="G1 Survivor Space",} 2.4117248E7
jvm_memory_committed_bytes{area="heap",id="G1 Old Gen",} 1.7301504E8
jvm_memory_committed_bytes{area="nonheap",id="Metaspace",} 7.6857344E7
jvm_memory_committed_bytes{area="nonheap",id="CodeHeap 'non-nmethods'",} 2555904.0
jvm_memory_committed_bytes{area="heap",id="G1 Eden Space",} 2.71581184E8
jvm_memory_committed_bytes{area="nonheap",id="Compressed Class Space",} 1.0354688E7
jvm_memory_committed_bytes{area="nonheap",id="CodeHeap 'non-profiled nmethods'",} 6619136.0
# HELP jvm_memory_used_bytes The amount of used memory
# TYPE jvm_memory_used_bytes gauge
jvm_memory_used_bytes{area="nonheap",id="CodeHeap 'profiled nmethods'",} 1.6585088E7
jvm_memory_used_bytes{area="heap",id="G1 Survivor Space",} 2.4117248E7
jvm_memory_used_bytes{area="heap",id="G1 Old Gen",} 2.0524392E7
jvm_memory_used_bytes{area="nonheap",id="Metaspace",} 7.4384552E7
jvm_memory_used_bytes{area="nonheap",id="CodeHeap 'non-nmethods'",} 1261696.0
jvm_memory_used_bytes{area="heap",id="G1 Eden Space",} 2.5165824E7
jvm_memory_used_bytes{area="nonheap",id="Compressed Class Space",} 9365664.0
jvm_memory_used_bytes{area="nonheap",id="CodeHeap 'non-profiled nmethods'",} 6604416.0
# HELP system_load_average_1m The sum of the number of runnable entities queued to available processors and the number of runnable entities running on the available processors averaged over a period of time
# TYPE system_load_average_1m gauge
system_load_average_1m 8.68
# HELP resilience4j_circuitbreaker_state The states of the circuit breaker
# TYPE resilience4j_circuitbreaker_state gauge
resilience4j_circuitbreaker_state{name="proxyService",state="forced_open",} 0.0
resilience4j_circuitbreaker_state{name="proxyService",state="closed",} 1.0
resilience4j_circuitbreaker_state{name="proxyService",state="disabled",} 0.0
resilience4j_circuitbreaker_state{name="proxyService",state="open",} 0.0
resilience4j_circuitbreaker_state{name="proxyService",state="half_open",} 0.0
resilience4j_circuitbreaker_state{name="proxyService",state="metrics_only",} 0.0
# HELP jvm_buffer_memory_used_bytes An estimate of the memory that the Java virtual machine is using for this buffer pool
# TYPE jvm_buffer_memory_used_bytes gauge
jvm_buffer_memory_used_bytes{id="mapped",} 0.0
jvm_buffer_memory_used_bytes{id="direct",} 24576.0
# HELP resilience4j_circuitbreaker_failure_rate The failure rate of the circuit breaker
# TYPE resilience4j_circuitbreaker_failure_rate gauge
resilience4j_circuitbreaker_failure_rate{name="proxyService",} -1.0
# HELP zipkin_reporter_queue_spans Spans queued for reporting
# TYPE zipkin_reporter_queue_spans gauge
zipkin_reporter_queue_spans 0.0
# HELP jvm_gc_memory_allocated_bytes_total Incremented for an increase in the size of the (young) heap memory pool after one GC to before the next
# TYPE jvm_gc_memory_allocated_bytes_total counter
jvm_gc_memory_allocated_bytes_total 1.402994688E9
# HELP jvm_buffer_count_buffers An estimate of the number of buffers in the pool
# TYPE jvm_buffer_count_buffers gauge
jvm_buffer_count_buffers{id="mapped",} 0.0
jvm_buffer_count_buffers{id="direct",} 3.0
# HELP jvm_threads_peak_threads The peak live thread count since the Java virtual machine started or peak was reset
# TYPE jvm_threads_peak_threads gauge
jvm_threads_peak_threads 25.0
# HELP jvm_gc_max_data_size_bytes Max size of long-lived heap memory pool
# TYPE jvm_gc_max_data_size_bytes gauge
jvm_gc_max_data_size_bytes 5.182062592E9
```

#### Check All Services Health
From ecommerce front Service proxy we can check all the core services health when you have all the
 microservices up and running using Docker Compose,
```bash
selim@:~/ecommerce-microservice-backend-app$ curl -k https://localhost:8443/actuator/health -s | jq .components."\"Core Microservices\""
```
This will result in the following response:
```json
{
    "status": "UP",
    "components": {
        "circuitBreakers": {
            "status": "UP",
            "details": {
                "proxyService": {
                    "status": "UP",
                    "details": {
                        "failureRate": "-1.0%",
                        "failureRateThreshold": "50.0%",
                        "slowCallRate": "-1.0%",
                        "slowCallRateThreshold": "100.0%",
                        "bufferedCalls": 0,
                        "slowCalls": 0,
                        "slowFailedCalls": 0,
                        "failedCalls": 0,
                        "notPermittedCalls": 0,
                        "state": "CLOSED"
                    }
                }
            }
        },
        "clientConfigServer": {
            "status": "UNKNOWN",
            "details": {
                "error": "no property sources located"
            }
        },
        "discoveryComposite": {
            "status": "UP",
            "components": {
                "discoveryClient": {
                    "status": "UP",
                    "details": {
                        "services": [
                            "proxy-client",
                            "api-gateway",
                            "cloud-config",
                            "product-service",
                            "user-service",
                            "favourite-service",
                            "order-service",
                            "payment-service",
                            "shipping-service"
                        ]
                    }
                },
                "eureka": {
                    "description": "Remote status from Eureka server",
                    "status": "UP",
                    "details": {
                        "applications": {
                            "FAVOURITE-SERVICE": 1,
                            "PROXY-CLIENT": 1,
                            "API-GATEWAY": 1,
                            "PAYMENT-SERVICE": 1,
                            "ORDER-SERVICE": 1,
                            "CLOUD-CONFIG": 1,
                            "PRODUCT-SERVICE": 1,
                            "SHIPPING-SERVICE": 1,
                            "USER-SERVICE": 1
                        }
                    }
                }
            }
        },
        "diskSpace": {
            "status": "UP",
            "details": {
                "total": 981889826816,
                "free": 325116776448,
                "threshold": 10485760,
                "exists": true
            }
        },
        "ping": {
            "status": "UP"
        },
        "refreshScope": {
            "status": "UP"
        }
    }
}
```
### Testing Them All
Now it's time to test all the application functionality as one part. To do so just run
 the following automation test script:

```bash
selim@:~/ecommerce-microservice-backend-app$ ./test-em-all.sh start
```
> You can use `stop` switch with `start`, that will 
>1. start docker, 
>2. run the tests, 
>3. stop the docker instances.

The result will look like this:

```bash
Starting 'ecommerce-microservice-backend-app' for [Blackbox] testing...

Start Tests: Tue, May 31, 2020 2:09:36 AM
HOST=localhost
PORT=8080
Restarting the test environment...
$ docker-compose -p -f compose.yml down --remove-orphans
$ docker-compose -p -f compose.yml up -d
Wait for: curl -k https://localhost:8080/actuator/health... , retry #1 , retry #2, {"status":"UP"} DONE, continues...
Test OK (HTTP Code: 200)
...
Test OK (actual value: 1)
Test OK (actual value: 3)
Test OK (actual value: 3)
Test OK (HTTP Code: 404, {"httpStatus":"NOT_FOUND","message":"No product found for productId: 13","path":"/app/api/products/20","time":"2020-04-12@12:34:25.144+0000"})
...
Test OK (actual value: 3)
Test OK (actual value: 0)
Test OK (HTTP Code: 422, {"httpStatus":"UNPROCESSABLE_ENTITY","message":"Invalid productId: -1","path":"/app/api/products/-1","time":"2020-04-12@12:34:26.243+0000"})
Test OK (actual value: "Invalid productId: -1")
Test OK (HTTP Code: 400, {"timestamp":"2020-04-12T12:34:26.471+00:00","path":"/app/api/products/invalidProductId","status":400,"error":"Bad Request","message":"Type mismatch.","requestId":"044dcdf2-13"})
Test OK (actual value: "Type mismatch.")
Test OK (HTTP Code: 401, )
Test OK (HTTP Code: 200)
Test OK (HTTP Code: 403, )
Start Circuit Breaker tests!
Test OK (actual value: CLOSED)
Test OK (HTTP Code: 500, {"timestamp":"2020-05-26T00:09:48.784+00:00","path":"/app/api/products/2","status":500,"error":"Internal Server Error","message":"Did not observe any item or terminal signal within 2000ms in 'onErrorResume' (and no fallback has been configured)","requestId":"4aa9f5e8-119"})
...
Test OK (actual value: Did not observe any item or terminal signal within 2000ms)
Test OK (HTTP Code: 200)
Test OK (actual value: Fallback product2)
Test OK (HTTP Code: 200)
Test OK (actual value: Fallback product2)
Test OK (HTTP Code: 404, {"httpStatus":"NOT_FOUND","message":"Product Id: 14 not found in fallback cache!","path":"/app/api/products/14","timestamp":"2020-05-26@00:09:53.998+0000"})
...
Test OK (actual value: product name C)
Test OK (actual value: CLOSED)
Test OK (actual value: CLOSED_TO_OPEN)
Test OK (actual value: OPEN_TO_HALF_OPEN)
Test OK (actual value: HALF_OPEN_TO_CLOSED)
End, all tests OK: Tue, May 31, 2020 2:10:09 AM
```
### Tracking the services with Zipkin
Now, you can now track Microservices interactions throughout Zipkin UI from the following link:
[http://localhost:9411/zipkin/](http://localhost:9411/zipkin/)
![Zipkin UI](zipkin-dash.png)

### Closing The Story

To stop containers, first stop the application services and then the core services:

```bash
# stop non-core services
docker-compose -f compose.yml down --remove-orphans
# stop core (zipkin, eureka, config)
docker-compose -f core.yml down --remove-orphans
```

### The End
In the end, I hope you enjoyed the application and find it useful, as I did when I was developing it. 
If you would like to enhance, please: 
- **Open PRs**, 
- Give **feedback**, 
- Add **new suggestions**, and
- Finally, give it a 🌟.

*Happy Coding ...* 🙂

## Guía rápida (Quickstart)

- Requisitos mínimos (local):
  - Docker Desktop 4.x
  - Java 11 (JDK)
  - Maven (o usa `./mvnw` del repo)
  - Opcional K8s: kubectl + kind

### A. Ejecutar con Docker Compose
1) Arranca los servicios core (Eureka, Config, Zipkin):
   - Linux/macOS:
     - `docker-compose -f core.yml up -d`
   - Windows (CMD):
     - `docker-compose -f core.yml up -d`
2) Arranca el resto:
   - `docker-compose -f compose.yml up -d`
3) Endpoints útiles (con context-path):
   - Product: http://localhost:8500/product-service/api/products
   - User: http://localhost:8700/user-service/api/users
   - Order: http://localhost:8300/order-service/api/orders
   - Payment: http://localhost:8400/payment-service/api/payments
   - Shipping: http://localhost:8600/shipping-service/api/shippings
   - Favourite: http://localhost:8800/favourite-service/api/favourites

Tips Windows:
- `run-all.cmd` para iniciar todo; `stop-all.cmd` para detener.

### B. Ejecutar en Kubernetes (kind)
1) Crea un cluster kind:
   - `kind create cluster --name dev-e2e --wait 120s`
2) Aplica los manifiestos:
   - `kubectl apply -k k8s`
3) Espera readiness:
   - `kubectl -n ecommerce wait --for=condition=available --timeout=360s deployment --all`
   - `kubectl -n ecommerce wait --for=condition=ready --timeout=360s pod --all`
4) Port-forward a Pods (en bash):
   - Obtén nombres de pods: `kubectl -n ecommerce get pods -o wide`
   - Abre forwards (consola 1):
     - `kubectl -n ecommerce port-forward pod/<product-pod> 8500:8500`
   - Abre forwards (consola 2):
     - `kubectl -n ecommerce port-forward pod/<user-pod> 8700:8700`
   - Repite para: shipping 8600, payment 8400, order 8300, favourite 8800.
5) Verifica endpoints (mismos que en Compose).

## Pruebas de carga (Locust) en local
- Instala dependencias:
  - `python -m pip install -r tests/locust/requirements.txt`
- Asegúrate de tener los port-forward activos (ver sección K8s) o servicios en localhost.
- Ejecuta Locust en modo headless (1 minuto, 50 usuarios):
  - `python -m locust -f tests/locust/locustfile.py --host http://localhost --headless -u 50 -r 10 -t 1m --html locust-report.html --csv locust-results`
- Reportes generados:
  - `locust-report.html` + `locust-results*.csv`.

Notas importantes de rutas
- Los microservicios exponen context-path:
  - Product: `/product-service`, User: `/user-service`, Shipping: `/shipping-service`, etc.
- Los endpoints inician con `/api/...` tras el context-path.

## Workflows de CI en GitHub Actions

### 1) E2E - Locust on kind
- Ubicación: `.github/workflows/locust-e2e.yml`.
- Qué hace:
  - Crea un cluster kind, aplica `k8s`, espera readiness.
  - Port-forward a Pods y warm-up de Product/User.
  - Ejecuta Locust headless (reportes como artifacts).
- Cómo lanzarlo:
  - En PR/push a `dev` o manual (workflow_dispatch).

### 2) CI + E2E + Locust + Pages
- Ubicación: `.github/workflows/ci-all-pages.yml`.
- Qué hace:
  - Compila y ejecuta tests (Surefire) y empaca reportes en `site/`.
  - E2E con kind + Locust; añade resultados a `site/e2e` y `site/locust`.
  - Sube el sitio como artifact para GitHub Pages.
- Despliegue a Pages:
  - Para publicar en Pages, ver sección siguiente.

## Activar GitHub Pages (paso a paso)
1) En tu repo GitHub: Settings > Pages.
   - En “Build and deployment” > Source: selecciona “GitHub Actions”.
2) Configura el environment protegido (opcional pero recomendado):
   - Settings > Environments > `github-pages`.
   - En “Deployment branches”, permite `main`/`master` (o las ramas que quieras permitir).
   - Si tienes “Required reviewers”, desactívalo para auto-deploy o configura revisores.
3) Permisos de Actions (si tu org los restringe):
   - Settings > Actions > General > “Workflow permissions”: habilita “Read and write permissions”.
4) Ejecuta el workflow de `CI + E2E + Locust + Pages` con push a `main`/`master`.
   - El job de deploy publicará el contenido de `site/` a Pages.
5) Verifica la URL en Settings > Pages o en la salida del job (page_url).

Sugerencia: Si trabajas en `dev`, puedes revisar los artifacts generados (site.zip) sin publicar a Pages.

## Solución de problemas
- “Connection refused” durante port-forward:
  - Asegura que el Pod está Ready: `kubectl -n ecommerce get pods`.
  - Espera un poco más tras abrir el forward (los workflows usan un sleep amplio).
  - Revisa logs: `kubectl -n ecommerce logs <pod> --tail=200`.
- Rutas 404:
  - Verifica el context-path (p.ej. `/product-service/api/products`).
- Locust exige host base:
  - Usa `--host http://localhost` (el workflow ya lo incluye) o define `BASE_HOST`.

## Referencias rápidas
- Crear cluster kind: `kind create cluster --name dev-e2e --wait 120s`
- Aplicar Kustomize: `kubectl apply -k k8s`
- Esperar readiness: `kubectl -n ecommerce wait --for=condition=available --timeout=360s deployment --all`
- Port-forward (ejemplo): `kubectl -n ecommerce port-forward pod/<product-pod> 8500:8500`
- Endpoints clave:
  - Product: `GET /product-service/api/products`
  - User: `GET /user-service/api/users`
  - Order: `GET /order-service/api/orders`
  - Payment: `GET /payment-service/api/payments`
  - Shipping: `GET /shipping-service/api/shippings`
  - Favourite: `GET /favourite-service/api/favourites`

# e-Commerce-boot μServices 

## Calidad de Código y Seguridad

Esta sección describe cómo ejecutar análisis de calidad (SonarQube) y escaneo de vulnerabilidades (Trivy).

### SonarQube Local
1. Levanta SonarQube dentro del landscape principal (requiere red creada por core.yml previamente):
```
docker compose -f compose.yml up -d sonarqube
```
(O si solo quieres SonarQube: `docker run -d --name sonarqube -p 9000:9000 sonarqube:9.9-community`)
2. Accede a http://localhost:9000 y crea un token (Administración -> Seguridad).
3. En PowerShell exporta variables:
```
$Env:SONAR_HOST_URL="http://localhost:9000"
$Env:SONAR_TOKEN="<tu_token>"
```
4. Ejecuta el script:
```
quality-scan.cmd
```
Esto compila, ejecuta tests con cobertura (JaCoCo) y sube resultados a SonarQube.

### Trivy Local
Ejecuta escaneo de dependencias, código y luego imágenes:
```
trivy-scan.cmd
```
Los reportes se generan en `security-reports/`. El script fallará por vulnerabilidades HIGH/CRITICAL (mostrará mensajes) pero continúa listando reportes.

### OWASP Dependency-Check Local
Ejecuta escaneo de vulnerabilidades en dependencias Maven (complementa Trivy):
```
owasp-scan.cmd    # Windows
./owasp-scan.sh   # Linux/macOS
```
El escaneo analiza todas las dependencias declaradas en `pom.xml` de cada microservicio y busca vulnerabilidades conocidas en la base de datos de OWASP.

**Reportes generados:**
- HTML: `{module}/target/dependency-check-report.html` - Reporte visual detallado
- JSON: `{module}/target/dependency-check-report.json` - Para procesamiento automatizado
- XML: `{module}/target/dependency-check-report.xml` - Para integración con otras herramientas

Los reportes también se copian a `security-reports/owasp/` para consulta centralizada.

**Configuración:**
- Umbral CVSS: El build falla si se encuentran vulnerabilidades con CVSS >= 7.0 (configurable en `pom.xml`)
- Actualización automática: La base de datos de vulnerabilidades se actualiza automáticamente
- Supresiones: Archivo `owasp-suppressions.xml` para suprimir falsos positivos o vulnerabilidades conocidas

### Pipeline CI
El workflow `code-quality.yml` ejecuta automáticamente:
- Build + tests + cobertura
- Análisis Sonar (requiere secretos `SONAR_HOST_URL` y `SONAR_TOKEN` en GitHub)
- **OWASP Dependency-Check** para escaneo de dependencias Maven
- Escaneo Trivy filesystem e imágenes (falla en severidades HIGH/CRITICAL)

Los reportes de OWASP se publican como artefactos en GitHub Actions y están disponibles en la pestaña "Actions" de cada ejecución.

### Reportes de Seguridad en GitHub Pages
El workflow `ci-all-pages.yml` ejecuta OWASP Dependency-Check y publica los reportes en GitHub Pages:
- **Ubicación**: `https://{usuario}.github.io/{repo}/security/`
- **Estructura**: Reportes HTML organizados por microservicio
- **Actualización**: Se actualiza automáticamente en cada push a `main`, `master` o `dev`

### Ajustes y Exclusiones
Las exclusiones configuradas en `sonar-project.properties` ignoran carpetas de infraestructura (`k8s`, `infra`, `Ansible`, artefactos `target`, pruebas de rendimiento, e2e, archivos binarios y diagramas). Ajusta estas listas según evolucionen los módulos de pruebas.

### Política Inicial
- Cobertura mínima aspirada: 60% (ajustable en Sonar Quality Gate).
- 0 vulnerabilidades HIGH/CRITICAL aceptadas en escaneos Trivy.
- Sin code smells críticos nuevos en ramas principales.

### Herramientas de Seguridad Implementadas

#### OWASP Dependency-Check 
- **Propósito**: Escanea dependencias Maven en busca de vulnerabilidades conocidas (CVE)
- **Integración**: Plugin Maven en `pom.xml`, scripts locales, workflows CI/CD
- **Reportes**: HTML, JSON, XML generados automáticamente
- **Ejecución automática**: En pipelines de CI/CD y disponible localmente

#### Trivy 
- **Propósito**: Escanea filesystem, imágenes Docker y Dockerfiles
- **Integración**: Scripts locales, workflows CI/CD
- **Reportes**: Tablas en consola, SARIF para GitHub Security

#### SonarQube 
- **Propósito**: Análisis estático de código, calidad y seguridad
- **Integración**: Plugin Maven, workflows CI/CD
- **Reportes**: Dashboard web en SonarQube

### Próximos Pasos
- Agregar agregación de cobertura global.
- Integrar análisis adicional (SpotBugs) si es necesario.
- Endurecer Quality Gate (duplications, mantenibilidad) tras estabilizar cobertura.

## Patrones de Diseño

Esta sección documenta los patrones de diseño utilizados en la arquitectura de microservicios del proyecto, incluyendo patrones arquitectónicos, de resiliencia y de configuración.

### Patrones Arquitectónicos Existentes

#### 1. **API Gateway Pattern**
- **Ubicación**: `api-gateway/`
- **Implementación**: Spring Cloud Gateway
- **Propósito**: Actúa como punto de entrada único para todas las peticiones de cliente, centralizando el enrutamiento, autenticación y autorización.
- **Beneficios**: 
  - Simplifica la comunicación del cliente hacia múltiples microservicios
  - Centraliza la autenticación/autorización
  - Facilita el versionamiento de APIs
  - Proporciona un punto único para aplicar políticas cross-cutting

#### 2. **Service Discovery Pattern**
- **Ubicación**: `service-discovery/`
- **Implementación**: Netflix Eureka
- **Propósito**: Permite que los microservicios se registren y descubran dinámicamente sin necesidad de configuración estática de URLs.
- **Beneficios**:
  - Desacoplamiento entre servicios (no necesitan conocer direcciones IP/puertos)
  - Escalabilidad dinámica (servicios pueden agregarse/removerse sin reconfiguración)
  - Tolerancia a fallos (balanceo de carga automático)
  - Auto-registro y des-registro de servicios

#### 3. **External Configuration Pattern (Configuration Server)**
- **Ubicación**: `cloud-config/`
- **Implementación**: Spring Cloud Config Server
- **Propósito**: Centraliza la configuración de todos los microservicios en un servidor dedicado, permitiendo gestionar configuraciones por ambiente.
- **Beneficios**:
  - Gestión centralizada de configuración
  - Diferentes configuraciones por ambiente (dev, stage, prod)
  - Versionamiento de configuraciones
  - Reducción de duplicación de configuración
  - Soporte para configuración desde repositorios Git

#### 4. **Proxy Pattern**
- **Ubicación**: `proxy-client/`
- **Implementación**: Spring Cloud OpenFeign
- **Propósito**: Proporciona un proxy/cliente para comunicación entre microservicios, encapsulando la lógica de llamadas HTTP.
- **Beneficios**:
  - Abstracción de la comunicación HTTP
  - Integración con Service Discovery
  - Soporte para circuit breakers y retry
  - Declaración de interfaces tipo REST

#### 5. **Repository Pattern**
- **Ubicación**: Todos los servicios (ej: `product-service/src/main/java/.../repository/`)
- **Implementación**: Spring Data JPA
- **Propósito**: Abstrae la lógica de acceso a datos, proporcionando una interfaz más orientada a objetos sobre la capa de persistencia.
- **Beneficios**:
  - Separación de responsabilidades entre lógica de negocio y acceso a datos
  - Facilita el testing (mock de repositorios)
  - Independencia de la implementación de base de datos
  - Reducción de boilerplate code

#### 6. **Service Layer Pattern**
- **Ubicación**: Todos los servicios (ej: `product-service/src/main/java/.../service/`)
- **Implementación**: Interfaces y clases de servicio con anotación `@Service`
- **Propósito**: Encapsula la lógica de negocio, separándola de la capa de presentación y acceso a datos.
- **Beneficios**:
  - Separación de responsabilidades
  - Reutilización de lógica de negocio
  - Facilita testing unitario
  - Permite transacciones `@Transactional`

#### 7. **DTO (Data Transfer Object) Pattern**
- **Ubicación**: Todos los servicios (ej: `product-service/src/main/java/.../dto/`)
- **Implementación**: Clases DTO dedicadas
- **Propósito**: Objetos que transportan datos entre procesos o capas de la aplicación sin exponer la estructura interna de las entidades.
- **Beneficios**:
  - Reduce el acoplamiento entre capas
  - Optimiza transferencia de datos (solo campos necesarios)
  - Oculta estructura interna de entidades
  - Facilita versionamiento de APIs

#### 8. **Database per Service Pattern**
- **Ubicación**: Todos los servicios tienen su propia base de datos
- **Implementación**: Cada microservicio tiene su esquema SQL propio
- **Propósito**: Cada microservicio tiene su propia base de datos, garantizando independencia de datos.
- **Beneficios**:
  - Independencia de datos entre servicios
  - Escalabilidad independiente por servicio
  - Tecnologías heterogéneas de base de datos posibles
  - Evita acoplamiento a nivel de datos

#### 9. **Microservices Architecture Pattern**
- **Implementación**: 10 microservicios independientes (api-gateway, service-discovery, cloud-config, proxy-client, user-service, product-service, favourite-service, order-service, shipping-service, payment-service)
- **Propósito**: Arquitectura que estructura una aplicación como una colección de servicios débilmente acoplados.
- **Beneficios**:
  - Escalabilidad independiente por servicio
  - Desarrollo y despliegue independiente
  - Tecnologías heterogéneas posibles
  - Aislamiento de fallos

#### 10. **Event-Driven Architecture**
- **Implementación**: Kafka mencionado en `compose.yml`
- **Propósito**: Los servicios se comunican mediante eventos asíncronos.
- **Beneficios**:
  - Desacoplamiento temporal
  - Escalabilidad mejorada
  - Resiliencia mejorada
  - Soporte para procesamiento asíncrono

### Patrones de Resiliencia

#### 1. **Circuit Breaker Pattern** 
- **Ubicación**: Todos los servicios en `application.yml`
- **Implementación**: Resilience4j Circuit Breaker
- **Propósito**: Previene fallos en cascada al detectar problemas y "abrir el circuito" cuando un servicio falla repetidamente.
- **Configuración actual**:
  - `failure-rate-threshold: 50%` - Abre el circuito cuando el 50% de las llamadas fallan
  - `sliding-window-size: 10` - Ventana de evaluación de 10 llamadas
  - `wait-duration-in-open-state: 5s` - Espera 5 segundos antes de intentar de nuevo
  - `minimum-number-of-calls: 5` - Requiere mínimo 5 llamadas antes de evaluar
- **Beneficios**:
  - Tolerancia a fallos mejorada
  - Evita sobrecarga del sistema cuando hay servicios caídos
  - Recuperación automática cuando el servicio se restaura
  - Métricas expuestas vía Actuator

#### 2. **Retry Pattern** (Implementado)
- **Ubicación**: `proxy-client/`, `user-service/`, `product-service/` en `application.yml`
- **Implementación**: Resilience4j Retry
- **Propósito**: Reintenta automáticamente operaciones fallidas con estrategias de backoff configuradas.
- **Configuración actual**:
  - `max-attempts: 3` - Realiza hasta 3 intentos antes de fallar
  - `wait-duration: 1000ms` - Espera 1 segundo entre intentos
  - `exponential-backoff-multiplier: 2` - Aumenta exponencialmente el tiempo de espera
  - Reintenta solo en excepciones específicas: `ConnectException`, `SocketTimeoutException`, `ResourceAccessException`
  - Ignora excepciones de validación que no deben reintentarse
- **Beneficios**:
  - Manejo automático de fallos transitorios de red
  - Mejora significativamente la tasa de éxito de operaciones
  - Reduce la necesidad de lógica manual de reintento en el código
  - Configurable por servicio u operación específica
  - Backoff exponencial evita saturar servicios que se están recuperando
- **Uso**: Se aplica automáticamente en llamadas Feign Client y puede usarse con anotación `@Retry(name = "proxyService")` en métodos de servicio.

### Patrones de Configuración

#### 1. **External Configuration Pattern** 
- **Ubicación**: `cloud-config/` y uso en todos los servicios
- **Implementación**: Spring Cloud Config Server
- **Propósito**: Centraliza la configuración externa de todos los microservicios.
- **Beneficios**:
  - Configuración centralizada
  - Gestión por ambientes
  - Versionamiento de configuración
  - Reducción de duplicación

#### 2. **Configuration Refresh Pattern** (Implementado)
- **Ubicación**: 
  - `proxy-client/`, `user-service/`, `product-service/` en `application.yml`
  - Clases de configuración con `@RefreshScope` (ej: `ClientConfig.java`)
- **Implementación**: Spring Cloud Config Refresh con `@RefreshScope` y endpoint `/actuator/refresh`
- **Propósito**: Permite actualizar la configuración de los servicios sin necesidad de reiniciarlos mediante el endpoint de refresh.
- **Configuración**:
  - Endpoint habilitado: `management.endpoint.refresh.enabled: true`
  - Endpoint expuesto: `POST /actuator/refresh`
  - Beans con `@RefreshScope` se recargan dinámicamente
- **Cómo usar**:
  1. Actualizar configuración en el servidor de configuración (Cloud Config)
  2. Llamar al endpoint: `POST http://localhost:PORT/actuator/refresh`
  3. Los beans marcados con `@RefreshScope` se recrean con la nueva configuración
- **Beneficios**:
  - Actualización de configuración sin downtime (sin reiniciar servicios)
  - Aplicación dinámica e inmediata de cambios de configuración
  - Mejora significativa la operabilidad del sistema
  - Reducción de tiempo de recuperación tras cambios (de minutos a segundos)
  - Permite ajustar parámetros de runtime sin interrumpir el servicio
- **Ejemplo de uso**:
  ```bash
  # Refrescar configuración del user-service
  curl -X POST http://localhost:8700/user-service/actuator/refresh
  
  # Refrescar configuración del proxy-client
  curl -X POST http://localhost:8900/app/actuator/refresh
  ```

### Detalles de Implementación de Patrones Nuevos

#### Implementación del Patrón Retry

El patrón Retry se ha implementado usando Resilience4j en los servicios que realizan llamadas externas. La configuración se encuentra en los archivos `application.yml` de cada servicio.

**Configuración (proxy-client):**
```yaml
resilience4j:
  retry:
    instances:
      proxyService:
        max-attempts: 3
        wait-duration: 1000
        exponential-backoff-multiplier: 2
        retry-exceptions:
          - java.net.ConnectException
          - java.net.SocketTimeoutException
          - org.springframework.web.client.ResourceAccessException
          - feign.RetryableException
        ignore-exceptions:
          - java.lang.IllegalArgumentException
          - javax.validation.ValidationException

feign:
  circuitbreaker:
    enabled: true
  resilience4j:
    enabled: true
```

**Cómo funciona:**
- Resilience4j Retry se aplica automáticamente a todos los Feign Clients cuando `feign.resilience4j.enabled=true`
- Cuando una llamada falla con una excepción configurada en `retry-exceptions`, el sistema reintenta hasta `max-attempts` veces
- Entre cada intento espera `wait-duration` milisegundos, multiplicado por `exponential-backoff-multiplier` en cada intento (backoff exponencial)
- Las excepciones de validación (configuradas en `ignore-exceptions`) no se reintentan, ya que son errores permanentes
- Se integra con Circuit Breaker: si el Circuit Breaker está abierto, no se intentan reintentos

**Implementación:**
- `FeignClientConfig.java`: Configuración de Feign con beans refreshables que usan propiedades del Config Server
- Todos los `@FeignClient` interfaces automáticamente usan Resilience4j Retry
- Configuración puede ser sobrescrita desde Config Server y refrescada dinámicamente

**Servicios implementados:**
- `proxy-client` - Retry en todos los Feign Clients (ProductClientService, UserClientService, OrderClientService, etc.)
- `user-service` - Retry configurado
- `product-service` - Retry configurado

#### Implementación del Patrón Configuration Refresh

El patrón Configuration Refresh permite actualizar configuraciones dinámicamente sin reiniciar los servicios mediante Spring Cloud Config Server.

**Componentes implementados:**

1. **Habilitación del Config Server:**
```yaml
spring:
  cloud:
    config:
      enabled: true
      fail-fast: false
      retry:
        initial-interval: 1000
        max-attempts: 6
        max-interval: 2000
        multiplier: 1.1

management:
  endpoint:
    refresh:
      enabled: true
  endpoints:
    web:
      exposure:
        include: health,info,refresh,metrics,prometheus
```

2. **Propiedades Refreshables (`RefreshableProperties.java`):**
```java
@Component
@RefreshScope
public class RefreshableProperties {
    @Value("${app.api.timeout:10000}")
    private int apiTimeout;
    
    @Value("${app.api.max-retries:3}")
    private int maxRetries;
}
```

3. **Beans Refreshables:**
```java
@Bean
@RefreshScope
public Request.Options requestOptions(RefreshableProperties props) {
    return new Request.Options(/* usa props.getApiTimeout() */);
}
```

**Proceso completo de refresh:**

1. **Actualizar configuración en Config Server:**
   - Editar archivo en el repositorio Git del Config Server (ej: `proxy-client-dev.yml`)
   - Commit y push al repositorio

2. **Llamar al endpoint de refresh:**
   ```bash
   curl -X POST http://localhost:8900/app/actuator/refresh
   # Respuesta: ["app.api.timeout", "app.api.max-retries"] - lista de propiedades refrescadas
   ```

3. **Spring automáticamente:**
   - Recarga las propiedades del Config Server
   - Destruye y recrea todos los beans marcados con `@RefreshScope`
   - Los nuevos valores se aplican inmediatamente sin reiniciar el servicio

**Archivos de configuración del Config Server:**
Los archivos de configuración deben estar en el repositorio Git del Config Server (configurado en `cloud-config/src/main/resources/application.yml`). 
La estructura típica incluye archivos como `proxy-client-dev.yml`, `user-service-dev.yml`, `product-service-dev.yml` con las propiedades 
refreshables definidas (ej: `app.api.timeout`, `app.user.max-results`, etc.).

**Beneficios en producción:**
- Ajustar timeouts sin downtime
- Modificar límites de resultados por consulta
- Habilitar/deshabilitar features (feature flags)
- Actualizar parámetros de retry dinámicamente
- Cambiar configuración de cache sin reiniciar

**Servicios implementados:**
- `proxy-client` - RefreshableProperties + FeignClientConfig refreshable
- `user-service` - RefreshableProperties + endpoint refresh habilitado
- `product-service` - RefreshableProperties + endpoint refresh habilitado

### Documentación Detallada

Para más detalles sobre los patrones, consulta el archivo `Docs/PATRONES_DISENO.md` que contiene un análisis más profundo de los patrones y recomendaciones adicionales.

## Observabilidad y Monitoreo

Esta sección describe cómo implementar y usar el stack de monitoreo con Prometheus y Grafana para observar métricas de los microservicios.

### Stack de Monitoreo: Prometheus + Grafana

El proyecto incluye un stack completo de monitoreo implementado con:
- **Prometheus**: Sistema de monitoreo y base de datos de series temporales
- **Grafana**: Plataforma de visualización y dashboards
- **Micrometer**: Métricas de Spring Boot expuestas en formato Prometheus

### Configuración de Métricas en Microservicios

Todos los microservicios están configurados para exponer métricas Prometheus a través del endpoint `/actuator/prometheus`:

**Configuración en `application.yml`:**
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
```

**Dependencias en `pom.xml`:**
- `spring-boot-starter-actuator` - Endpoints de monitoreo
- `micrometer-registry-prometheus` - Exportador de métricas Prometheus

### Ejecutar con Docker Compose

**1. Levantar servicios de monitoreo:**
```bash
docker network create microservices_network || true

docker compose -f compose.yml up -d prometheus grafana
```

**2. Acceder a las interfaces:**

- **Prometheus**: http://localhost:9090
  - Consulta métricas directamente usando PromQL
  - Ejemplo: `rate(http_server_requests_seconds_count[5m])`
  
- **Grafana**: http://localhost:3000
  - Usuario: `admin`
  - Contraseña: `admin`
  - El dashboard "Ecommerce Microservices - Overview" se carga automáticamente

**3. Endpoints de métricas de cada servicio:**

```
API Gateway:        http://localhost:8080/actuator/prometheus
Proxy Client:       http://localhost:8900/app/actuator/prometheus
User Service:       http://localhost:8700/user-service/actuator/prometheus
Product Service:    http://localhost:8500/product-service/actuator/prometheus
Order Service:      http://localhost:8300/order-service/actuator/prometheus
Payment Service:    http://localhost:8400/payment-service/actuator/prometheus
Shipping Service:   http://localhost:8600/shipping-service/actuator/prometheus
Favourite Service:  http://localhost:8800/favourite-service/actuator/prometheus
Service Discovery:  http://localhost:8761/actuator/prometheus
Cloud Config:       http://localhost:9296/actuator/prometheus
```

### Ejecutar en Kubernetes

**1. Aplicar manifiestos de monitoreo:**
```bash
kubectl apply -f k8s/prometheus.yaml
kubectl apply -f k8s/grafana.yaml

kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

**2. Acceder a los servicios:**

Usando port-forward:
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090

kubectl port-forward -n monitoring svc/grafana 3000:3000
```

O directamente via NodePort (si está configurado):
- Prometheus: `http://<node-ip>:30090`
- Grafana: `http://<node-ip>:30000`

### Métricas Disponibles

Las métricas expuestas incluyen:

**Métricas HTTP:**
- `http_server_requests_seconds_count` - Contador de solicitudes HTTP
- `http_server_requests_seconds_sum` - Tiempo total de respuesta
- `http_server_requests_seconds_max` - Tiempo máximo de respuesta
- Métricas por código de estado (2xx, 4xx, 5xx)

**Métricas de Circuit Breaker (Resilience4j):**
- `resilience4j_circuitbreaker_state` - Estado del circuit breaker (OPEN/CLOSED/HALF_OPEN)
- `resilience4j_circuitbreaker_calls` - Llamadas totales
- `resilience4j_circuitbreaker_failure_rate` - Tasa de fallos

**Métricas de Retry (Resilience4j):**
- `resilience4j_retry_calls_total` - Intentos de retry por tipo (successful/retry/error)
- `resilience4j_retry_attempts` - Intentos realizados

**Métricas de JVM:**
- `jvm_memory_used_bytes` - Memoria usada
- `jvm_gc_pause_seconds` - Pausas de garbage collection
- `jvm_threads_live` - Hilos activos

**Métricas de Sistema:**
- `process_cpu_usage` - Uso de CPU
- `system_load_average_1m` - Carga del sistema

### Dashboards de Grafana

**Dashboard principal:** "Ecommerce Microservices - Overview"

Vista general de todos los servicios con paneles agregados. Incluye:
1. **HTTP Request Rate by Service** - Tasa de solicitudes por segundo por servicio
2. **HTTP Request Latency** - Latencia de solicitudes (percentiles 50, 95, 99)
3. **HTTP Success Rate** - Tasa de éxito (códigos 2xx)
4. **HTTP 5xx Errors** - Errores del servidor por servicio
5. **Circuit Breaker Status** - Estado de los circuit breakers
6. **Retry Attempts** - Intentos de retry por servicio
7. **Service Health Status** - Estado de salud de todos los servicios

**Dashboards específicos por servicio:**

Cada microservicio tiene su propio dashboard detallado con métricas relevantes:

1. **API Gateway Dashboard** (`api-gateway.json`)
   - Request Rate y Latency por endpoint
   - HTTP Status Codes
   - Circuit Breaker Status
   - Requests por ruta configurada
   - JVM Memory y CPU Usage

2. **User Service Dashboard** (`user-service.json`)
   - Métricas de autenticación y usuarios
   - Latencia de operaciones CRUD
   - Success Rate y Error Rate
   - Circuit Breaker y Retry
   - Métricas de JVM

3. **Product Service Dashboard** (`product-service.json`)
   - Métricas de catálogo de productos
   - Requests por endpoint (GET, POST, PUT, DELETE)
   - Latencia de búsquedas y consultas
   - Circuit Breaker Status
   - Métricas de rendimiento

4. **Order Service Dashboard** (`order-service.json`)
   - Métricas de procesamiento de órdenes
   - Latencia de creación de órdenes
   - Tasa de éxito de transacciones
   - Circuit Breaker Status
   - Métricas de JVM

5. **Payment Service Dashboard** (`payment-service.json`)
   - Métricas de procesamiento de pagos
   - Latencia de transacciones
   - Tasa de éxito de pagos
   - Circuit Breaker Status (crítico para pagos)
   - Métricas de seguridad

6. **Shipping Service Dashboard** (`shipping-service.json`)
   - Métricas de gestión de envíos
   - Latencia de operaciones
   - Success Rate
   - Circuit Breaker Status
   - Métricas de JVM

7. **Favourite Service Dashboard** (`favourite-service.json`)
   - Métricas de favoritos de usuarios
   - Latencia de operaciones
   - Success Rate
   - Circuit Breaker Status
   - Métricas de JVM

8. **Proxy Client Dashboard** (`proxy-client.json`)
   - Métricas de proxy y routing
   - Latencia de llamadas entre servicios
   - Circuit Breaker Status
   - Retry Attempts
   - Métricas de JVM

**Cada dashboard de servicio incluye:**
- **Request Rate (req/s)** - Tasa de solicitudes por segundo
- **Request Latency (ms)** - Latencia p50, p95, p99
- **Success Rate (%)** - Porcentaje de solicitudes exitosas (2xx)
- **Error Rate (5xx)** - Tasa de errores del servidor
- **HTTP Status Codes** - Distribución de códigos de estado
- **Circuit Breaker Status** - Estado de circuit breakers del servicio
- **JVM Memory Usage** - Uso de memoria heap
- **CPU Usage (%)** - Uso de CPU del proceso
- **Requests by Endpoint** - Solicitudes desglosadas por URI
- **Service Health Status** - Estado de salud del servicio

**Acceder a los dashboards:**
1. Accede a Grafana (http://localhost:3000)
2. Ve a Dashboards > Microservices
3. Selecciona el dashboard del servicio que deseas visualizar

**Personalizar dashboards:**
1. Accede a Grafana (http://localhost:3000)
2. Ve a Dashboards > Microservices
3. Selecciona el dashboard que deseas editar
4. Haz clic en "Edit" para modificar paneles
5. Usa PromQL queries para agregar nuevas métricas

**Regenerar dashboards:**
Si necesitas regenerar los dashboards (por ejemplo, después de agregar nuevos servicios), ejecuta:
```bash
python monitoring/grafana/scripts/create_service_dashboard.py
```

### Consultas PromQL Útiles

**Tasa de solicitudes por servicio:**
```promql
sum(rate(http_server_requests_seconds_count[5m])) by (application)
```

**Latencia p99 por servicio:**
```promql
histogram_quantile(0.99, sum(rate(http_server_requests_seconds_bucket[5m])) by (le, application)) * 1000
```

**Tasa de éxito (códigos 2xx):**
```promql
sum(rate(http_server_requests_seconds_count{status=~"2.."}[5m])) by (application) 
/ 
sum(rate(http_server_requests_seconds_count[5m])) by (application)
```

**Circuit breakers abiertos:**
```promql
resilience4j_circuitbreaker_state{state="open"}
```

**Errores 5xx por servicio:**
```promql
sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m])) by (application, status)
```

### Configuración de Prometheus

El archivo de configuración está en `monitoring/prometheus/prometheus.yml` y define:

- **Intervalo de scraping**: 15 segundos
- **Retención de datos**: 30 días
- **Targets**: Todos los microservicios configurados para scraping

Para modificar la configuración:
1. Edita `monitoring/prometheus/prometheus.yml`
2. Reinicia Prometheus:
   ```bash
   # Docker Compose
   docker compose -f compose.yml restart prometheus
   
   # Kubernetes - recarga la configuración
   curl -X POST http://localhost:9090/-/reload
   ```

### Archivos de Configuración

**Estructura de monitoreo:**
```
monitoring/
├── prometheus/
│   └── prometheus.yml          # Configuración de Prometheus
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   │   └── prometheus.yml  # Datasource de Prometheus
    │   └── dashboards/
    │       └── dashboard.yml   # Configuración de dashboards
    ├── dashboards/
    │   ├── microservices-overview.json  # Dashboard principal (overview)
    │   ├── api-gateway.json             # Dashboard API Gateway
    │   ├── user-service.json            # Dashboard User Service
    │   ├── product-service.json         # Dashboard Product Service
    │   ├── order-service.json           # Dashboard Order Service
    │   ├── payment-service.json         # Dashboard Payment Service
    │   ├── shipping-service.json        # Dashboard Shipping Service
    │   ├── favourite-service.json       # Dashboard Favourite Service
    │   └── proxy-client.json            # Dashboard Proxy Client
    └── scripts/
        └── create_service_dashboard.py  # Script para generar dashboards
```

**Manifiestos Kubernetes:**
- `k8s/prometheus.yaml` - Deployment, Service y ConfigMap de Prometheus
- `k8s/grafana.yaml` - Deployment, Service y ConfigMaps de Grafana

## Gestión de Logs con Elasticsearch

Esta sección describe cómo configurar y usar Elasticsearch para la gestión centralizada de logs de todos los microservicios.

### Stack ELK: Elasticsearch + Filebeat

El proyecto incluye una configuración simplificada de ELK Stack centrada en Elasticsearch:
- **Elasticsearch**: Almacenamiento y búsqueda de logs centralizados
- **Filebeat**: Agente ligero que recopila logs de contenedores Docker y los envía a Elasticsearch
- **Logs estructurados**: Los microservicios generan logs en formato JSON para facilitar el análisis

### Ejecutar con Docker Compose

**1. Levantar Elasticsearch y Filebeat:**
```bash
docker network create microservices_network || true

docker compose -f compose.yml up -d elasticsearch filebeat
```

**2. Verificar que Elasticsearch está funcionando:**
```bash
curl http://localhost:9200/_cluster/health?pretty

curl http://localhost:9200/_cat/indices?v
```

**3. Acceso a Elasticsearch:**
- **Elasticsearch API**: http://localhost:9200

### Ejecutar en Kubernetes

**1. Aplicar manifiestos de logging:**
```bash
kubectl apply -f k8s/elasticsearch.yaml
kubectl apply -f k8s/filebeat.yaml

kubectl get pods -n logging
kubectl get svc -n logging
```

**2. Acceder a Elasticsearch:**

Usando port-forward:
```bash
kubectl port-forward -n logging svc/elasticsearch 9200:9200
```

O directamente via NodePort:
- Elasticsearch: `http://<node-ip>:30200`

**3. Verificar logs recopilados:**
```bash
curl http://localhost:9200/_cat/indices?v

curl -X GET "http://localhost:9200/ecommerce-microservices-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "container.name": "product-service"
      }
    }
  }'
```

### Configuración de Filebeat

Filebeat está configurado para:
- **Recopilar logs**: De todos los contenedores Docker en `/var/lib/docker/containers/`
- **Auto-descubrimiento**: Detecta automáticamente nuevos contenedores
- **Formato JSON**: Parsea logs en formato JSON cuando están disponibles
- **Envío a Elasticsearch**: Indexa logs en Elasticsearch con el patrón `ecommerce-microservices-YYYY.MM.DD`

**Configuración en `elk/filebeat/filebeat.yml`:**
```yaml
output.elasticsearch:
  hosts: ['elasticsearch:9200']
  index: "ecommerce-microservices-%{+yyyy.MM.dd}"
```

### Estructura de Logs

Los logs se indexan en Elasticsearch con la siguiente estructura:

**Campos principales:**
- `@timestamp`: Fecha y hora del log
- `message`: Contenido del mensaje de log
- `container.name`: Nombre del contenedor (ej: `product-service-container`)
- `container.id`: ID del contenedor Docker
- `json.*`: Campos parseados de logs JSON (si aplica)

### Consultas Útiles en Elasticsearch

**Buscar logs por servicio:**
```json
GET /ecommerce-microservices-*/_search
{
  "query": {
    "wildcard": {
      "container.name": "*product-service*"
    }
  }
}
```

**Buscar errores:**
```json
GET /ecommerce-microservices-*/_search
{
  "query": {
    "match": {
      "message": "ERROR"
    }
  }
}
```

**Buscar logs en un rango de tiempo:**
```json
GET /ecommerce-microservices-*/_search
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "now-1h",
        "lte": "now"
      }
    }
  }
}
```

**Contar logs por servicio:**
```json
GET /ecommerce-microservices-*/_search
{
  "size": 0,
  "aggs": {
    "services": {
      "terms": {
        "field": "container.name.keyword",
        "size": 10
      }
    }
  }
}
```

### Archivos de Configuración

**Estructura de ELK:**
```
elk/
├── filebeat/
│   └── filebeat.yml        # Configuración de Filebeat
└── logback-spring.xml      # Configuración de logging JSON (referencia)
```

**Manifiestos Kubernetes:**
- `k8s/elasticsearch.yaml` - StatefulSet, Service y ConfigMap de Elasticsearch
- `k8s/filebeat.yaml` - DaemonSet, ConfigMap, ServiceAccount y RBAC de Filebeat

## Tracing Distribuido con Zipkin

### Stack de Tracing: Spring Cloud Sleuth + Zipkin

El proyecto incluye un sistema completo de tracing distribuido implementado con:
- **Spring Cloud Sleuth**: Instrumentación automática para rastrear solicitudes
- **Zipkin**: Sistema de recopilación y visualización de traces
- **Trace ID y Span ID**: Identificadores únicos propagados a través de todos los servicios

### Funcionalidades Implementadas

**1. Instrumentación Automática:**
- Todos los microservicios están instrumentados con Spring Cloud Sleuth
- Traces automáticos para:
  - Solicitudes HTTP (Spring MVC, Spring WebFlux)
  - Llamadas entre servicios (Feign Clients)
  - Base de datos (JPA/Hibernate)
  - Mensajería (Kafka - si está configurado)

**2. Propagación de Traces:**
- Trace ID único por solicitud
- Span ID para cada operación dentro de un trace
- Propagación automática a través de:
  - Headers HTTP (`X-B3-TraceId`, `X-B3-SpanId`, etc.)
  - Llamadas Feign entre servicios
  - API Gateway a microservicios

**3. Sampling Configurable:**
- Probabilidad de sampling configurable por servicio
- Valor por defecto: 1.0 (100% de las solicitudes se rastrean)
- Configurable mediante variable de entorno: `SLEUTH_SAMPLER_PROBABILITY`

### Ejecutar con Docker Compose

**1. Levantar Zipkin:**
```bash
docker compose -f compose.yml up -d zipkin
```

**2. Verificar que esté corriendo:**
```bash
curl http://localhost:9411/health
```

**3. Generar tráfico y ver traces:**
```bash

curl http://localhost:8080/product-service/api/products

```

**4. Búsqueda de Traces en Zipkin UI:**
- **Por servicio**: Selecciona un servicio específico
- **Por tiempo**: Define rango de tiempo
- **Por trace ID**: Si conoces el trace ID de los logs
- **Por tag**: Busca por tags personalizados

### Ejecutar en Kubernetes

**1. Aplicar manifiestos de Zipkin:**
```bash
kubectl apply -f k8s/zipkin.yaml

kubectl get pods -n ecommerce | grep zipkin
kubectl get svc -n ecommerce | grep zipkin
```

**2. Acceder a Zipkin:**

Usando port-forward:
```bash
kubectl port-forward -n ecommerce svc/zipkin 9411:9411
```

O directamente via NodePort:
- Zipkin: `http://<node-ip>:30411`

**3. Verificar traces:**
```bash

kubectl port-forward -n ecommerce svc/api-gateway 8080:8080
curl http://localhost:8080/product-service/api/products

```

### Configuración de Sampling

**Ajustar sampling rate por servicio:**

En `application.yml` o mediante variable de entorno:
```yaml
spring:
  sleuth:
    sampler:
      probability: 0.5  
```

**Configurar mediante variable de entorno:**
```bash

SPRING_SLEUTH_SAMPLER_PROBABILITY=0.5


env:
  - name: SLEUTH_SAMPLER_PROBABILITY
    value: "0.5"
```

**Recomendaciones de sampling:**
- **Desarrollo**: 1.0 (100%) - Para ver todas las solicitudes
- **Producción**: 0.1 - 0.5 (10-50%) - Balance entre visibilidad y overhead
- **Servicios críticos**: 1.0 (100%) - Para diagnóstico completo

### Visualización de Traces

**1. Trace Timeline:**
- Muestra la duración total de la solicitud
- Visualiza todos los servicios involucrados
- Indica el tiempo en cada servicio

**2. Dependency Graph:**
- Visualiza las dependencias entre servicios
- Muestra la frecuencia de llamadas
- Identifica cuellos de botella

**3. Trace Details:**
- Span individuales con:
  - Timestamp de inicio y fin
  - Duración exacta
  - Tags y annotations
  - Errores (si los hay)

### Búsqueda y Filtrado

**Búsqueda por:**
- **Service Name**: Nombre del servicio (ej: `api-gateway`, `product-service`)
- **Span Name**: Operación específica (ej: `GET /api/products`)
- **Trace ID**: ID único del trace
- **Duration**: Duración mínima/máxima
- **Tags**: Tags personalizados
- **Annotations**: Anotaciones en los spans

**Ejemplo de búsqueda:**
```
Service Name: api-gateway
Span Name: GET /product-service/api/products
Min Duration: 100ms
Max Duration: 5000ms
```

### Integración con Logs

Los traces se integran automáticamente con los logs:

**Formato de logs con Sleuth:**
```
[api-gateway,1234567890123456789,9876543210987654] INFO - Processing request
```

Donde:
- `api-gateway` - Nombre del servicio
- `1234567890123456789` - Trace ID
- `9876543210987654` - Span ID

**Buscar en logs por Trace ID:**
```bash

trace.id:1234567890123456789


docker logs <container> | grep 1234567890123456789
```

### Configuración Avanzada

**1. Tags Personalizados:**
```java
@Autowired
private Tracer tracer;

public void someMethod() {
    Span span = tracer.currentSpan();
    span.tag("custom.tag", "value");
    span.tag("user.id", userId);
}
```

**2. Annotations Personalizadas:**
```java
span.event("custom.event");
span.tag("annotation", "something happened");
```

**3. Span Personalizado:**
```java
@NewSpan("custom-operation")
public void customOperation() {
    
}
```

### Métricas de Zipkin en Prometheus

Zipkin expone métricas que pueden ser scrapeadas por Prometheus:

**Métricas disponibles:**
- `zipkin_reporter_spans_total` - Total de spans reportados
- `zipkin_reporter_spans_dropped_total` - Spans que fallaron al reportar
- `zipkin_reporter_queue_spans` - Spans en cola para reportar

**Configurar scraping en Prometheus:**
```yaml
scrape_configs:
  - job_name: 'zipkin'
    static_configs:
      - targets: ['zipkin:9411']
        labels:
          service: 'zipkin'
```

### Persistencia de Traces

**Configuración actual (Memoria):**
- Traces almacenados en memoria
- Se pierden al reiniciar Zipkin
- Adecuado para desarrollo

**Configurar persistencia con Elasticsearch:**

1. Modificar `compose.yml`:
```yaml
zipkin:
  environment:
    - STORAGE_TYPE=elasticsearch
    - ES_HOSTS=http://elasticsearch:9200
```

2. O en Kubernetes:
```yaml
env:
  - name: STORAGE_TYPE
    value: "elasticsearch"
  - name: ES_HOSTS
    value: "http://elasticsearch:9200"
```

### Troubleshooting

**No aparecen traces en Zipkin:**
1. Verifica que Zipkin esté corriendo: `curl http://localhost:9411/health`
2. Verifica la URL de Zipkin en los servicios: `SPRING_ZIPKIN_BASE_URL`
3. Verifica el sampling rate: `SLEUTH_SAMPLER_PROBABILITY`
4. Revisa los logs del servicio para errores de conexión

**Traces incompletos:**
1. Verifica que todos los servicios tengan Sleuth configurado
2. Verifica que los headers de trace se propaguen (X-B3-*)
3. Revisa que Feign Clients tengan Sleuth habilitado

**Alto overhead de performance:**
1. Reduce el sampling rate: `SLEUTH_SAMPLER_PROBABILITY=0.1`
2. Considera usar async reporting (configurar RabbitMQ/Kafka)

### Archivos de Configuración

**Dependencias (pom.xml):**
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-sleuth</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-sleuth-zipkin</artifactId>
</dependency>
```

**Configuración en servicios (application.yml):**
```yaml
spring:
  zipkin:
    base-url: ${SPRING_ZIPKIN_BASE_URL:http://localhost:9411/}
    sender:
      type: web
  sleuth:
    sampler:
      probability: ${SLEUTH_SAMPLER_PROBABILITY:1.0}
    zipkin:
      base-url: ${SPRING_ZIPKIN_BASE_URL:http://localhost:9411/}
```

**Manifiestos Kubernetes:**
- `k8s/zipkin.yaml` - Deployment, Service y ConfigMap de Zipkin

### Ejemplos de Uso

**1. Rastrear una solicitud completa:**
```
1. Cliente → API Gateway (Trace ID: abc123)
2. API Gateway → Product Service (Trace ID: abc123)
3. Product Service → Database (Trace ID: abc123)
4. Product Service → User Service (Trace ID: abc123)
```

Todos los pasos aparecen en el mismo trace en Zipkin.

**2. Identificar cuellos de botella:**
- Ver duración de cada span
- Identificar servicios lentos
- Analizar dependencias problemáticas

**3. Debugging de errores:**
- Buscar traces con errores
- Ver stack traces completos
- Analizar el flujo completo de la solicitud

## Alertas para Situaciones Críticas

Esta sección describe cómo configurar y usar Prometheus Alertmanager para alertar sobre situaciones críticas en los microservicios.

### Stack de Alertas: Prometheus + Alertmanager

El proyecto incluye un sistema completo de alertas implementado con:
- **Prometheus**: Evalúa reglas de alertas basadas en métricas
- **Alertmanager**: Gestiona, agrupa y envía notificaciones de alertas
- **Reglas de alertas**: Definidas para situaciones críticas, de infraestructura y de negocio

### Reglas de Alertas Implementadas

**Alertas Críticas de Microservicios:**

1. **ServiceDown** (Crítica)
   - **Condición**: Servicio no responde por más de 1 minuto
   - **Severidad**: Critical
   - **Acción**: Notificación inmediata

2. **HighErrorRate** (Crítica)
   - **Condición**: Más del 5% de errores 5xx en los últimos 5 minutos
   - **Severidad**: Critical
   - **Umbral**: 5% de tasa de error

3. **HighLatency** (Advertencia)
   - **Condición**: Latencia p99 > 1 segundo por más de 5 minutos
   - **Severidad**: Warning
   - **Umbral**: 1 segundo

4. **CircuitBreakerOpen** (Crítica)
   - **Condición**: Circuit breaker en estado OPEN por más de 2 minutos
   - **Severidad**: Critical
   - **Indica**: Servicio no disponible o con fallos constantes

5. **CircuitBreakerHalfOpen** (Advertencia)
   - **Condición**: Circuit breaker en estado HALF_OPEN por más de 5 minutos
   - **Severidad**: Warning
   - **Indica**: Servicio en proceso de recuperación

6. **HighRetryRate** (Advertencia)
   - **Condición**: Más del 30% de llamadas requieren retry
   - **Severidad**: Warning
   - **Umbral**: 30% de tasa de retry

**Alertas de Infraestructura:**

7. **HighJvmMemoryUsage** (Advertencia)
   - **Condición**: Uso de memoria heap > 85% por más de 5 minutos
   - **Severidad**: Warning
   - **Umbral**: 85% de memoria

8. **HighCpuUsage** (Advertencia)
   - **Condición**: Uso de CPU > 80% por más de 5 minutos
   - **Severidad**: Warning
   - **Umbral**: 80% de CPU

9. **HighGcPauseTime** (Advertencia)
   - **Condición**: Tiempo de pausa GC > 0.1s/s por más de 5 minutos
   - **Severidad**: Warning
   - **Indica**: Problemas de rendimiento de JVM

10. **PrometheusTargetDown** (Crítica)
    - **Condición**: Prometheus no puede scrapear un target por más de 2 minutos
    - **Severidad**: Critical
    - **Indica**: Problema de monitoreo o servicio caído

**Alertas de Negocio:**

11. **NoHttpRequests** (Advertencia)
    - **Condición**: Sin solicitudes HTTP en los últimos 10 minutos
    - **Severidad**: Warning
    - **Indica**: Posible problema de tráfico o servicio no accesible

12. **LowSuccessRate** (Crítica)
    - **Condición**: Tasa de éxito < 90% por más de 5 minutos
    - **Severidad**: Critical
    - **Umbral**: 90% de éxito

### Ejecutar con Docker Compose

**1. Levantar Alertmanager:**
```bash
docker compose -f compose.yml up -d alertmanager
```

**2. Verificar configuración:**
```bash

curl http://localhost:9093/api/v1/status

curl http://localhost:9093/api/v1/alerts
```

**3. Acceso a Alertmanager:**
- **Alertmanager UI**: http://localhost:9093
  - Ver alertas activas
  - Ver silencios (silences)
  - Ver historial de alertas

**4. Verificar reglas de alertas en Prometheus:**
- **Prometheus Alerts**: http://localhost:9090/alerts
  - Ver todas las reglas de alertas
  - Ver estado de cada alerta (Pending/Firing)

### Ejecutar en Kubernetes

**1. Aplicar manifiestos de alertas:**
```bash
kubectl apply -f k8s/alertmanager.yaml

kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

**2. Acceder a Alertmanager:**

Usando port-forward:
```bash
kubectl port-forward -n monitoring svc/alertmanager 9093:9093
```

O directamente via NodePort:
- Alertmanager: `http://<node-ip>:30093`

**3. Verificar alertas:**
```bash
kubectl port-forward -n monitoring svc/alertmanager 9093:9093
curl http://localhost:9093/api/v1/alerts
```

### Configuración de Notificaciones

Alertmanager está configurado con receptores para diferentes tipos de alertas:

**Receptores configurados:**
- `default-receiver`: Alertas generales (webhook)
- `critical-receiver`: Alertas críticas (webhook)
- `infrastructure-receiver`: Alertas de infraestructura (webhook)
- `business-receiver`: Alertas de negocio (webhook)

**Configurar notificaciones por Slack:**

```yaml
receivers:
  - name: 'critical-receiver'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#alerts'
        title: 'Alerta Crítica'
        text: '{{ .CommonAnnotations.description }}'
```
### Health Checks y Probes en Kubernetes

Todos los microservicios están configurados con health checks:

**Liveness Probe:**
- **Propósito**: Determina si el contenedor está vivo
- **Acción**: Si falla, Kubernetes reinicia el contenedor
- **Configuración**: 
  - Path: `/actuator/health` (o con context-path)
  - Initial Delay: 60 segundos
  - Period: 10 segundos
  - Timeout: 5 segundos
  - Failure Threshold: 3

**Readiness Probe:**
- **Propósito**: Determina si el contenedor está listo para recibir tráfico
- **Acción**: Si falla, Kubernetes remueve el pod del Service
- **Configuración**:
  - Path: `/actuator/health` (o con context-path)
  - Initial Delay: 30 segundos
  - Period: 5 segundos
  - Timeout: 3 segundos
  - Failure Threshold: 3

**Ejemplo de configuración en Kubernetes:**
```yaml
livenessProbe:
  httpGet:
    path: /product-service/actuator/health
    port: 8500
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /product-service/actuator/health
    port: 8500
  initialDelaySeconds: 30
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

### Gestión de Alertas

**Ver alertas activas:**
```bash
curl http://localhost:9093/api/v1/alerts

```
### Inhibiciones de Alertas

Las inhibiciones evitan alertas duplicadas o relacionadas:

**Configuradas:**
- Si `ServiceDown` está activa, no alertar sobre `HighLatency` del mismo servicio
- Si `ServiceDown` está activa, no alertar sobre `HighErrorRate` del mismo servicio

**Lógica**: Si un servicio está caído, no tiene sentido alertar sobre latencia o errores.

### Archivos de Configuración

**Estructura de alertas:**
```
monitoring/
├── prometheus/
│   ├── prometheus.yml    # Configuración de Prometheus (incluye alertmanager)
│   └── alerts.yml       # Reglas de alertas
└── alertmanager/
    └── alertmanager.yml # Configuración de Alertmanager y notificaciones
```

**Manifiestos Kubernetes:**
- `k8s/prometheus.yaml` - ConfigMap con reglas de alertas
- `k8s/alertmanager.yaml` - Deployment, Service y ConfigMap de Alertmanager

### Personalizar Reglas de Alertas

Para modificar umbrales o agregar nuevas alertas:

1. Edita `monitoring/prometheus/alerts.yml`
2. Reinicia Prometheus:
   ```bash
   # Docker Compose
   docker compose -f compose.yml restart prometheus
   
   # Kubernetes - recarga configuración
   curl -X POST http://localhost:9090/-/reload
   ```

**Ejemplo de nueva regla:**
```yaml
- alert: CustomAlert
  expr: your_promql_query > threshold
  for: 5m
  labels:
    severity: warning
    component: custom
  annotations:
    summary: "Resumen de la alerta"
    description: "Descripción detallada: {{ $value }}"
```