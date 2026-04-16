package me.ifmo.backend.mappers;

import me.ifmo.backend.DTO.LocationDTO;
import me.ifmo.backend.entities.Location;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface LocationMapper {
    LocationDTO toDto(Location location);
    Location toEntity(LocationDTO dto);
}
