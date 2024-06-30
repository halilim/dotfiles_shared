use terminal_colorsaurus::{color_scheme, ColorScheme, QueryOptions};

fn main() {
    match color_scheme(QueryOptions::default()).unwrap() {
        ColorScheme::Dark => {
            println!("dark")
        }
        ColorScheme::Light => {
            println!("light")
        }
    }
}
