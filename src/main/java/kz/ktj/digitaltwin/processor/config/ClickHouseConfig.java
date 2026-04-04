package kz.ktj.digitaltwin.processor.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;

@Configuration
public class ClickHouseConfig {

    private static final Logger log = LoggerFactory.getLogger(ClickHouseConfig.class);

    @Value("${clickhouse.url}")
    private String url;

    @Value("${clickhouse.username}")
    private String username;

    @Value("${clickhouse.password}")
    private String password;

    @Bean(name = "clickHouseDataSource")
    public DataSource clickHouseDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName("com.clickhouse.jdbc.ClickHouseDriver");
        config.setMaximumPoolSize(5);
        config.setMinimumIdle(1);
        config.setConnectionTimeout(5000);

        HikariDataSource dataSource = new HikariDataSource(config);
        initSchema(dataSource);
        return dataSource;
    }

    private void initSchema(DataSource dataSource) {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {

            //noinspection SqlDialectInspection,SqlNoDataSourceInspection,SqlResolve
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS telemetry_raw (
                    event_time      DateTime64(3),
                    locomotive_id   String,
                    locomotive_type String,
                    param_name      String,
                    value           Float64,
                    phase           String,
                    quality_flag    UInt8 DEFAULT 1,
                    partition_date  Date DEFAULT toDate(event_time)
                )
                ENGINE = MergeTree()
                PARTITION BY partition_date
                ORDER BY (locomotive_id, param_name, event_time)
                TTL partition_date + INTERVAL 72 HOUR
                SETTINGS index_granularity = 8192
                """);

            //noinspection SqlDialectInspection,SqlNoDataSourceInspection,SqlResolve
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS telemetry_1min_agg (
                    event_time    DateTime,
                    locomotive_id String,
                    param_name    String,
                    sum_value     SimpleAggregateFunction(sum, Float64),
                    min_value     SimpleAggregateFunction(min, Float64),
                    max_value     SimpleAggregateFunction(max, Float64),
                    sample_count  SimpleAggregateFunction(sum, UInt64)
                )
                ENGINE = AggregatingMergeTree()
                PARTITION BY toYYYYMM(event_time)
                ORDER BY (locomotive_id, param_name, event_time)
                """);

            //noinspection SqlDialectInspection,SqlNoDataSourceInspection,SqlResolve
            stmt.execute("""
                CREATE MATERIALIZED VIEW IF NOT EXISTS telemetry_1min_mv
                TO telemetry_1min_agg
                AS
                SELECT
                    toStartOfMinute(event_time) AS event_time,
                    locomotive_id,
                    param_name,
                    sum(value) AS sum_value,
                    min(value) AS min_value,
                    max(value) AS max_value,
                    count()    AS sample_count
                FROM telemetry_raw
                GROUP BY
                    event_time,
                    locomotive_id,
                    param_name
                ;
                """);

            log.info("ClickHouse schema initialized successfully");
        } catch (Exception e) {
            log.error("Failed to initialize ClickHouse schema: {}", e.getMessage());
            throw new IllegalStateException("Could not create ClickHouse tables", e);
        }
    }
}