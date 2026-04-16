package me.ifmo.backend.exceptions;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Getter
@Builder
public class ApiErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private List<Map<String, String>> errors;
}
