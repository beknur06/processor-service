package kz.ktj.digitaltwin.processor.controller;

import kz.ktj.digitaltwin.processor.service.ClickHouseWriter;
import kz.ktj.digitaltwin.processor.service.EmaService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Debug/monitoring endpoints для processor-service.
 */
@RestController
@RequestMapping("/api/processor")
public class ProcessorController {

    private final EmaService emaService;
    private final ClickHouseWriter clickHouseWriter;

    public ProcessorController(EmaService emaService, ClickHouseWriter clickHouseWriter) {
        this.emaService = emaService;
        this.clickHouseWriter = clickHouseWriter;
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status() {
        return ResponseEntity.ok(Map.of(
            "emaStateEntries", emaService.stateSize(),
            "clickhouseBufferSize", clickHouseWriter.bufferSize()
        ));
    }

    /**
     * Принудительный flush буфера в ClickHouse.
     */
    @PostMapping("/flush")
    public ResponseEntity<String> flush() {
        clickHouseWriter.flush();
        return ResponseEntity.ok("Flushed");
    }
}
