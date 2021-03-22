local Fitter = {}

local CC_THRESHOLD = 0.1

local function feather_edges(img, sigma, axis)
  local margin = sigma * 2
  local wi, hi = img:width(), img:height()
  local alpha = img:extract_band(img:bands() - 1)
  if axis == 'x' then
    alpha = alpha:crop(margin, 0, wi - 2 * margin, hi)
      :embed(margin, 0, wi, hi)
      :gaussblur(sigma)
  else
    alpha = alpha:crop(0, margin, wi, hi - 2 * margin)
      :embed(0, margin, wi, hi)
      :gaussblur(sigma)
  end
  return img:extract_band(0, { n = img:bands() - 1 })
    :bandjoin(alpha)
end

--- Fits `img` inside the specified `layout`, using `base` as background.
--- If `img` doesn't fit the layout, it will be downscaled to be fully
--- contained in it. In that case, to fill otherwise empty space,
--- a blurred copy of `img` is placed behind it.
--- @param base Image
--- @param img Image
--- @param layout table
--- @return Image
function Fitter.contain(base, img, layout)
  local x, y, w, h, sigma = layout.x, layout.y, layout.w, layout.h, layout.blur or 2
  local wi, hi = img:width(), img:height()
  local r, ri = w / h, wi / hi
  if math.abs(ri - r) < CC_THRESHOLD then
    return Fitter.fill(base, img, layout)
  end
  local scale, bgscale, wb, hb, fg
  if ri > r then
    scale, bgscale = w / wi, h / hi
    wb, hb = wi * bgscale, h
    wi, hi = w, hi * scale
    fg = feather_edges(img:resize(scale), sigma, 'y')
  else
    scale, bgscale = h / hi, w / wi
    wb, hb = w, hi * bgscale
    wi, hi = wi * scale, h
    fg = feather_edges(img:resize(scale), sigma, 'x')
  end
  local bg = img:resize(bgscale):gaussblur(sigma)
  local wf, hf = fg:width(), fg:height()
  local xf, yf = wb / 2 - wf / 2, hb / 2 - hf / 2
  fg = bg:crop(xf, yf, wf, hf):composite(fg, 'over')
  img = bg:insert(fg, xf, yf):crop(wb / 2 - w / 2, hb / 2 - h / 2, w, h)
  return base:insert(img, x, y)
end

--- Fits `img` inside the specified `layout`, using `base` as background.
--- If `img` doesn't fit the layout, it will be upscaled to cover that
--- layout. The exceeding parts of `img` are cropped.
--- @param base Image
--- @param img Image
--- @param layout table
--- @return Image
function Fitter.cover(base, img, layout)
  local x, y, w, h = layout.x, layout.y, layout.w, layout.h
  local wi, hi = img:width(), img:height()
  local r, ri = w / h, wi / hi
  local scale
  if ri < r then
    scale = w / wi
    wi, hi = w, hi * scale
  else
    scale = h / hi
    wi, hi = wi * scale, h
  end
  img = img:resize(scale):crop(wi / 2 - w / 2, hi / 2 - h / 2, w, h)
  return base:insert(img, x, y)
end

--- Fits `img` inside the specified `layout`, using `base` as background.
--- If `img` doesn't fit the layout, it will be stretched to fill the
--- entire layout, losing aspect ratio.
function Fitter.fill(base, img, layout)
  local x, y, w, h = layout.x, layout.y, layout.w, layout.h
  local wi, hi = img:width(), img:height()
  return base:insert(img:resize(w / wi, { vscale = h / hi }), x, y)
end

return Fitter
