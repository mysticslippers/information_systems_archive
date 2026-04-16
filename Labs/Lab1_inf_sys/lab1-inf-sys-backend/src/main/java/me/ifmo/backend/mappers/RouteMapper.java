package me.ifmo.backend.mappers;

import me.ifmo.backend.DTO.RouteDTO;
import me.ifmo.backend.entities.Route;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring", uses = {CoordinatesMapper.class, LocationMapper.class})
public interface RouteMapper {
    RouteDTO toDto(Route route);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "creationDate", ignore = true)
    Route toEntity(RouteDTO dto);
}
