-- Shortcode `{{< today >}}`: the date the page is rendered, as YYYY-MM-DD.

return {
  today = function()
    return pandoc.Str(os.date("%Y-%m-%d"))
  end,
}
