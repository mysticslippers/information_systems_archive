package me.ifmo.backend.DTO;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
public class RouteDTO {
    private Long id;

    @NotBlank(message = "Route.name cannot be null or blank")
    private String name;

    @NotNull(message = "Route.coordinates cannot be null")
    private CoordinatesDTO coordinates;

    @NotNull(message = "Route.from cannot be null")
    private LocationDTO from;

    @NotNull(message = "Route.to cannot be null")
    private LocationDTO to;

    @DecimalMin(value = "1.0", inclusive = false, message = "Route.distance must be greater than 1 if present")
    private Float distance;

    @Positive(message = "Route.rating must be greater than 0")
    private Double rating;

    private LocalDateTime creationDate;
}
