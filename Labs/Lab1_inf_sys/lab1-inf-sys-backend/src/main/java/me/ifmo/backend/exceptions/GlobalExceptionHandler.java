package me.ifmo.backend.exceptions;

import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    private final SimpMessagingTemplate messagingTemplate;

    private void sendErrorToWebSocket(ApiErrorResponse response) {
        try {
            messagingTemplate.convertAndSend("/topic/errors", response);
        } catch (Exception exception) {
            log.warn("Не удалось отправить ошибку через WebSocket: {}", exception.getMessage());
        }
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ApiErrorResponse> handleEntityNotFound(EntityNotFoundException exception) {
        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(404)
                .error("Not Found")
                .message(exception.getMessage())
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @ExceptionHandler({IllegalArgumentException.class, IllegalStateException.class})
    public ResponseEntity<ApiErrorResponse> handleBadRequest(RuntimeException exception) {
        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Bad Request")
                .message(exception.getMessage())
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException exception) {
        var errors = exception.getBindingResult().getFieldErrors().stream()
                .map(err -> Map.of("field", err.getField(), "message", Objects.requireNonNull(err.getDefaultMessage())))
                .collect(Collectors.toList());

        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Validation Failed")
                .errors(errors)
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleConstraintViolation(ConstraintViolationException ex) {
        var errors = ex.getConstraintViolations().stream()
                .map(v -> Map.of("field", v.getPropertyPath().toString(), "message", v.getMessage()))
                .toList();

        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Validation Failed")
                .errors(errors)
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiErrorResponse> handleDataIntegrityViolation(DataIntegrityViolationException exception) {
        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(400)
                .error("Data Integrity Violation")
                .message(exception.getMessage())
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleGeneral(Exception exception) {
        log.error("Unhandled exception: ", exception);

        var response = ApiErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .status(500)
                .error("Internal Server Error")
                .message(exception.getMessage())
                .build();

        sendErrorToWebSocket(response);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
}
