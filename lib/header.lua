local Version = require 'lib.version'
local colors = require 'lib.colors'
local HIGHLIGHT = colors.FG_MAGENTA .. colors.BOLD

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
  Version.number, Version.name,
  HIGHLIGHT, colors.RESET
)