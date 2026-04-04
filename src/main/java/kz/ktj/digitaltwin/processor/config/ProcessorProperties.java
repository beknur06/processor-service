package kz.ktj.digitaltwin.processor.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "processor")
public class ProcessorProperties {

    private EmaConfig ema = new EmaConfig();
    private BatchConfig batch = new BatchConfig();

    @Data
    public static class EmaConfig {
        /**
         * EMA alpha (0..1). Чем выше — тем больше вес нового значения.
         * 0.3 = хорошо сглаживает шум, но не слишком отстаёт.
         */
        private double alpha = 0.3;
        private boolean enabled = true;
    }

    @Data
    public static class BatchConfig {
        /** Размер батча перед flush в ClickHouse */
        private int size = 100;
        /** Максимальный интервал между flush-ами (мс) */
        private int flushIntervalMs = 500;
    }
}
