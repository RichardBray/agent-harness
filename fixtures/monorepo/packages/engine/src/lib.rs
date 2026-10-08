#[must_use]
pub fn parse_port(s: &str) -> Option<u16> {
    s.parse().ok()
}
