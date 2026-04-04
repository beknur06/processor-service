package kz.ktj.digitaltwin.processor.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

/**
 * ClickHouse DataSource + автосоздание таблиц при старте.
 */
@Configuration
public class ClickHouseConfig {

    private static final Logger log = LoggerFactory.getLogger(ClickHouseConfig.class);

    @Value("${clickhouse.url}")
    private String url;

    @Value("${clickhouse.username}")
    private String username;

    @Value("${clickhouse.password}")
    private String password;

    @Bean
    public DataSource clickHouseDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName("com.clickhouse.jdbc.ClickHouseDriver");
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(1);
        config.setConnectionTimeout(5000);
        return new HikariDataSource(config);
    }

    /**
     * Создаём таблицы ClickHouse при старте, если их нет.
     */
    @PostConstruct
    public void initSchema() {
        try (Connection conn = clickHouseDataSource().getConnection();
             Statement stmt = conn.createStatement()) {

            // Raw telemetry (partitioned by day, TTL 72 hours)
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS telemetry_raw (
                    event_time   DateTime64(3),
                    locomotive_id String,
                    locomotive_type String,
                    param_name   String,
                    value        Float64,
                    phase        String,
                    quality_flag UInt8 DEFAULT 1,
                    partition_date Date DEFAULT toDate(event_time)
                )
                ENGINE = MergeTree()
                PARTITION BY partition_date
                ORDER BY (locomotive_id, param_name, event_time)
                TTL partition_date + INTERVAL 72 HOUR
                SETTINGS index_granularity = 8192
                """);

            // 1-minute aggregates (materialized view)
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS telemetry_1min_agg (
                    event_time   DateTime,
                    locomotive_id String,
                    param_name   String,
                    avg_value    Float64,
                    min_value    Float64,
                    max_value    Float64,
                    stddev_value Float64,
                    sample_count UInt32
                )
                ENGINE = SummingMergeTree()
                PARTITION BY toYYYYMM(event_time)
                ORDER BY (locomotive_id, param_name, event_time)
                """);

            // Materialized view that auto-populates 1min aggregates
            stmt.execute("""
                CREATE MATERIALIZED VIEW IF NOT EXISTS telemetry_1min_mv
                TO telemetry_1min_agg
                AS SELECT
                    toStartOfMinute(event_time) AS event_time,
                    locomotive_id,
                    param_name,
                    avg(value)      AS avg_value,
                    min(value)      AS min_value,
                    max(value)      AS max_value,
                    stddevPop(value) AS stddev_value,
                    count()         AS sample_count
                FROM telemetry_raw
                GROUP BY
                    toStartOfMinute(event_time),
                    locomotive_id,
                    param_name
                """);

            log.info("ClickHouse schema initialized successfully");

        } catch (Exception e) {
            log.error("Failed to initialize ClickHouse schema: {}", e.getMessage());
            // Don't crash — ClickHouse might not be up yet in dev
        }
    }
}
