package kz.ktj.digitaltwin.processor.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import kz.ktj.digitaltwin.processor.config.ProcessorProperties;
import kz.ktj.digitaltwin.processor.dto.ProcessedTelemetry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentLinkedQueue;

@Service
public class ClickHouseWriter {

    private static final Logger log = LoggerFactory.getLogger(ClickHouseWriter.class);

    private static final String INSERT_SQL = """
        INSERT INTO telemetry_raw (event_time, locomotive_id, locomotive_type,
                                    param_name, value, phase)
        VALUES (?, ?, ?, ?, ?, ?)
        """;

    private final DataSource dataSource;
    private final int batchSize;
    private final ConcurrentLinkedQueue<RowData> buffer = new ConcurrentLinkedQueue<>();

    private final Counter rowsWritten;
    private final Counter flushErrors;
    private final Timer flushDuration;

    public ClickHouseWriter(@Qualifier("clickHouseDataSource") DataSource dataSource,
                            ProcessorProperties properties,
                            MeterRegistry meterRegistry) {
        this.dataSource = dataSource;
        this.batchSize = properties.getBatch().getSize();
        this.rowsWritten = Counter.builder("processor.clickhouse.rows_written").register(meterRegistry);
        this.flushErrors = Counter.builder("processor.clickhouse.flush_errors").register(meterRegistry);
        this.flushDuration = Timer.builder("processor.clickhouse.flush_duration").register(meterRegistry);
    }

    public void buffer(ProcessedTelemetry telemetry) {
        Timestamp ts = Timestamp.from(telemetry.getTimestamp());
        String locoId = telemetry.getLocomotiveId();
        String locoType = telemetry.getLocomotiveType();
        String phase = telemetry.getPhase();

        Map<String, Double> params = telemetry.getSmoothedParameters();
        for (Map.Entry<String, Double> entry : params.entrySet()) {
            buffer.offer(new RowData(ts, locoId, locoType, entry.getKey(), entry.getValue(), phase));
        }

        if (buffer.size() >= batchSize) {
            flush();
        }
    }

    @Scheduled(fixedDelayString = "${processor.batch.flush-interval-ms:500}")
    public void scheduledFlush() {
        if (!buffer.isEmpty()) flush();
    }

    public synchronized void flush() {
        if (buffer.isEmpty()) return;

        List<RowData> batch = new ArrayList<>();
        RowData row;
        while ((row = buffer.poll()) != null) batch.add(row);

        flushDuration.record(() -> {
            try (Connection conn = dataSource.getConnection();
                 PreparedStatement ps = conn.prepareStatement(INSERT_SQL)) {

                for (RowData r : batch) {
                    ps.setTimestamp(1, r.eventTime);
                    ps.setString(2, r.locomotiveId);
                    ps.setString(3, r.locomotiveType);
                    ps.setString(4, r.paramName);
                    ps.setDouble(5, r.value);
                    ps.setString(6, r.phase);
                    ps.addBatch();
                }

                ps.executeBatch();
                rowsWritten.increment(batch.size());
                log.debug("Flushed {} rows to ClickHouse", batch.size());

            } catch (Exception e) {
                flushErrors.increment();
                log.error("ClickHouse flush failed ({} rows lost): {}", batch.size(), e.getMessage());
            }
        });
    }

    public int bufferSize() {
        return buffer.size();
    }

    private record RowData(Timestamp eventTime, String locomotiveId, String locomotiveType,
                           String paramName, double value, String phase) {}
}
