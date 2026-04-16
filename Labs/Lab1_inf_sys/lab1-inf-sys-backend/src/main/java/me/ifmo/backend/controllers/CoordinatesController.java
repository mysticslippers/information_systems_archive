package me.ifmo.backend.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import me.ifmo.backend.DTO.CoordinatesDTO;
import me.ifmo.backend.services.CoordinatesService;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coordinates")
@RequiredArgsConstructor
public class CoordinatesController {

    private final CoordinatesService coordinatesService;

    @GetMapping
    public ResponseEntity<List<CoordinatesDTO>> getAllCoordinates() {
        return ResponseEntity.ok(coordinatesService.getAllCoordinates());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CoordinatesDTO> getCoordinatesById(@PathVariable Long id) {
        return ResponseEntity.ok(coordinatesService.getById(id));
    }

    @PostMapping
    public ResponseEntity<CoordinatesDTO> createCoordinates(@Valid @RequestBody CoordinatesDTO dto) {
        CoordinatesDTO created = coordinatesService.create(dto);
        return ResponseEntity.status(201).body(created);
    }


    @PutMapping("/{id}")
    public ResponseEntity<CoordinatesDTO> updateCoordinates(@PathVariable Long id, @Valid @RequestBody CoordinatesDTO dto) {
        return ResponseEntity.ok(coordinatesService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCoordinates(@PathVariable Long id) {
        try {
            coordinatesService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException | DataIntegrityViolationException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "status", 400,
                    "message", "Cannot delete coordinates: they are referenced by existing routes."
            ));
        }
    }

}
