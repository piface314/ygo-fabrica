local colors = require 'lib.colors'
local HIGHLIGHT = colors.FG_MAGENTA .. colors.BOLD

local Info = { version = "1.0.1", version_name = "artefato-astral" }

function Info.get_header()
  return ([[

                    %s---_____
                   /  _____ -----__
                  / /      -----   /
                 / /   _        / /%s
__     __  ____     %s_ / \ _%s    ____
\ \   / / / __ \   %s/ -___- \%s  | ___|
 \ \ / / / /  \/  %s_- / _ \ -_%s | |__        ___  ___   _   ___
  \   / | |  ___ %s|_ | |_| | _|%s| ___| /\   |   \|   \ | | / __\   /\
   | |  | | |__ |  %s/ \___/ \%s  | |   /  \  | D /| D / | || /     /  \
   | |   \ \__/ /  %s\_-   -_/%s  | |  / __ \ | D \| | \ | || \__  / __ \
   |_|    \____/      %s\_/%s     |_| /_/  \_\|___/|_|\_\|_| \___//_/  \_\
            %s/ /            / /
           /  -----____   / /
            --_____    --- /          %sv%s %s%s
                   -----___%s
]]):format(
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  HIGHLIGHT, colors.RESET,
  Info.version, Info.version_name,
  HIGHLIGHT, colors.RESET
)
end

function Info.get_version()
  return ("ygofabrica v%s %s"):format(Info.version, Info.version_name)
end

return Info