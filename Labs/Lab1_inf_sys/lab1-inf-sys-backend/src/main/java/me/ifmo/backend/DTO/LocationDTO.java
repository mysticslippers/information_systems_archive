package me.ifmo.backend.DTO;

import lombok.*;

@Getter
@Setter
@ToString
@EqualsAndHashCode
@NoArgsConstructor
@AllArgsConstructor
public class LocationDTO {
    private Long id;
    private Long x;
    private Long y;
    private Double z;
}
