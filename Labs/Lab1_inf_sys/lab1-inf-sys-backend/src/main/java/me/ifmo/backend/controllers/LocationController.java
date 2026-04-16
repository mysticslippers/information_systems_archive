package me.ifmo.backend.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.ifmo.backend.DTO.LocationDTO;
import me.ifmo.backend.services.LocationService;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/locations")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @GetMapping
    public ResponseEntity<List<LocationDTO>> getAllLocations() {
        return ResponseEntity.ok(locationService.getAllLocations());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LocationDTO> getLocationById(@PathVariable Long id) {
        return ResponseEntity.ok(locationService.getById(id));
    }

    @PostMapping
    public ResponseEntity<LocationDTO> createLocation(@Valid @RequestBody LocationDTO dto) {
        LocationDTO created = locationService.create(dto);
        return ResponseEntity.status(201).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<LocationDTO> updateLocation(@PathVariable Long id, @Valid @RequestBody LocationDTO dto) {
        return ResponseEntity.ok(locationService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteLocation(@PathVariable Long id) {
        try {
            locationService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException | DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "status", 400,
                    "message", "Cannot delete location: it is used in existing routes."
            ));
        }
    }

}
