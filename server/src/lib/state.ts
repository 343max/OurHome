export const sharedState = <T extends {}>(
    initialState: T,
    updated: (newState: T) => void,
) => {
    let state = initialState;

    return {
        get: () => state,
        update: (newState: Partial<T>) => {
            state = { ...state, ...newState };
            updated(state);
        },
    };
};
