expect 0 src/lib.rs ""

printf 'pub fn port(s: &str) -> u16 {\n    dbg!(s);\n    s.parse().unwrap()\n}\n' > src/bad.rs
echo 'pub mod bad;' >> src/lib.rs
expect 2 src/bad.rs "unwrap"
expect 2 src/bad.rs "dbg!"
blocks "unwrap"
rm src/bad.rs
cp "$fx/src/lib.rs" src/lib.rs

printf 'pub const  A:u8=1;\n' > src/fmt.rs
echo 'pub mod fmt;' >> src/lib.rs
formats src/fmt.rs "pub const A: u8 = 1;"
rm src/fmt.rs
cp "$fx/src/lib.rs" src/lib.rs

passes
