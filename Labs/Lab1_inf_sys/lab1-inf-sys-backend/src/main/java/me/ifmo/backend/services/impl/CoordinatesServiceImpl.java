package me.ifmo.backend.services.impl;

import lombok.RequiredArgsConstructor;
import me.ifmo.backend.DTO.CoordinatesDTO;
import me.ifmo.backend.mappers.CoordinatesMapper;
import me.ifmo.backend.entities.Coordinates;
import me.ifmo.backend.repositories.CoordinatesRepository;
import me.ifmo.backend.repositories.RouteRepository;
import me.ifmo.backend.services.CoordinatesService;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityNotFoundException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CoordinatesServiceImpl implements CoordinatesService {

    private final CoordinatesRepository coordinatesRepository;
    private final RouteRepository routeRepository;
    private final CoordinatesMapper coordinatesMapper;
    private final SimpMessagingTemplate messagingTemplate;

    private static final String TOPIC = "/topic/coordinates";

    @Override
    @Transactional
    public CoordinatesDTO create(CoordinatesDTO dto) {
        validate(dto);
        Coordinates entity = coordinatesMapper.toEntity(dto);
        Coordinates saved = coordinatesRepository.save(entity);
        CoordinatesDTO res = coordinatesMapper.toDto(saved);

        messagingTemplate.convertAndSend(
                TOPIC,
                new WebSocketEvent("coordinates", "create", res)
        );

        return res;
    }

    @Override
    public List<CoordinatesDTO> getAllCoordinates() {
        return coordinatesRepository.findAll()
                .stream()
                .map(coordinatesMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public CoordinatesDTO getById(Long id) {
        Coordinates c = coordinatesRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Coordinates with id " + id + " not found"));
        return coordinatesMapper.toDto(c);
    }

    @Override
    @Transactional
    public CoordinatesDTO update(Long id, CoordinatesDTO dto) {
        validate(dto);
        Coordinates existing = coordinatesRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Coordinates with id " + id + " not found"));

        existing.setX(dto.getX());
        existing.setY(dto.getY());

        Coordinates saved = coordinatesRepository.save(existing);
        CoordinatesDTO res = coordinatesMapper.toDto(saved);

        messagingTemplate.convertAndSend(
                TOPIC,
                new WebSocketEvent("coordinates", "update", res)
        );

        return res;
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Coordinates existing = coordinatesRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Coordinates with id " + id + " not found"));

        boolean used = routeRepository.existsByCoordinates_Id(id);
        if (used) {
            throw new IllegalStateException("Cannot delete coordinates: they are used in some route");
        }

        coordinatesRepository.delete(existing);

        messagingTemplate.convertAndSend(
                TOPIC,
                new WebSocketEvent("coordinates", "delete", coordinatesMapper.toDto(existing))
        );
    }

    private void validate(CoordinatesDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Coordinates cannot be null");
        if (dto.getX() == null) throw new IllegalArgumentException("Coordinates.x cannot be null");
        if (dto.getY() == null) throw new IllegalArgumentException("Coordinates.y cannot be null");
        if (dto.getY() <= -976.0f) throw new IllegalArgumentException("Coordinates.y must be greater than -976");
    }
}
