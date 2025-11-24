package com.selimhorri.app.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

/**
 * Example of refreshable properties for user-service.
 * These properties come from the Config Server and can be refreshed without restarting the service.
 * 
 * Usage: Call POST /user-service/actuator/refresh to reload these properties
 * after updating them in Config Server.
 */
@Component
@RefreshScope
public class RefreshableProperties {
	
	/**
	 * Database connection timeout (in milliseconds).
	 * Default: 5000ms (5 seconds)
	 */
	@Value("${app.database.connection-timeout:5000}")
	private int databaseConnectionTimeout;
	
	/**
	 * Maximum number of users to return in a single query.
	 * Default: 100
	 */
	@Value("${app.user.max-results:100}")
	private int maxUsersPerQuery;
	
	/**
	 * Enable/disable user caching.
	 * Default: true
	 */
	@Value("${app.user.enable-cache:true}")
	private boolean enableUserCache;
	
	/**
	 * Cache expiration time in seconds.
	 * Default: 300 seconds (5 minutes)
	 */
	@Value("${app.user.cache-expiration:300}")
	private int cacheExpirationSeconds;
	
	// Getters
	public int getDatabaseConnectionTimeout() {
		return databaseConnectionTimeout;
	}
	
	public int getMaxUsersPerQuery() {
		return maxUsersPerQuery;
	}
	
	public boolean isEnableUserCache() {
		return enableUserCache;
	}
	
	public int getCacheExpirationSeconds() {
		return cacheExpirationSeconds;
	}
	
}

