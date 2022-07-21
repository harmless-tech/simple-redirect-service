import { Database, SQLQueryBindings, Statement } from "bun:sqlite";
import { Cache } from "./cache";

function createTableQuery(table: string, cols: string): string {
    return `CREATE TABLE IF NOT EXISTS ${table} (${cols})`;
}

abstract class Store {
    private static readonly db = new Database("srs-data.sqlite", { readwrite: true, create: true });

    public static run(query: string, bindings?: SQLQueryBindings): void {
        if(bindings)
            this.db.run(query, bindings);
        else
            this.db.run(query);
    }

    public static query(query: string): Statement {
        return this.db.query(query);
    }

    public static close(): void {
        this.db.close();
    }
}

export abstract class RedirectStore {
    private static readonly TABLE_STATS = "t_redirects_stats";

    private static statCmdQueue: string[] = []; //TODO Should this move to a better system where a reduced amount of calls are needed?
    private static statQuery: Statement;

    public static init() {
        Store.run(createTableQuery(this.TABLE_STATS, "id INTEGER PRIMARY KEY AUTOINCREMENT, r_key TEXT UNIQUE NOT NULL, r_amount INTEGER"));
        this.statQuery = Store.query(`SELECT t.r_amount FROM ${this.TABLE_STATS} t where r_key=?`);

        // Stats are not pushed live. (Pushed every 30 secs)
        setInterval(() => {
            let q;
            while(q = this.statCmdQueue.pop())
                Store.run(q);
        }, 30_000);
    }

    public static incrementRedirect(id: string) {
        this.statCmdQueue.push(`INSERT OR IGNORE INTO ${this.TABLE_STATS} (r_key, r_amount) VALUES ('${id}', 1)`)
        this.statCmdQueue.push(`UPDATE ${this.TABLE_STATS} SET r_amount=r_amount + 1 WHERE r_key='${id}'`)
    }
    
    public static getRedirectStat(id: string): number {
        // Check cache
        if(Cache.has(id))
            return +Cache.get(id);
            
        // Pull from db
        let data = this.statQuery.get(id);
        if(data && data.r_amount) {
            Cache.set(id, `${data.r_amount}`);
            return data.r_amount;
        }
        
        Cache.set(id, `${0}`);
        return 0;
    }
}
