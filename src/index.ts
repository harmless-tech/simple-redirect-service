import { Hono } from "hono";
import { RegExpRouter } from "hono/router/reg-exp-router";
import { logger } from "hono/logger";
import redirect from "./redirect/redirect";
import stats from "./redirect/stats";
import { RedirectStore } from "./database";

const app = new Hono({ router: new RegExpRouter() });
const port = process.env.PORT || 3000;

const LICENSE_FILE = await Bun.file("LICENSE").text();

// DB Init
RedirectStore.init();

// Home
app.use('*', logger());
app.get("/", (c) => c.json({
    name: "Simple Redirect Service",
    id: "simple-redirect-service",
    version: "0.0.1",
    desc: "A simple redirect service with a stat counter. Built using Bun and Hono.",
    author: "harmless-tech",
    license: "/license",
    git: "https://github.com/harmless-tech/simple-redirect-service",
    issues: "https://github.com/harmless-tech/simple-redirect-service/issues"
}));
app.get("/license", (c) => c.text(LICENSE_FILE));
app.notFound((c) => c.text("Not Found", 404));
app.onError((err, c) => {
    console.error(err);
    return c.text("Internal Server Error", 500);
});

// Routes
app.route("/", redirect);
app.route("/", stats);

// Start
console.log(`Running at http://localhost:${port}`);
export default {
    port: process.env.PORT || 3000,
    fetch: app.fetch,
};
