use aho_corasick::{AhoCorasick, AhoCorasickBuilder, MatchKind};
use magnus::{method, function, prelude::*, Error, Ruby, RHash, RArray, Value, Symbol};

#[magnus::wrap(class = "AhoCorasickRust")]
pub struct AhoCorasickRust {
    words: Vec<String>,
    ac: AhoCorasick,
}

impl AhoCorasickRust {
    fn new_impl(ruby: &Ruby, words: Vec<String>, kwargs: Option<RHash>) -> Result<Self, Error> {
        let mut builder = AhoCorasickBuilder::new();

        // Check for options if kwargs provided
        if let Some(kwargs) = kwargs {
            // case_insensitive option
            if let Some(val) = kwargs.get(ruby.to_symbol("case_insensitive")) {
                if let Ok(case_insensitive) = bool::try_convert(val) {
                    if case_insensitive {
                        builder.ascii_case_insensitive(true);
                    }
                }
            }

            // match_kind option
            if let Some(val) = kwargs.get(ruby.to_symbol("match_kind")) {
                if let Some(sym) = Symbol::from_value(val) {
                    let kind_str = sym.name()?.to_string();
                    let match_kind = match kind_str.as_ref() {
                        "standard" => MatchKind::Standard,
                        "leftmost_first" => MatchKind::LeftmostFirst,
                        "leftmost_longest" => MatchKind::LeftmostLongest,
                        _ => {
                            return Err(Error::new(
                                ruby.exception_arg_error(),
                                format!("Invalid match_kind: '{}'. Valid values are :standard, :leftmost_first, :leftmost_longest", kind_str)
                            ));
                        }
                    };
                    builder.match_kind(match_kind);
                }
            }
        }

        let ac = builder.build(&words)
            .map_err(|e| Error::new(ruby.exception_runtime_error(), format!("Failed to build automaton: {}", e)))?;
        Ok(Self { words, ac })
    }

    fn new(ruby: &Ruby, args: &[Value]) -> Result<Self, Error> {
        let args = magnus::scan_args::scan_args::<(Vec<String>,), (), (), (), RHash, ()>(args)?;
        let (words,) = args.required;
        let kwargs = args.keywords;

        // Only pass kwargs if non-empty
        let kwargs_opt = if kwargs.len() > 0 { Some(kwargs) } else { None };

        Self::new_impl(ruby, words, kwargs_opt)
    }

    fn lookup(&self, haystack: String) -> Vec<String> {
        let mut matches = vec![];
        for mat in self.ac.find_iter(&haystack) {
            matches.push(self.words[mat.pattern()].clone());
        }
        matches
    }

    fn is_match(&self, haystack: String) -> bool {
        self.ac.is_match(&haystack)
    }

    fn lookup_overlapping(&self, haystack: String) -> Vec<String> {
        let mut matches = vec![];
        for mat in self.ac.find_overlapping_iter(&haystack) {
            matches.push(self.words[mat.pattern()].clone());
        }
        matches
    }

    fn find_first(&self, haystack: String) -> Option<String> {
        self.ac.find(&haystack).map(|mat| self.words[mat.pattern()].clone())
    }

    fn find_first_with_position(&self, haystack: String) -> Result<Option<RHash>, Error> {
        let ruby = Ruby::get().unwrap();
        if let Some(mat) = self.ac.find(&haystack) {
            let hash = ruby.hash_new();
            hash.aset(ruby.to_symbol("pattern"), self.words[mat.pattern()].clone())?;
            hash.aset(ruby.to_symbol("start"), mat.start())?;
            hash.aset(ruby.to_symbol("end"), mat.end())?;
            Ok(Some(hash))
        } else {
            Ok(None)
        }
    }

    fn lookup_with_positions(&self, haystack: String) -> Result<RArray, Error> {
        let ruby = Ruby::get().unwrap();
        let matches = ruby.ary_new();
        for mat in self.ac.find_iter(&haystack) {
            let hash = ruby.hash_new();
            hash.aset(ruby.to_symbol("pattern"), self.words[mat.pattern()].clone())?;
            hash.aset(ruby.to_symbol("start"), mat.start())?;
            hash.aset(ruby.to_symbol("end"), mat.end())?;
            matches.push(hash)?;
        }
        Ok(matches)
    }

    fn replace_all(&self, args: &[Value]) -> Result<String, Error> {
        let ruby = Ruby::get().unwrap();

        // Parse arguments: haystack (required), replacements (optional if block given)
        let haystack: String = if args.is_empty() {
            return Err(Error::new(
                ruby.exception_arg_error(),
                "wrong number of arguments (given 0, expected 1..2)"
            ));
        } else {
            String::try_convert(args[0])?
        };

        // Check if a block was given
        match ruby.block_proc() {
            Ok(proc) => {
                // Block-based replacement
                let mut result = haystack.clone();
                let mut offset: isize = 0;

                for mat in self.ac.find_iter(&haystack) {
                    let pattern = &self.words[mat.pattern()];
                    let replacement: String = proc.call((pattern.clone(),))?;

                    let start = (mat.start() as isize + offset) as usize;
                    let end = (mat.end() as isize + offset) as usize;

                    result.replace_range(start..end, &replacement);
                    offset += replacement.len() as isize - (mat.end() - mat.start()) as isize;
                }

                Ok(result)
            }
            Err(_) if args.len() >= 2 => {
                // Hash-based replacement
                if let Some(hash) = RHash::from_value(args[1]) {
                    let mut replace_with: Vec<String> = Vec::with_capacity(self.words.len());

                    for word in &self.words {
                        if let Some(val) = hash.get(word.clone()) {
                            if let Ok(replacement) = String::try_convert(val) {
                                replace_with.push(replacement);
                            } else {
                                replace_with.push(word.clone());
                            }
                        } else {
                            replace_with.push(word.clone());
                        }
                    }

                    Ok(self.ac.replace_all(&haystack, &replace_with))
                } else {
                    Err(Error::new(
                        ruby.exception_arg_error(),
                        "replace_all requires a Hash or block"
                    ))
                }
            }
            Err(_) => {
                Err(Error::new(
                    ruby.exception_arg_error(),
                    "replace_all requires a Hash or block"
                ))
            }
        }
    }
}

#[magnus::init]
fn main(ruby: &Ruby) -> Result<(), Error> {
    let class = ruby.define_class("AhoCorasickRust", ruby.class_object())?;
    class.define_singleton_method("new", function!(AhoCorasickRust::new, -1))?;
    class.define_method("lookup", method!(AhoCorasickRust::lookup, 1))?;
    class.define_method("match?", method!(AhoCorasickRust::is_match, 1))?;
    class.define_method("lookup_overlapping", method!(AhoCorasickRust::lookup_overlapping, 1))?;
    class.define_method("find_first", method!(AhoCorasickRust::find_first, 1))?;
    class.define_method("find_first_with_position", method!(AhoCorasickRust::find_first_with_position, 1))?;
    class.define_method("lookup_with_positions", method!(AhoCorasickRust::lookup_with_positions, 1))?;
    class.define_method("replace_all", method!(AhoCorasickRust::replace_all, -1))?;
    Ok(())
}
