import { Hono } from "hono";
import fileRedirects from "./redirect-file";
import utils from "../utils";
import { RedirectStore } from "../database";

const app = new Hono();

app.get("/:id/stats", (c) => {
    const { id } = c.req.param();
    if(id.length > utils.MAX_ID_SIZE)
        return c.text("Improper Redirect Link", utils.STATUS_BAD_REQUEST);

    // Check if there is a redirect that matches.
    if(fileRedirects.has(id)) {
        let amount = RedirectStore.getRedirectStat(id);
        return c.text(`${amount}`, utils.STATUS_OKAY);
    }

    return c.text("No Redirect Found", utils.STATUS_NOT_FOUND);
});

export default app;
