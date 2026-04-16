package me.ifmo.backend.services.impl;

import lombok.Getter;
import lombok.ToString;
import lombok.AllArgsConstructor;

@Getter
@ToString
@AllArgsConstructor
public class WebSocketEvent {
    private final String entity;
    private final String action;
    private final Object data;
}
