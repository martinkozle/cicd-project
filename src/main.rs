extern crate env_logger;

use actix_web::{
    get,
    middleware::Logger,
    web::{self, Data},
    App, HttpServer, Responder,
};
use dotenvy::dotenv;
use serde::Serialize;
use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

pub struct AppState {
    db: Pool<Postgres>,
}

#[derive(Serialize)]
struct Variable {
    name: String,
    value: String,
}

#[get("/var/{name}")]
async fn var(state: Data<AppState>, name: web::Path<String>) -> impl Responder {
    match sqlx::query_as!(
        Variable,
        "SELECT name, value FROM variables WHERE name = $1",
        name.as_str()
    )
    .fetch_one(&state.db)
    .await
    {
        Ok(variable) => format!("{} = {}", variable.name, variable.value),
        Err(_) => format!("Variable {name} not found"),
    }
}

#[get("/var/{name}/{value}")]
async fn set_var(state: Data<AppState>, path: web::Path<(String, String)>) -> impl Responder {
    let (name, value) = path.into_inner();
    match sqlx::query!(
        "INSERT INTO variables (name, value) VALUES ($1, $2)
         ON CONFLICT (name) DO UPDATE SET value = $2",
        name,
        value
    )
    .execute(&state.db)
    .await
    {
        Ok(_) => format!("{name} = {value}"),
        Err(_) => format!("Failed to set variable {name} to {value}"),
    }
}

#[actix_web::main] // or #[tokio::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    std::env::set_var("RUST_LOG", "actix_web=debug");
    env_logger::init();
    let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .expect("Failed to connect to Postgres");

    HttpServer::new(move || {
        App::new()
            .app_data(Data::new(AppState { db: pool.clone() }))
            .wrap(Logger::default())
            .service(var)
            .service(set_var)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
