local function prepare_reply_text(text)
  local prefix = '{{chat}}\n'
  return prefix .. text
end

return {
  reply = function(text)
    local text_to_insert = prepare_reply_text(text)
    local text_lines = {}
    for line in text_to_insert:gmatch '[^\r\n]+' do
      table.insert(text_lines, line)
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local found_end = false

    for i, line in ipairs(lines) do
      if line:find('@end', 1, true) then
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i - 1, false, text_lines)
        vim.cmd 'redraw!'
        vim.cmd 'syntax sync fromstart'
        found_end = true
        break
      end
    end

    if not found_end then
      print "No '@end' tag found in the document."
    end
  end,
}
