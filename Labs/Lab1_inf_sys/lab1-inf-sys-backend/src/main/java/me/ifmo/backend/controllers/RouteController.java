package me.ifmo.backend.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.ifmo.backend.DTO.RouteDTO;
import me.ifmo.backend.services.RouteService;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    @GetMapping
    public ResponseEntity<Page<RouteDTO>> getAllRoutes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(routeService.getAllRoutes(PageRequest.of(page, size)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<RouteDTO> getRouteById(@PathVariable Long id) {
        return ResponseEntity.ok(routeService.getById(id));
    }

    @PostMapping
    public ResponseEntity<RouteDTO> createRoute(@Valid @RequestBody RouteDTO dto) {
        RouteDTO created = routeService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }


    @PutMapping("/{id}")
    public ResponseEntity<RouteDTO> updateRoute(@PathVariable Long id, @Valid @RequestBody RouteDTO dto) {
        return ResponseEntity.ok(routeService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRoute(@PathVariable Long id) {
        try {
            routeService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException | DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "status", 400,
                    "message", "Cannot delete route: it is linked to existing objects."
            ));
        }
    }


    @GetMapping("/min-distance")
    public ResponseEntity<RouteDTO> getMinDistanceRoute() {
        return ResponseEntity.ok(routeService.findMinDistance());
    }

    @GetMapping("/group-by-rating")
    public ResponseEntity<Map<Double, Long>> groupByRating() {
        return ResponseEntity.ok(routeService.groupByRating());
    }

    @GetMapping("/unique-ratings")
    public ResponseEntity<List<Double>> getUniqueRatings() {
        return ResponseEntity.ok(routeService.getUniqueRatings());
    }

    @GetMapping("/between")
    public ResponseEntity<List<RouteDTO>> findRoutesBetween(
            @RequestParam Long fromId,
            @RequestParam Long toId,
            @RequestParam(defaultValue = "id") String sortBy) {
        return ResponseEntity.ok(routeService.findRoutesBetween(fromId, toId, sortBy));
    }

    @PostMapping("/between")
    public ResponseEntity<RouteDTO> addRouteBetween(
            @RequestParam Long fromId,
            @RequestParam Long toId,
            @Valid @RequestBody RouteDTO dto) {
        RouteDTO created = routeService.addRouteBetween(fromId, toId, dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }


}
