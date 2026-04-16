package me.ifmo.backend.DTO;

import lombok.*;

@Getter
@Setter
@ToString
@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
public class CoordinatesDTO {
    private Long id;
    private Double x;
    private Float y;
}
