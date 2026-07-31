-- names.lua
-- Human-readable name/email generator built from online wordlists.
--   adjectives: github.com/hugsy english-adjectives (curated)
--   animals   : gist raineorshine 446 animals (curated)

local M = {}
    M.adjectives = {
        "abandoned", "able", "absolute", "adorable", "academic", "acclaimed", "accurate", "aching", "acidic", "acrobatic", "active", "actual",
        "adept", "admirable", "admired", "adored", "advanced", "afraid", "aged", "agile", "agitated", "agonizing", "agreeable", "ajar",
        "alarmed", "alarming", "alert", "alienated", "alive", "all", "amazing", "ambitious", "ample", "amused", "amusing", "anchored",
        "ancient", "angelic", "angry", "anguished", "animated", "annual", "another", "antique", "anxious", "any", "apt", "arctic",
        "arid", "aromatic", "artistic", "ashamed", "assured", "athletic", "attached", "attentive", "austere", "authentic", "automatic", "average",
        "aware", "awesome", "awful", "awkward", "babyish", "bad", "back", "baggy", "bare", "barren", "basic", "beautiful",
        "belated", "beloved", "better", "best", "bewitched", "big", "bitter", "black", "bland", "blank", "blaring", "bleak",
        "blind", "blissful", "blond", "blue", "blushing", "bogus", "boiling", "bold", "bony", "boring", "bossy", "both",
        "bouncy", "bountiful", "bowed", "brave", "breakable", "brief", "bright", "brilliant", "brisk", "broken", "bronze", "brown",
        "bruised", "bubbly", "bulky", "bumpy", "buoyant", "burly", "bustling", "busy", "buttery", "buzzing", "calm", "candid",
        "canine", "capital", "carefree", "careful", "careless", "caring", "cautious", "cavernous", "charming", "cheap", "cheerful", "cheery",
        "chief", "chilly", "chubby", "circular", "classic", "clean", "clear", "clever", "close", "closed", "cloudy", "clueless",
        "clumsy", "cluttered", "coarse", "cold", "colorful", "colorless",
    }

    M.animals = {
        "aardvark", "aardwolf", "albatross", "alligator", "alpaca", "amphibian", "anaconda", "angelfish", "anglerfish", "ant", "anteater", "antelope",
        "antlion", "ape", "aphid", "armadillo", "asp", "baboon", "badger", "bandicoot", "barnacle", "barracuda", "basilisk", "bass",
        "bat", "bear", "beaver", "bedbug", "bee", "beetle", "bird", "bison", "blackbird", "boa", "boar", "bobcat",
        "bobolink", "bonobo", "bovid", "buffalo", "bug", "butterfly", "buzzard", "camel", "canary", "canid", "canidae", "capybara",
        "cardinal", "caribou", "carp", "cat", "caterpillar", "catfish", "catshark", "cattle", "centipede", "cephalopod", "chameleon", "cheetah",
        "chickadee", "chicken", "chimpanzee", "chinchilla", "chipmunk", "cicada", "clam", "clownfish", "cobra", "cockroach", "cod", "condor",
        "constrictor", "coral", "cougar", "cow", "coyote", "crab", "crane", "crawdad", "crayfish", "cricket", "crocodile", "crow",
        "cuckoo", "damselfly", "deer", "dingo", "dinosaur", "dog", "dolphin", "donkey", "dormouse", "dove", "dragon", "dragonfly",
        "duck", "eagle", "earthworm", "earwig", "echidna", "eel", "egret", "elephant", "elk", "emu", "ermine", "falcon",
        "felidae", "ferret", "finch", "firefly", "fish", "flamingo", "flea", "fly", "flyingfish", "fowl", "fox", "frog",
        "galliform", "gamefowl", "gayal", "gazelle", "gecko", "gerbil", "gibbon", "giraffe", "goat", "goldfish", "goose", "gopher",
        "gorilla", "grasshopper", "grouse", "guan", "guanaco", "guineafowl", "gull", "guppy", "haddock", "halibut", "hamster", "hare",
        "harrier", "hawk", "hedgehog", "heron", "herring", "hippopotamus",
    }

-- Seed once with a non-deterministic value.
math.randomseed(os.time())
math.random(); math.random(); math.random()

local function pick(t)
    return t[math.random(#t)]
end

-- Generate a random "adjective-noun" name, e.g. "brave-wolf".
function M.name()
    return pick(M.adjectives) .. "-" .. pick(M.animals)
end

-- Generate a unique email from a name + numeric suffix.
--   names.email("example.com")      => "brave-wolf-48213@example.com"
--   names.email("example.com", 42)  => "brave-wolf-42@example.com"
function M.email(domain, suffix)
    domain = domain or "example.com"
    local uniq = suffix or math.random(10000, 99999)
    return M.name() .. "-" .. tostring(uniq) .. "@" .. domain
end

return M
