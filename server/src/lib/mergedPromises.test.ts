import { mergedPromises } from "./mergedPromises";

const mockedPromises = (): {
    result: { timesCalled: number; resolved: boolean };
    fn: () => Promise<undefined>;
    resolve: () => undefined;
    promise: Promise<undefined>;
} => {
    const result = { timesCalled: 0, resolved: false, started: false };
    let resolve: () => undefined = () => {};

    const promise = new Promise<undefined>((resolver) => {
        resolve = () => {
            if (result.started) {
                resolver(undefined);
                result.resolved = true;
            }
        };
    });

    const fn = () => {
        result.timesCalled += 1;
        result.started = true;
        return promise;
    };

    return { result, fn, resolve, promise };
};

test("mergedPromises-one-request", async () => {
    const merge = mergedPromises(undefined);
    const callA = mockedPromises();
    merge(callA.fn);
    callA.resolve();
    await callA.promise;
    expect(callA.result.resolved).toBeTruthy();
    expect(callA.result.timesCalled).toBe(1);
});

test("mergedPromises-serial", async () => {
    const merge = mergedPromises(undefined);
    const callA = mockedPromises();
    const callB = mockedPromises();
    merge(callA.fn);
    callA.resolve();
    await callA.promise;
    expect(callA.result.resolved).toBeTruthy();
    merge(callB.fn);
    callB.resolve();
    await callB.promise;
    expect(callB.result.resolved).toBeTruthy();
    expect(callA.result.timesCalled).toBe(1);
    expect(callB.result.timesCalled).toBe(1);
});

test("mergedPromises-parallel", async () => {
    const merge = mergedPromises(undefined);
    const callA = mockedPromises();
    const callB = mockedPromises();
    merge(callA.fn);
    merge(callB.fn);
    callA.resolve();
    callB.resolve();
    expect(callA.result.timesCalled).toBe(1);
    expect(callB.result.timesCalled).toBe(0);
});
