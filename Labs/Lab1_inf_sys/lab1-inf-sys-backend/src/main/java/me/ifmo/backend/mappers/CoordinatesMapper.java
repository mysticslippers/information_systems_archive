package me.ifmo.backend.mappers;

import me.ifmo.backend.DTO.CoordinatesDTO;
import me.ifmo.backend.entities.Coordinates;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface CoordinatesMapper {
    CoordinatesDTO toDto(Coordinates coordinates);
    Coordinates toEntity(CoordinatesDTO dto);
}
