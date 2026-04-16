package me.ifmo.backend.entities;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Objects;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "coordinates")
public class Coordinates {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "X must not be null")
    @Column(nullable = false)
    private Double x;

    @DecimalMin(value = "-976", inclusive = false, message = "Y must be > -976")
    @Column(nullable = false)
    private Float y;

    @Override
    public String toString() {
        return "Coordinates{" +
                "id=" + id +
                ", x=" + x +
                ", y=" + y +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Coordinates coordinates)) return false;
        return Objects.equals(id, coordinates.id);
    }

    @Override
    public int hashCode() {
        return id != null ? id.hashCode() : Objects.hash(x, y);
    }
}
