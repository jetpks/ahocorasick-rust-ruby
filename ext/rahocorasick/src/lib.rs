use aho_corasick::AhoCorasick;
use magnus::{method, function, prelude::*, Error, Ruby};

#[magnus::wrap(class = "AhoCorasickRust")]
pub struct AhoCorasickRust {
    words: Vec<String>,
    ac: AhoCorasick,
}

impl AhoCorasickRust {
    fn new(ruby: &Ruby, words: Vec<String>) -> Result<Self, Error> {
        let ac = AhoCorasick::new(&words)
            .map_err(|e| Error::new(ruby.exception_runtime_error(), format!("Failed to build automaton: {}", e)))?;
        Ok(Self { words, ac })
    }

    fn lookup(&self, haystack: String) -> Vec<String> {
        let mut matches = vec![];
        for mat in self.ac.find_iter(&haystack) {
            matches.push(self.words[mat.pattern()].clone());
        }
        matches
    }
}

#[magnus::init]
fn main(ruby: &Ruby) -> Result<(), Error> {
    let class = ruby.define_class("AhoCorasickRust", ruby.class_object())?;
    class.define_singleton_method("new", function!(AhoCorasickRust::new, 1))?;
    class.define_method("lookup", method!(AhoCorasickRust::lookup, 1))?;
    Ok(())
}
