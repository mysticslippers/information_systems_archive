package me.ifmo.backend.services.impl;

import lombok.RequiredArgsConstructor;
import me.ifmo.backend.DTO.RouteDTO;
import me.ifmo.backend.entities.Coordinates;
import me.ifmo.backend.entities.Location;
import me.ifmo.backend.mappers.CoordinatesMapper;
import me.ifmo.backend.mappers.LocationMapper;
import me.ifmo.backend.mappers.RouteMapper;
import me.ifmo.backend.entities.Route;
import me.ifmo.backend.repositories.CoordinatesRepository;
import me.ifmo.backend.repositories.LocationRepository;
import me.ifmo.backend.repositories.RouteRepository;
import me.ifmo.backend.services.RouteService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityNotFoundException;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RouteServiceImpl implements RouteService {

    private final RouteRepository routeRepository;
    private final RouteMapper routeMapper;
    private final CoordinatesMapper coordinatesMapper;
    private final LocationMapper locationMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final CoordinatesRepository coordinatesRepository;
    private final LocationRepository locationRepository;

    private static final String TOPIC = "/topic/routes";

    @Override
    @Transactional
    public RouteDTO create(RouteDTO dto) {
        Route route = new Route();

        if (dto.getCoordinates() != null && dto.getCoordinates().getId() != null) {
            Coordinates existing = coordinatesRepository.findById(dto.getCoordinates().getId())
                    .orElseThrow(() -> new EntityNotFoundException("Coordinates not found: " + dto.getCoordinates().getId()));
            route.setCoordinates(existing);
        } else {
            route.setCoordinates(coordinatesMapper.toEntity(dto.getCoordinates()));
        }

        if (dto.getFrom() != null && dto.getFrom().getId() != null) {
            Location existingFrom = locationRepository.findById(dto.getFrom().getId())
                    .orElseThrow(() -> new EntityNotFoundException("Location (from) not found: " + dto.getFrom().getId()));
            route.setFrom(existingFrom);
        } else {
            route.setFrom(locationMapper.toEntity(dto.getFrom()));
        }

        if (dto.getTo() != null && dto.getTo().getId() != null) {
            Location existingTo = locationRepository.findById(dto.getTo().getId())
                    .orElseThrow(() -> new EntityNotFoundException("Location (to) not found: " + dto.getTo().getId()));
            route.setTo(existingTo);
        } else {
            route.setTo(locationMapper.toEntity(dto.getTo()));
        }

        route.setName(dto.getName());
        route.setDistance(dto.getDistance());
        route.setRating(dto.getRating());
        route.setCreationDate(LocalDateTime.now());

        Route saved = routeRepository.save(route);
        RouteDTO res = routeMapper.toDto(saved);

        messagingTemplate.convertAndSend(
                TOPIC,
                new WebSocketEvent("route", "create", res)
        );

        return res;
    }

    @Override
    public Page<RouteDTO> getAllRoutes(Pageable pageable) {
        return routeRepository.findAll(pageable)
                .map(routeMapper::toDto);
    }

    @Override
    public RouteDTO getById(Long id) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Route with id " + id + " not found"));
        return routeMapper.toDto(route);
    }

    @Override
    @Transactional
    public RouteDTO update(Long id, RouteDTO dto) {
        Route route = routeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Route not found with id = " + id));

        if (dto.getCoordinates() != null) {
            if (dto.getCoordinates().getId() != null) {
                Coordinates existing = coordinatesRepository.findById(dto.getCoordinates().getId())
                        .orElseThrow(() -> new EntityNotFoundException("Coordinates not found: " + dto.getCoordinates().getId()));
                route.setCoordinates(existing);
            } else {
                route.setCoordinates(coordinatesMapper.toEntity(dto.getCoordinates()));
            }
        }

        if (dto.getFrom() != null) {
            if (dto.getFrom().getId() != null) {
                Location existingFrom = locationRepository.findById(dto.getFrom().getId())
                        .orElseThrow(() -> new EntityNotFoundException("Location (from) not found: " + dto.getFrom().getId()));
                route.setFrom(existingFrom);
            } else {
                route.setFrom(locationMapper.toEntity(dto.getFrom()));
            }
        }

        if (dto.getTo() != null) {
            if (dto.getTo().getId() != null) {
                Location existingTo = locationRepository.findById(dto.getTo().getId())
                        .orElseThrow(() -> new EntityNotFoundException("Location (to) not found: " + dto.getTo().getId()));
                route.setTo(existingTo);
            } else {
                route.setTo(locationMapper.toEntity(dto.getTo()));
            }
        }

        if (dto.getName() != null) route.setName(dto.getName());
        if (dto.getDistance() != null) route.setDistance(dto.getDistance());
        route.setRating(dto.getRating());

        Route saved = routeRepository.save(route);
        RouteDTO res = routeMapper.toDto(saved);

        messagingTemplate.convertAndSend(
                TOPIC,
                new WebSocketEvent("route", "update", res)
        );

        return res;
    }


    @Override
    @Transactional
    public void delete(Long id) {
        Route existing = routeRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Route with id " + id + " not found"));

        routeRepository.delete(existing);

        messagingTemplate.convertAndSend(TOPIC, new WebSocketEvent("route", "delete", routeMapper.toDto(existing)));
    }

    @Override
    public RouteDTO findMinDistance() {
        return routeRepository.findRouteWithMinDistance()
                .map(routeMapper::toDto)
                .orElseThrow(() -> new EntityNotFoundException("No routes found"));
    }

    @Override
    public Map<Double, Long> groupByRating() {
        return routeRepository.groupByRating().stream()
                .collect(Collectors.toMap(
                        arr -> (Double) arr[0],
                        arr -> (Long) arr[1]
                ));
    }

    @Override
    public List<Double> getUniqueRatings() {
        return routeRepository.findDistinctRatings();
    }

    @Override
    public List<RouteDTO> findRoutesBetween(Long fromId, Long toId, String sortBy) {
        List<Route> routes = routeRepository.findRoutesBetween(fromId, toId);

        Comparator<Route> comparator = switch (sortBy) {
            case "distance" -> Comparator.comparing(Route::getDistance, Comparator.nullsLast(Float::compareTo));
            case "rating" -> Comparator.comparing(Route::getRating);
            case "name" -> Comparator.comparing(Route::getName);
            default -> Comparator.comparing(Route::getId);
        };

        return routes.stream()
                .sorted(comparator)
                .map(routeMapper::toDto)
                .toList();
    }

    @Override
    @Transactional
    public RouteDTO addRouteBetween(Long fromId, Long toId, RouteDTO dto) {
        Location from = locationRepository.findById(fromId)
                .orElseThrow(() -> new EntityNotFoundException("From location not found: " + fromId));
        Location to = locationRepository.findById(toId)
                .orElseThrow(() -> new EntityNotFoundException("To location not found: " + toId));

        Route route = routeMapper.toEntity(dto);
        route.setFrom(from);
        route.setTo(to);

        Route saved = routeRepository.save(route);
        messagingTemplate.convertAndSend("/topic/routes",
                new WebSocketEvent("route", "create", routeMapper.toDto(saved)));

        return routeMapper.toDto(saved);
    }

}
