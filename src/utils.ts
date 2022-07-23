import { StatusCode } from "hono/dist/utils/http-status";

// Status Codes (https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
const STATUS_OKAY: StatusCode = 200;
const STATUS_MULTIPLE_CHOICES: StatusCode = 300;
const STATUS_MOVE_PERMANENTLY: StatusCode = 301;
const STATUS_FOUND: StatusCode = 302;
const STATUS_BAD_REQUEST: StatusCode = 400;
const STATUS_UNAUTHORIZED: StatusCode = 401;
const STATUS_PAYMENT_REQUIRED: StatusCode = 402;
const STATUS_FORBIDDEN: StatusCode = 403;
const STATUS_NOT_FOUND: StatusCode = 404;
const STATUS_TEAPOT: StatusCode = 418;
const STATUS_INTERNAL_SERVER_ERROR: StatusCode = 500;

const MAX_ID_SIZE = 20;

export default {
    STATUS_OKAY,
    STATUS_MULTIPLE_CHOICES,
    STATUS_MOVE_PERMANENTLY,
    STATUS_FOUND,
    STATUS_BAD_REQUEST,
    STATUS_UNAUTHORIZED,
    STATUS_PAYMENT_REQUIRED,
    STATUS_FORBIDDEN,
    STATUS_NOT_FOUND,
    STATUS_TEAPOT,
    STATUS_INTERNAL_SERVER_ERROR,

    MAX_ID_SIZE
}
