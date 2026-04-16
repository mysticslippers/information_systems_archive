package me.ifmo.backend.services.impl;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WebSocketEvent {
    private String entity;
    private String action;
    private Object data;
}
