local A = require("my.abbreviations")
local scrap = require("scrap")

require("my.helpers.wrapMovement").enable()

vim.opt.conceallevel = 0

-- vim.opt.foldcolumn = "1"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldmethod = "expr"

-- {{{ Older functions for calculating things inside vim
-- vim.keymap.set("n", "<leader>lg", function()
--   if not pcall(function()
--     local a = tonumber(vim.fn.input("A: "))
--     local b = tonumber(vim.fn.input("B: "))
--
--     local g, x, y = require("my.helpers.math.mod").gcd(a, b)
--
--     vim.fn.input("Result: " .. g .. " " .. x .. " " .. y)
--   end) then vim.fn.input("No results exist") end
-- end, { buffer = true, desc = "Gcd calculator" })
--
-- vim.keymap.set("n", "<leader>li", function()
--   if not pcall(function()
--     local class = tonumber(vim.fn.input("Mod class: "))
--     local num = tonumber(vim.fn.input("Number: "))
--
--     vim.fn.input("Result: " .. require("my.helpers.math.mod").modinverse(num, class))
--   end) then vim.fn.input("No results exist") end
-- end, { buffer = true, desc = "Mod inverse calculator" })
-- }}}

local abbreviations = {
  -- Other fancy symvols
  { "tmat", "^T" }, -- Tranpose of a matrix
  { "cmat", "^*" }, -- Conjugate of a matrix
  { "sneg", "^C" }, -- Set complement
  { "ortco", "^\\bot" }, -- Orthogonal complement
  { "sinter", "^\\circ" }, -- Interior of a set
  { "nuls", "\\varnothing" },

  -- Basic commands
  { "mangle", "\\measuredangle" },
  { "aangle", "\\angle" },
  { "sdiff", "\\setminus" },
  { "sst", "\\subset" },
  { "spt", "\\supset" },
  { "sseq", "\\subseteq" },
  { "speq", "\\supseteq" },
  { "nin", "\\not\\in" },
  { "iin", "\\in" },
  { "tto", "\\to" },
  { "land", "\\land" },
  { "lor", "\\lor" },
  { "ssin", "\\sin" },
  { "ccos", "\\cos" },
  { "ttan", "\\ttan" },
  { "ssec", "\\sec" },
  { "lln", "\\ln" },
  { "frl", "\\forall" },
  { "exs", "\\exists" },
  { "iinf", "\\infty" },
  { "ninf", "-\\infty" },
  { "nlnl", "\\pm" }, -- had this as npnp first but it was hard-ish to type
  { "ccup", "\\cup" },
  { "ccap", "\\cap" },
  { "nope", "\\bot" },
  { "yee", "\\top" },
  { "ccan", "\\cancel" },
  { "com", "\\circ" },
  { "mul", "\\cdot" },
  { "smul", "\\times" },
  { "card", "\\#" },
  { "div", "\\|" },
  { "ndiv", "\\not\\|\\:" },
  { "perp", "\\perp" },
  { "cdots", "\\cdots" }, -- center dots
  { "ldots", "\\ldots" }, -- low dots
  { "cldots", ",\\ldots," }, -- comma, low dots
  { "frac", "\\frac" }, -- fraction
  { "lim", "\\lim" }, -- Limit
  { "sup", "\\sup" }, -- supremum
  { "limsup", "\\lim\\sup" }, -- Limit of the supremum
  { "cal", "\\mathcal" }, -- Limit of the supremum

  -- Decorations
  { "hat", "\\hat" },
  { "bar", "\\bar" },

  -- Custom commands
  { "abs", "\\abs" }, -- custom abs command
  { "norm", "\\norm" }, -- custom norm command
  { "iprod", "\\iprod" }, -- custom inner product command
  { "diprod", "\\dprod" }, -- custom self inner product command
  { "prob", "\\prob" }, -- custom probability function
  { "dist", "\\dist" }, -- custom dist function
  { "ball", "\\ball" }, -- custom ball function
  { "diam", "\\diam" }, -- custom diam operator
  { "gen", "\\gen" }, -- custom command for group generated by element
  { "ord", "\\ordop" }, -- order of a group
  { "vsm", "\\vecspace" }, -- custom math vector space
  { "half", "\\half" }, -- 1/2 fraction
}

