import { Hono } from "hono";
import fileRedirects from "./redirect-file";
import utils from "../utils";
import { RedirectStore } from "../database";

const app = new Hono();

app.get("/:id", (c) => {
    const { id } = c.req.param();
    if(id.length > utils.MAX_ID_SIZE)
        return c.text("Improper Redirect Link", utils.STATUS_BAD_REQUEST);

    // Check if there is a redirect that matches.
    if(fileRedirects.has(id)) {
        RedirectStore.incrementRedirect(id);
        return c.redirect(fileRedirects.get(id), utils.STATUS_FOUND);
    }

    return c.text("No Redirect Found", utils.STATUS_NOT_FOUND);
});

export default app;
