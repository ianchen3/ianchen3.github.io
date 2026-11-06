-- Appends the BibTeX source of each `nocite` entry, read from the document's
-- `bibliography`, as a code block titled "BibTeX".

local function bibliographies(meta)
  local value = meta.bibliography
  if pandoc.utils.type(value) == "List" then
    return value:map(pandoc.utils.stringify)
  end
  return { pandoc.utils.stringify(value) }
end

local function read(path)
  local dir = pandoc.path.directory(quarto.doc.input_file)
  for _, candidate in ipairs({ pandoc.path.join({ dir, path }), path }) do
    local h = io.open(candidate)
    if h then
      local text = h:read("a")
      h:close()
      return text
    end
  end
end

local function entry(text, key)
  local start = text:find("@%a+%s*{%s*" .. key:gsub("%p", "%%%0") .. "%s*,")
  if not start then
    return nil
  end
  local open = text:find("{", start, true)
  local depth = 0
  for i = open, #text do
    local c = text:sub(i, i)
    if c == "{" then
      depth = depth + 1
    elseif c == "}" then
      depth = depth - 1
      if depth == 0 then
        return text:sub(start, i)
      end
    end
  end
end

function Pandoc(doc)
  if not (doc.meta.nocite and doc.meta.bibliography) then
    return nil
  end
  local keys = {}
  pandoc.Inlines(doc.meta.nocite):walk({
    Cite = function(cite)
      for _, citation in ipairs(cite.citations) do
        keys[#keys + 1] = citation.id
      end
    end,
  })
  local found = {}
  for _, path in ipairs(bibliographies(doc.meta)) do
    local text = read(path)
    for _, key in ipairs(keys) do
      found[#found + 1] = text and entry(text, key)
    end
  end
  if #found == 0 then
    return nil
  end
  doc.blocks:insert(pandoc.CodeBlock(table.concat(found, "\n\n"), { class = "bibtex", filename = "BibTeX" }))
  return doc
end