-- Todo: convert exponents and subscripts
-- to use this more concise notation.
local abolishAbbreviations = {
  -- {{{ General phrases
  { "thrf", "therefore" },
  { "bcla", "by contradiction let's assume" },
  { "wlg", "without loss of generality" },
  { "tits", "that is to say," },
  { "wpbd", "we will prove the statement in both directions." },
  { "stam{,s}", "statement{}" },
  { "{ww,tt}{m,i}", "{which,this} {means,implies}" },
  { "cex{,s}", "counterexample{}" },
  { "er{t,s,r}", "{transitivity,symmetry,reflexivity}" },
  -- }}}
  -- {{{ Exponents and subscripts:
  --   {operation}{argument}
  --   - operation = e (exponent) | s (subscript)
  --   - argument = t{special} | {basic}
  --   - basic = 0-9|n|i|t|k
  --   - special =
  --     - "p" => +
  --     - "m" => -
  --     - "i" => -1
  {
    "{e,s}{{0,1,2,3,4,5,6,7,8,9,n,i,t,k},t{i,m,p}}",
    "{^,_}{{},{\\{-1\\},-,+}}",
    options = A.no_capitalization,
  },
  -- }}}
  -- {{{ Special chars
  -- System for writing special characters which need to also be easly
  -- accessible as {sub/super}scripts.
  --
  -- The reason epsilon and lambda are separated out from everything else in
  -- the pattern is because they are the only ones where `foo` doesn't expand
  -- to `\\foo` directly (so I saved some keystrokes by letting scrap.nvim
  -- repeat everything for me).
  {
    "{,e,s}{{eps,lam},{star,delta,Delta,pi,tau,psi,phi,rho,sigma,alpha,beta,theta,gamma,omega,Omega}}",
    "{,^,_}\\\\{{epsilon,lambda},{}}",
    options = A.no_capitalization,
  },
  -- }}}
  -- {{{ My own operator syntax:
  --   - Any operator can be prefixed with "a" to
  --     align in aligned mode
  --   - Any operator can be prefixed with cr to
  --     start a new line and align in aligned mode
  {
    "{cr,a,}{eq,neq,leq,geq,lt,gt,iff,iip,iib}",
    "{\\\\\\&,&,}{=,\\neq,\\leq,\\geq,<,>,\\iff,\\implies,\\impliedby}",
    options = A.no_capitalization,
  },
  -- }}}
  -- {{{ Set symbols
  --   - nats => naturals
  --   - ints => integers
  --   - rats => rationals
  --   - irats => irationals
  --   - rrea => reals
  --   - comp => complex
  --   - ppri => primes
  --   - ffie => fields
  {
    "{nats,ints,rats,irats,rrea,comp,ppri,ffie}",
    "\\mathbb\\{{N,Z,Q,I,R,C,P,F}\\}",
    options = A.no_capitalization,
  },
  -- }}}
  -- {{{ General function calls:
  --   {function-name}{modifier?}{argument}{argument-modifier?}
  --
  --   - function-name = f/g/h/P
  --   - modifier:
  --     - d => derivative
  --     - 2 => squared
  --     - 3 => cubed
  --     - i => inverse
  --   - argument = x/y/z/a/t/i/n/k
  --   - argument-modifier:
  --     - n => subscript n
  {
    "{f,g,h,P}{d,2,3,i,}{x,y,z,a,t,i,n,k}{n,}",
    "{}{',^2,^3,^\\{-1\\},}({}{_n,})",
  },
  -- }}}
  -- {{{ Calculus & analysis
  { "ib{p,s}", "integration by {parts,substitution}" },
  { "nb{,h}{,s}", "neighbour{,hood}{}" },
  -- }}}
  -- {{{ Linear algebra
  { "rref", "reduced row echalon form" },
  { "eg{va,ve,p}{,s}", "eigen{value,vector,pair}{}" },
  { "mx{,s}", "matri{x,ces}" },
  { "dete{,s}", "determinant{}" },
  { "ort{n,g}", "orto{normal,gonal}" },
  { "l{in,de}", "linearly {independent,dependent}" },
  { "lcon{,s}", "linear combination{}" },
  { "vst{,s}", "vector space{}" }, -- text vector space
  {
    "rizz", -- ok please ignore this one 💀
    "Riesz vector",
    options = A.no_capitalization,
  },
  -- }}}
  -- {{{ Linear systems
  -- Note: we must add the space inside the {} in order for capitalization to work!
  {
    "{{s,o,l},}deq{s,}",
    "{{scalar,ordinary,linear} ,}differential equation{}",
  },
  -- }}}
  -- {{{ Graph theory
  { "vx{,s}", "vert{ex,ices}" },
  { "edg{,s}", "edge{}" },

  -- Graph theory function syntax:
  --   gt[function]{graph}{modifier}
  --   - function:
  --     - basic functions: e/E/v/G/L
  --     - k => connectivity
  --     - a => size of the biggest stable set
  --     - w => size of the biggest clique
  --     - d => biggest degree
  --     - c{target}{kind} => {target} {kind} chromatic number
  --       - target:
  --         - vertices by default
  --         - e => edges
  --       - kind:
  --         - normal by default
  --         - l => list
  --   - graph:
  --     - G by default
  --     - s/x/y/h => S/X/Y/H
  --   - modifier:
  --     - a => '
  --     - 1/2 => _k
  {
    "gt{{e,E,v,V,L},k,a,w,d,md{,e},c{,e}{,l}}{,s,h,x,y}{,a,1,2}",
    "{{},\\kappa,\\alpha,\\omega,\\Delta,\\delta{,'},\\chi{,'}{,_l}}({G,S,H,X,Y}{,',_1,_2})",
    options = A.no_capitalization,
  },
  -- }}}
}

local expanded = scrap.expand_many(abolishAbbreviations)

-- Last I checked this contained 1229 abbreviations
-- print(#abbreviations + #expanded)

A.manyLocalAbbr(abbreviations)
A.manyLocalAbbr(expanded)

vim.keymap.set(
  "n",
  "<leader>lc",
  "<cmd>VimtexCompile<cr>",
  { desc = "Compile current buffer using vimtex", buffer = true }
)

vim.opt_local.list = false -- The lsp usese tabs for formatting
