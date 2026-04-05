package kz.ktj.digitaltwin.processor.listener;

import kz.ktj.digitaltwin.processor.dto.TelemetryEnvelope;
import kz.ktj.digitaltwin.processor.service.ProcessingPipeline;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class TelemetryListener {

    private static final Logger log = LoggerFactory.getLogger(TelemetryListener.class);

    private final ProcessingPipeline pipeline;

    public TelemetryListener(ProcessingPipeline pipeline) {
        this.pipeline = pipeline;
    }

    @RabbitListener(queues = "${rabbitmq.queue.processor}")
    public void onMessage(TelemetryEnvelope envelope) {
        if (envelope == null || envelope.getLocomotiveId() == null) {
            log.warn("Received null or invalid envelope, skipping");
            return;
        }

        log.trace("Received [{}] from queue", envelope.getMessageId());
        pipeline.process(envelope);
    }
}
