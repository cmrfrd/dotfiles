# Set PWD segment style
if not set -q dangerous_pwdstyle
  set -U dangerous_pwdstyle short long none
end
set pwd_style $dangerous_pwdstyle[1]

# Define colors
set -U dangerous_night 000000 083743 445659 fdf6e3 b58900 cb4b16 dc121f af005f 6c71c4 268bd2 2aa198 859900
set -U dangerous_day 000000 333333 666666 ffffff ffff00 ff6600 ff0000 ff0033 3300ff 00aaff 00ffff 00ff00
if not set -q dangerous_colors
   # Values are: black dark_gray light_gray white yellow orange red magenta violet blue cyan green
    set -U dangerous_colors $dangerous_night
end

# day theme
function day -d "Set color palette for bright environment."
    set dangerous_colors $dangerous_day
    set dangerous_cursors "\033]12;#$dangerous_colors[10]\007" "\033]12;#$dangerous_colors[5]\007" "\033]12;#$dangerous_colors[8]\007" "\033]12;#$dangerous_colors[9]\007"
end

# night theme
function night -d "Set color palette for dark environment."
    set dangerous_colors $dangerous_night
    set dangerous_cursors "\033]12;#$dangerous_colors[10]\007" "\033]12;#$dangerous_colors[5]\007" "\033]12;#$dangerous_colors[8]\007" "\033]12;#$dangerous_colors[9]\007"
end

# pre exec
function __dangerous_preexec -d 'Execute after hitting <Enter> before doing anything else'
  set -l cmd (commandline | sed 's|\s\+|\x1e|g')
  if [ $_ = 'fish' ]
    if [ -z $cmd[1] ]
      set -e cmd[1]
    end
    if [ -z $cmd[1] ]
      return
    end
    set -e dangerous_prompt_error[1]
    if not type -q $cmd[1]
      if [ -d $cmd[1] ]
        set dangerous_prompt_error (cd $cmd[1] 2>&1)
        and commandline ''
        commandline -f repaint
        return
      end
    end
    switch $cmd[1]
      case 'c'
        if begin
            [ (count $cmd) -gt 1 ]
            and [ $cmd[2] -gt 0 ]
          end
          commandline $prompt_hist[$cmd[2]]
          echo $prompt_hist[$cmd[2]] | xsel -b -i
          commandline -f repaint
          return
        end
      case 'cd'
        if [ (count $cmd) -le 2 ]
          set dangerous_prompt_error (eval $cmd 2>&1)
          and commandline ''
          if [ (count $dangerous_prompt_error) -gt 1 ]
            set dangerous_prompt_error $dangerous_prompt_error[1]
          end
          commandline -f repaint
          return
        end
      case 'day' 'night'
        if [ (count $cmd) -eq 1 ]
          eval $cmd
          commandline ''
          commandline -f repaint
          return
        end
    end
  end
  commandline -f execute
end


##############
# => Bookmarks
##############
function mark -d 'Create bookmark for present working directory.'
  if not contains $PWD $bookmarks
    set -U bookmarks $PWD $bookmarks
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function unmark -d 'Remove bookmark for present working directory.'
  if contains $PWD $bookmarks
    set -e bookmarks[(contains -i $PWD $bookmarks)]
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function m -d 'List bookmarks, jump to directory in list with m <number>'
  set -l num_items (count $bookmarks)
  if [ $num_items -eq 0 ]
    set_color $fish_color_error[1]
    echo 'Bookmark list is empty. '(set_color normal)'Enter '(set_color $fish_color_command[1])'mark '(set_color normal)'in INSERT mode or '(set_color $fish_color_command[1])'m '(set_color normal)'in NORMAL mode, if you want to add the current directory to your bookmark list.'
    return
  end
  for i in (seq $num_items)
    if [ $PWD = $bookmarks[$i] ]
      set_color $dangerous_colors[10]
    else
      if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
        set_color normal
      else
        set_color $dangerous_colors[3]
      end
    end
    echo '› '(expr $num_items - $i)\t$bookmarks[$i] | sed "s|$HOME|~|"
  end
  if [ $num_items -eq 1 ]
    set last_item ''
  else
    set last_item '-'(expr $num_items - 1)
  end
  echo -en $dangerous_cursors[1]
  set input_length (expr length (expr $num_items - 1))
  read -p 'echo -n (set_color $dangerous_colors[10])"⌘ Goto [0"$last_item"] ❯ "' -n $input_length -l dir_num
  switch $dir_num
    case (seq 0 (expr $num_items - 1))
      cd $bookmarks[(expr $num_items - $dir_num)]
  end
  for i in (seq (expr $num_items + 1))
    tput cuu1
  end
  tput ed
  tput cuu1
end

