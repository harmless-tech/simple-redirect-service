#![forbid(unsafe_code)]
#![allow(clippy::multiple_crate_versions)]

use axum::{
    extract::{Path, Request, State},
    http::StatusCode,
    response::{IntoResponse, Redirect, Response},
    routing::get,
    Json, Router, ServiceExt,
};
use indexmap::IndexMap;
use serde::Deserialize;
use serde_json::{json, Value};
use std::{
    fs,
    sync::{Arc, OnceLock},
};
use tokio::signal;
use tower::Layer;
use tower_http::{normalize_path::NormalizePathLayer, trace, trace::TraceLayer};
use tracing::{debug, info, trace, Level};
use url::Url;

#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

#[derive(Debug, Deserialize)]
struct Redirects {
    redirects: IndexMap<String, String>,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_max_level(Level::TRACE)
        .with_target(false)
        .compact()
        .init();

    info!("Starting...");

    info!("Loading redirects from ./redirects.json...");
    let file = fs::read_to_string("./redirects.json")?;
    let redirects: Redirects = serde_json::from_str(&file)?;
    debug!("Found: {redirects:?}");

    debug!("Validating URLs...");
    for (k, v) in &redirects.redirects {
        trace!("Validating URL {k} : {v}");
        Url::parse(v)?;
    }
    debug!("Validated URLs.");

    let app = Router::new()
        .route("/", get(srs_info))
        .route("/srs", get(srs_src))
        .route("/srs/license", get(srs_license))
        .route("/:path", get(redirect))
        .fallback(h_404)
        .with_state(Arc::new(redirects));

    let app = app.layer(
        TraceLayer::new_for_http()
            .make_span_with(trace::DefaultMakeSpan::new().level(Level::INFO))
            .on_request(trace::DefaultOnRequest::new().level(Level::INFO))
            .on_response(trace::DefaultOnResponse::new().level(Level::INFO))
            .on_failure(trace::DefaultOnFailure::new().level(Level::ERROR)),
    );
    let app = NormalizePathLayer::trim_trailing_slash().layer(app);

    let listener = tokio::net::TcpListener::bind(":::3000").await?;
    info!("Should be listening soon! On port 3000");
    axum::serve(listener, ServiceExt::<Request>::into_make_service(app))
        .with_graceful_shutdown(shutdown_handle())
        .await?;

    Ok(())
}

async fn shutdown_handle() {
    let ctrl_c = async { signal::ctrl_c().await.expect("Could not hook ctrl-c.") };

    #[cfg(unix)]
    let term = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("Could not hook signal.")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let term = std::future::pending::<()>();

    tokio::select! {
        () = ctrl_c => {},
        () = term => {},
    }
}

async fn srs_info() -> Json<Value> {
    static INFO: OnceLock<Json<Value>> = OnceLock::new();
    INFO.get_or_init(|| {
        Json(json!({
            "name": "Simple Redirect Service",
            "id": "simple-redirect-service",
            "version": env!("CARGO_PKG_VERSION"),
            "desc": "A simple redirect service.",
            "authors": ["harmless-tech"],
            "license": "/srs/license",
            "git": "https://github.com/harmless-tech/simple-redirect-service",
            "issues": "https://github.com/harmless-tech/simple-redirect-service/issues"
        }))
    })
    .clone()
}

async fn srs_src() -> Redirect {
    Redirect::temporary("https://github.com/harmless-tech/simple-redirect-service")
}

async fn srs_license() -> &'static str {
    static STR: &str = include_str!("../LICENSE");
    STR
}

async fn h_404() -> impl IntoResponse {
    (StatusCode::NOT_FOUND, "Invalid URL.")
}

enum Returns {
    ErrorC(StatusCode, String),
    Redirect(Redirect),
}
impl IntoResponse for Returns {
    fn into_response(self) -> Response {
        match self {
            Self::ErrorC(a, b) => (a, b).into_response(),
            Self::Redirect(a) => a.into_response(),
        }
    }
}

async fn redirect(Path(path): Path<String>, State(redirects): State<Arc<Redirects>>) -> Returns {
    if path.len() > 128 {
        return Returns::ErrorC(
            StatusCode::URI_TOO_LONG,
            "Redirect link was too long!".to_string(),
        );
    }

    match redirects.redirects.get(&path) {
        Some(url) => Returns::Redirect(Redirect::temporary(url)),
        None => Returns::ErrorC(StatusCode::NOT_FOUND, String::from("Unknown redirect.")),
    }
}
