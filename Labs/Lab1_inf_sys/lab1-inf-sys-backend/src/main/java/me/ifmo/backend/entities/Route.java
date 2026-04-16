package me.ifmo.backend.entities;


import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.Objects;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "routes")
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name must not be blank")
    @Column(nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false, cascade = CascadeType.PERSIST)
    @JoinColumn(name = "coordinates_id", nullable = false)
    private Coordinates coordinates;

    @Column(name = "creation_date", updatable = false)
    private LocalDateTime creationDate;

    @ManyToOne(fetch = FetchType.LAZY, optional = false, cascade = CascadeType.PERSIST)
    @JoinColumn(name = "from_location_id", nullable = false)
    private Location from;

    @ManyToOne(fetch = FetchType.LAZY, optional = false, cascade = CascadeType.PERSIST)
    @JoinColumn(name = "to_location_id", nullable = false)
    private Location to;

    @NotNull
    @DecimalMin(value = "1", inclusive = false, message = "Distance must be > 1")
    @Column(name = "distance", nullable = false)
    private Float distance;

    @NotNull
    @DecimalMin(value = "0", inclusive = false, message = "Rating must be > 0")
    @Column(nullable = false)
    private Double rating;

    @PrePersist
    protected void onCreate() {
        this.creationDate = LocalDateTime.now();
    }

    @Override
    public String toString() {
        return "Route{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", coordinatesId=" + (coordinates != null ? coordinates.getId() : null) +
                ", creationDate=" + creationDate +
                ", fromId=" + (from != null ? from.getId() : null) +
                ", toId=" + (to != null ? to.getId() : null) +
                ", distance=" + distance +
                ", rating=" + rating +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Route route)) return false;
        return id != null ? id.equals(route.id) :
                Objects.equals(name, route.name) &&
                        Objects.equals(creationDate, route.creationDate);
    }

    @Override
    public int hashCode() {
        return id != null ? id.hashCode() : Objects.hash(name, creationDate);
    }
}