################
# => Git segment
################
function __dangerous_prompt_git_branch -d 'Return the current branch name'
    set -l branch (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
    if not test $branch > /dev/null
        set -l position (command git describe --contains --all HEAD 2> /dev/null)
        if not test $position > /dev/null
            set -l commit (command git rev-parse HEAD 2> /dev/null | sed 's|\(^.......\).*|\1|')
            set_color $dangerous_colors[11]
            if test $commit
            echo -n "❯ ➦ $commit "
            echo -n '❯'
        end
        else
            set_color $dangerous_colors[9]
            echo -n "❯  $position "
            echo -n '❯'
        end
    else
        set_color $dangerous_colors[4]
        echo -n "❯  $branch "
        echo -n '❯'
    end
end

######################
# => Bind-mode segment
######################
function __dangerous_prompt_bindmode -d 'Displays the current mode'
    switch $fish_bind_mode
        case default
            set dangerous_current_bindmode_color $dangerous_colors[10]
            echo -en $dangerous_cursors[1]
        case insert
            set dangerous_current_bindmode_color $dangerous_colors[5]
            echo -en $dangerous_cursors[2]
            if [ "$pwd_hist_lock" = true ]
                set pwd_hist_lock false
                __dangerous_create_dir_hist
            end
        case visual
            set dangerous_current_bindmode_color $dangerous_colors[8]
            echo -en $dangerous_cursors[3]
    end
    if [ (count $dangerous_prompt_error) -eq 1 ]
        set dangerous_current_bindmode_color $dangerous_colors[7]
    end
    set_color $dangerous_current_bindmode_color
    echo -n '❯'

    ## Get trunc path
    set trunc_path \
    (for i in (echo $PWD   | \
               tr "/" "\n" | \
               tail -n +2);  \
               echo "/$i" |  \
               head -c 2 ; end)

    echo -n " $trunc_path ❯"
end

####################
# => Symbols segment
####################
function __dangerous_prompt_left_symbols -d 'Display symbols'
    set -l symbols_urgent 'F'
    set -l symbols (set_color $dangerous_colors[3])'❯'

    set -l jobs (jobs | wc -l | tr -d '[:space:]')
    if [ -e ~/.taskrc ]
        set todo (task due.before:sunday 2> /dev/null | tail -1 | cut -f1 -d' ')
        set overdue (task due.before:today 2> /dev/null | tail -1 | cut -f1 -d' ')
    end
    if [ -e ~/.reminders ]
        set appointments (rem -a | cut -f1 -d' ')
    end
    if [ (count $todo) -eq 0 ]
        set todo 0
    end
    if [ (count $overdue) -eq 0 ]
        set overdue 0
    end
    if [ (count $appointments) -eq 0 ]
        set appointments 0
    end

    if [ $symbols_style = 'symbols' ]
        set symbols $symbols(set_color -o $dangerous_colors[8])' ✻'
        set symbols_urgent 'T'

        if contains $PWD $bookmarks
            set symbols $symbols(set_color -o $dangerous_colors[10])' ⌘'
        end
        if set -q -x EMACS
            set symbols $symbols(set_color -o $dangerous_colors[3])' E'
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color -o $dangerous_colors[11])' ⚙'
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $dangerous_colors[6])' '
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color -o $dangerous_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color -o $dangerous_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols' ⚔'
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color -o $dangerous_colors[5])' ⚑'
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color -o $dangerous_colors[12])' ✔'
        else
            set symbols $symbols(set_color -o $dangerous_colors[7])' ✘'
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $dangerous_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    else
        set symbols $symbols(set_color $dangerous_colors[8])
        set symbols_urgent 'T'

        if contains $PWD $bookmarks
            set symbols $symbols(set_color $dangerous_colors[10])' '(expr (count $bookmarks) - (contains -i $PWD $bookmarks))
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $dangerous_colors[9])' V'(set_color normal)
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color $dangerous_colors[11])' '$jobs
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $dangerous_colors[6])' '(set_color normal)
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color $dangerous_colors[4])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color $dangerous_colors[8])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols" $todo"
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color $dangerous_colors[12])' '$last_status
        else
            set symbols $symbols(set_color $dangerous_colors[7])' '$last_status
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $dangerous_colors[6])' ⚡'
            set symbols_urgent 'T'
        end
    end
    set symbols $symbols(set_color $dangerous_colors[3])' ❯'
    # switch $pwd_style
    #     case none
    #         if test $symbols_urgent = 'T'
    #             set symbols (set_color $dangerous_colors[3])'❯'
    #         else
    #             set symbols ''
    #         end
    # end
    echo -n $symbols
end

###############################################################################
# => Prompt initialization
###############################################################################

# Initialize some global variables
set -g dangerous_prompt_error
set -g dangerous_current_bindmode_color
set -g CMD_DURATION 0
set -g pwd_hist_lock false
set -g prompt_hist
set -g no_prompt_hist 'F'
set -g symbols_style 'symbols'

# Load user defined key bindings
if functions --query fish_user_key_bindings
  fish_user_key_bindings
end

# Don't save in command history
if not set -q dangerous_nocmdhist
  set -U dangerous_nocmdhist 'c' 'd' 'll' 'ls' 'm' 's'
end

# Cd to newest bookmark if this is a login shell
if not begin
    set -q -x LOGIN
    or set -q -x RANGER_LEVEL
    or set -q -x VIM
  end 2> /dev/null
  cd $bookmarks[1]
end
set -x LOGIN $USER

###############################################################################
# => Left prompt
###############################################################################

function fish_prompt -d 'Write out the left prompt of the dangerous theme'
  set -g last_status $status
  echo -n -s (__dangerous_prompt_bindmode) (__dangerous_prompt_git_branch) (__dangerous_prompt_left_symbols) ' '
end

set fish_greeting
function fish_title
    true
end
