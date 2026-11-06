-- Turns ```{.ocaml .live} blocks into x-ocaml editors (https://github.com/art-w/x-ocaml).

if not quarto.doc.is_format("html") then
  return {}
end

-- With async, a cached script runs before later cells are parsed, and they never run.
local script = [[
<script defer
  src="https://cdn.jsdelivr.net/gh/art-w/x-ocaml.js@6/x-ocaml.js"
  src-worker="https://cdn.jsdelivr.net/gh/art-w/x-ocaml.js@6/x-ocaml.worker+effects.js"
  integrity="sha256-3ITn2LRgP/8Rz6oqP5ZQTysesNaSi6/iEdbDvBfyCSE="
  crossorigin="anonymous"
></script>
]]

local used = false

local function escape(s)
  return (s:gsub("[&<>]", { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;" }))
end

return {
  {
    CodeBlock = function(block)
      if block.classes:includes("ocaml") and block.classes:includes("live") then
        used = true
        return pandoc.RawBlock("html", "<x-ocaml>" .. escape(block.text) .. "</x-ocaml>")
      end
    end,
    Pandoc = function(doc)
      if used then
        quarto.doc.include_text("in-header", script)
      end
      return doc
    end,
  },
}
