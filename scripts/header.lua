local colors = require 'scripts.colors'
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
            --_____    --- /
                   -----___%s
]]):format(
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET,
  colors.FG_MAGENTA,
  colors.RESET
)
