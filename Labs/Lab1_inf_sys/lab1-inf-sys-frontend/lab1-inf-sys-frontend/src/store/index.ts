import { configureStore } from '@reduxjs/toolkit';
import routesReducer from './routesSlice';
import locationsReducer from './locationsSlice';
import coordinatesReducer from './coordinatesSlice';

export const store = configureStore({
    reducer: {
        routes: routesReducer,
        locations: locationsReducer,
        coordinates: coordinatesReducer,
    },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
