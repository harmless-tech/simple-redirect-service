import * as LRU from "lru-cache";

const options: LRU.Options<any, any> = {
    maxSize: 10_000, // 1 mb
    sizeCalculation: (val, key) => {
        return new Blob([val, key]).size;
    },
    ttl: 1000 * 60 * 5, // 5 mins
    ttlResolution: 1000
};

export abstract class Cache {
    private static readonly cache = new LRU(options);

    public static set(key: string, val: string): void {
        this.cache.set(key, val);
    }

    public static has(key: string): boolean {
        return this.cache.has(key);
    }

    public static get?(key: string): string {
        return this.cache.get(key);
    }

    public static delete(key: string): boolean {
        return this.cache.delete(key);
    }
}
